import 'package:web/web.dart' as web;
import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'page_config.dart';
import 'noop_url_strategy.dart';

/// JSON-based Navigator - Main public API
class JsonNavigator {
  // Private constructor
  JsonNavigator._();

  static final Map<Enum, Widget Function()> _routes = {};
  static Enum? _currentPage;
  static final ValueNotifier<Enum?> _currentPageNotifier =
      ValueNotifier<Enum?>(null);
  static bool _isInitialized = false;
  static bool _isNavigating = false;
  static Enum? _lastRestoredPage;
  static final Map<String, Enum> _nameToPage = {};
  static void Function(Enum page)? _onPageChangeEnum;
  static Type? _enumType;
  static bool _loggingEnabled = kDebugMode;
  static final Map<Enum, GuardDecision<Enum> Function(Map<String, dynamic>)>
      _middlewares = {};

  /// Initialize and register pages
  static void initialize<T extends Enum>({
    required List<PageConfig<T>> pages,
    required T initialPage,
    void Function(T page)? onPageChange,
    bool enableLogging = kDebugMode,
  }) {
    if (_isInitialized) {
      throw StateError(
          'JsonNavigator is already initialized. Call initialize() only once.');
    }

    if (!kIsWeb) {
      throw UnsupportedError('JsonNavigator only works on Web platform');
    }

    if (pages.isEmpty) {
      throw ArgumentError('pages must not be empty');
    }

    // Set URL Strategy
    setUrlStrategy(NoOpUrlStrategy());

    // Remember enum type used for initialization
    _enumType = T;

    // Set logging option
    _loggingEnabled = enableLogging;

    // Set onPageChange callback (typed wrapper)
    if (onPageChange != null) {
      _onPageChangeEnum = (Enum page) => onPageChange(page as T);
    } else {
      _onPageChangeEnum = null;
    }

    // Register pages
    for (final page in pages) {
      if (_routes.containsKey(page.page)) {
        throw ArgumentError('Page ${page.page.name} is already registered.');
      }
      _routes[page.page] = page.builder;
      _nameToPage[page.page.name] = page.page;

      // Register middleware if provided (typed wrapper)
      if (page.middleware != null) {
        _middlewares[page.page] = (Map<String, dynamic> params) =>
            (page.middleware!(params)) as GuardDecision<Enum>;
      }
    }

    // Validate initial page is registered
    if (!_routes.containsKey(initialPage)) {
      throw ArgumentError(
          'initialPage "${initialPage.name}" must be included in the pages list');
    }

    // Set initial page
    _currentPage = initialPage;
    _currentPageNotifier.value = initialPage;

    // Restore saved state
    _restoreLastPage();

    // Setup browser navigation listener
    _setupBrowserListener();

    // Set initial browser state
    _setInitialBrowserState();

    _isInitialized = true;
    _log('[JsonNavigator] Initialized with page: ${_currentPage?.name}');
  }

  /// Enable/disable internal logging at runtime
  static void setLoggingEnabled(bool enabled) {
    _loggingEnabled = enabled;
  }

  static void _log(Object? message) {
    if (_loggingEnabled) {
      debugPrint(message?.toString());
    }
  }

  /// Typed: Navigate to a page using enum (without parameters)
  static void navigateToEnum<T extends Enum>(T page) {
    _ensureInitialized();
    _ensureEnumType<T>();

    if (_currentPage == page || _isNavigating) return;

    _isNavigating = true;
    try {
      final resolved = _resolveGuard(page, const {});
      _commitNavigation(
        resolved.page,
        resolved.params,
        replace: resolved.redirected ? resolved.replace : false,
        triggeredByPopState: false,
      );
      _log(
          '[JsonNavigator] SUCCESS - page(enum): ${resolved.page.name}${resolved.params.isNotEmpty ? ', params: ${resolved.params}' : ''}');
    } catch (e) {
      _log('[JsonNavigator] ERROR (enum): $e');
    } finally {
      _isNavigating = false;
    }
  }

  /// Typed: Navigate to a page using enum (with JSON parameters)
  static void navigateToEnumWithParams<T extends Enum>(
      T page, Map<String, dynamic> params) {
    _ensureInitialized();
    _ensureEnumType<T>();

    if (_isNavigating) {
      _log('[JsonNavigator] Skipping - already navigating');
      return;
    }

    _isNavigating = true;
    try {
      final resolved = _resolveGuard(page, params);
      _commitNavigation(
        resolved.page,
        resolved.params,
        replace: resolved.redirected ? resolved.replace : false,
        triggeredByPopState: false,
      );
      _log(
          '[JsonNavigator] SUCCESS - page(enum): ${resolved.page.name}, params: ${resolved.params}');
    } catch (e) {
      _log('[JsonNavigator] ERROR (enum): $e');
    } finally {
      _isNavigating = false;
    }
  }

  /// Navigate to a page (without parameters)
  static void navigateTo(String pageName) {
    _ensureInitialized();

    final page = _nameToPage[pageName];
    if (page == null) {
      throw ArgumentError('Page "$pageName" is not registered');
    }

    if (_currentPage == page || _isNavigating) return;

    _isNavigating = true;
    try {
      final resolved = _resolveGuard(page, const {});
      _commitNavigation(
        resolved.page,
        resolved.params,
        replace: resolved.redirected ? resolved.replace : false,
        triggeredByPopState: false,
      );
      _log(
          '[JsonNavigator] SUCCESS - page: ${resolved.page.name}${resolved.params.isNotEmpty ? ', params: ${resolved.params}' : ''}');
    } catch (e) {
      _log('[JsonNavigator] ERROR: $e');
    } finally {
      _isNavigating = false;
    }
  }

  /// Navigate to a page (with JSON parameters)
  static void navigateToWithParams(
      String pageName, Map<String, dynamic> params) {
    _ensureInitialized();

    final page = _nameToPage[pageName];
    if (page == null) {
      throw ArgumentError('Page "$pageName" is not registered');
    }

    if (_isNavigating) {
      _log('[JsonNavigator] Skipping - already navigating');
      return;
    }

    _isNavigating = true;
    try {
      final resolved = _resolveGuard(page, params);
      _commitNavigation(
        resolved.page,
        resolved.params,
        replace: resolved.redirected ? resolved.replace : false,
        triggeredByPopState: false,
      );
      _log(
          '[JsonNavigator] SUCCESS - page: ${resolved.page.name}, params: ${resolved.params}');
    } catch (e) {
      _log('[JsonNavigator] ERROR: $e');
    } finally {
      _isNavigating = false;
    }
  }

  /// Go back to previous page
  static void goBack() {
    _ensureInitialized();
    if (_isNavigating) return;

    try {
      web.window.history.back();
    } catch (e) {
      _log('[JsonNavigator] Go back error: $e');
    }
  }

  /// Go forward to next page
  static void goForward() {
    _ensureInitialized();
    if (_isNavigating) return;

    try {
      web.window.history.forward();
    } catch (e) {
      _log('[JsonNavigator] Go forward error: $e');
    }
  }

  /// Replace current page (without adding to history)
  static void replaceTo(String pageName, {Map<String, dynamic>? params}) {
    _ensureInitialized();

    final page = _nameToPage[pageName];
    if (page == null) {
      throw ArgumentError('Page "$pageName" is not registered');
    }

    try {
      final resolved = _resolveGuard(page, params ?? const {});
      _commitNavigation(
        resolved.page,
        resolved.params,
        replace: true, // replace semantics requested explicitly
        triggeredByPopState: false,
      );
      _log(
          '[JsonNavigator] REPLACE SUCCESS - page: ${resolved.page.name}${resolved.params.isNotEmpty ? ', params: ${resolved.params}' : ''}');
    } catch (e) {
      _log('[JsonNavigator] REPLACE ERROR: $e');
    }
  }

  /// Typed: Replace current page using enum (without adding to history)
  static void replaceToEnum<T extends Enum>(T page,
      {Map<String, dynamic>? params}) {
    _ensureInitialized();
    _ensureEnumType<T>();

    try {
      final resolved = _resolveGuard(page, params ?? const {});
      _commitNavigation(
        resolved.page,
        resolved.params,
        replace: true,
        triggeredByPopState: false,
      );
      _log(
          '[JsonNavigator] REPLACE SUCCESS - page(enum): ${resolved.page.name}${resolved.params.isNotEmpty ? ', params: ${resolved.params}' : ''}');
    } catch (e) {
      _log('[JsonNavigator] REPLACE ERROR (enum): $e');
    }
  }

  /// Get parameters of current page
  static Map<String, dynamic> getParams() {
    final data = web.window.sessionStorage.getItem('currentParams');
    if (data == null || data.isEmpty) return {};

    try {
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (e) {
      _log('[JsonNavigator] Failed to parse params: $e');
      return {};
    }
  }

  /// Get current page name
  static String? get currentPageName => _currentPage?.name;

  /// Typed: Get current page as enum T
  static T? currentPageAs<T extends Enum>() {
    _ensureInitialized();
    _ensureEnumType<T>();
    return _currentPage as T?;
  }

  /// Get current page notifier (internal use)
  static ValueNotifier<Enum?> get currentPageNotifier => _currentPageNotifier;

  /// Get page widget (internal use)
  static Widget? getPageWidget(Enum page) {
    final builder = _routes[page];
    return builder?.call();
  }

  // Private methods
  static void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
          'JsonNavigator is not initialized. Call initialize() first.');
    }
  }

  static void _ensureEnumType<T extends Enum>() {
    if (_enumType != null && _enumType != T) {
      throw StateError(
          'JsonNavigator was initialized with enum type $_enumType, but was accessed with $T');
    }
  }

  static void _clearParams() {
    web.window.sessionStorage.removeItem('currentParams');
  }

  static void _setParams(Map<String, dynamic> params) {
    web.window.sessionStorage.setItem('currentParams', jsonEncode(params));
  }

  static void _setupBrowserListener() {
    web.window.addEventListener(
        'popstate',
        ((web.Event event) {
          try {
            final popStateEvent = event as web.PopStateEvent;
            final state = popStateEvent.state?.dartify();
            _log('[JsonNavigator] PopState event: $state');

            if (state != null && state is Map && state['flutter'] == true) {
              final pageName = state['page']?.toString();
              final paramsJson = state['params']?.toString();

              if (pageName != null) {
                _log('[JsonNavigator] Restoring to page: $pageName');
                _restoreAppStateSync(pageName, paramsJson);
              } else {
                _log('[JsonNavigator] No page in state');
                _handleInvalidState();
              }
            } else {
              _log('[JsonNavigator] Invalid state');
              _handleInvalidState();
            }
          } catch (e) {
            _log('[JsonNavigator] PopState error: $e');
            _handleInvalidState();
          }
        }.toJS));
  }

  static void _restoreAppStateSync(String pageName, String? paramsJson) {
    try {
      final page = _nameToPage[pageName];
      if (page != null) {
        Map<String, dynamic> params = const {};
        if (paramsJson != null && paramsJson.isNotEmpty) {
          try {
            params = jsonDecode(paramsJson) as Map<String, dynamic>;
            _log('[JsonNavigator] Restored params: $params');
          } catch (e) {
            _log('[JsonNavigator] Failed to parse params: $e');
          }
        }

        final resolved = _resolveGuard(page, params);
        // For popstate: if redirected, rewrite current entry; if allowed, no history change
        _commitNavigation(
          resolved.page,
          resolved.params,
          replace: resolved.redirected ? resolved.replace : false,
          triggeredByPopState: true,
        );

        _log(
            '[JsonNavigator] Restored to: ${resolved.page.name}${resolved.params.isNotEmpty ? ' with params' : ''}');
      }
    } catch (e) {
      _log('[JsonNavigator] RestoreAppStateSync error: $e');
    }
  }

  static void _handleInvalidState() {
    final targetPage = _lastRestoredPage ?? _currentPage;
    if (targetPage == null) return;
    _log('[JsonNavigator] Redirecting to ${targetPage.name}');
    final resolved = _resolveGuard(targetPage, getParams());
    _commitNavigation(
      resolved.page,
      resolved.params,
      replace: true,
      triggeredByPopState: true,
    );
  }

  static void _setInitialBrowserState() {
    try {
      final lastPageData = web.window.sessionStorage.getItem('lastPage');
      if (lastPageData != null && lastPageData.isNotEmpty) {
        _log('[JsonNavigator] sessionStorage already has data, skipping');
        return;
      }

      if (_currentPage == null) return;

      final params = getParams();
      final resolved = _resolveGuard(_currentPage!, params);
      final stateData = {
        'flutter': true,
        'page': resolved.page.name,
        if (resolved.params.isNotEmpty) 'params': jsonEncode(resolved.params),
      };
      _log('[JsonNavigator] Setting initial state: $stateData');
      web.window.history.replaceState(stateData.jsify(), '', '/');
      _saveLastPage(resolved.page.name, resolved.params);
    } catch (e) {
      _log('[JsonNavigator] SetInitialBrowserState error: $e');
    }
  }

  static void _saveLastPage(String pageName, Map<String, dynamic> params) {
    try {
      final data = {
        'page': pageName,
        'params': params,
      };
      web.window.sessionStorage.setItem('lastPage', jsonEncode(data));
      _log('[JsonNavigator] Saved to sessionStorage: $data');
    } catch (e) {
      _log('[JsonNavigator] Save last page error: $e');
    }
  }

  static void _restoreLastPage() {
    try {
      // 브라우저 history state를 먼저 확인
      final currentState = web.window.history.state?.dartify();
      if (currentState != null &&
          currentState is Map &&
          currentState['flutter'] == true) {
        final pageName = currentState['page']?.toString();
        final paramsJson = currentState['params']?.toString();

        if (pageName != null) {
          final page = _nameToPage[pageName];
          if (page != null) {
            if (paramsJson != null && paramsJson.isNotEmpty) {
              try {
                final params = jsonDecode(paramsJson) as Map<String, dynamic>;
                _setParams(params);
                _log(
                    '[JsonNavigator] Restored params from history.state: $params');
              } catch (e) {
                _log(
                    '[JsonNavigator] Failed to parse params from history.state: $e');
              }
            }
            final resolved = _resolveGuard(page, getParams());
            _commitNavigation(
              resolved.page,
              resolved.params,
              replace: false, // don't mutate history; state already matches
              triggeredByPopState: true,
            );

            // sessionStorage도 업데이트 (ensure stored value matches)
            _saveLastPage(resolved.page.name, resolved.params);

            _log(
                '[JsonNavigator] Restored from history.state: ${resolved.page.name}');
            return;
          }
        }
      }

      // Fallback: sessionStorage에서 복원
      final lastPageData = web.window.sessionStorage.getItem('lastPage');
      if (lastPageData != null && lastPageData.isNotEmpty) {
        try {
          final data = jsonDecode(lastPageData) as Map<String, dynamic>;
          final pageName = data['page'] as String?;
          final params = data['params'] as Map<String, dynamic>?;

          if (pageName != null) {
            final page = _nameToPage[pageName];
            if (page != null) {
              if (params != null && params.isNotEmpty) {
                _setParams(params);
                _log(
                    '[JsonNavigator] Restored params from sessionStorage: $params');
              }
              final resolved = _resolveGuard(page, getParams());
              _commitNavigation(
                resolved.page,
                resolved.params,
                replace:
                    true, // sessionStorage is our source of truth, rewrite current entry
                triggeredByPopState: true,
              );

              _log(
                  '[JsonNavigator] Restored from sessionStorage: ${resolved.page.name}');
              return;
            }
          }
        } catch (e) {
          _log('[JsonNavigator] Failed to parse sessionStorage data: $e');
        }
      }

      _log('[JsonNavigator] No restore data');
    } catch (e) {
      _log('[JsonNavigator] Restore last page error: $e');
    }
  }

  // Guard evaluation helpers
  static _GuardResolution _resolveGuard(
      Enum target, Map<String, dynamic> params) {
    var page = target;
    var p = params;
    var replace = false;
    var redirected = false;
    const maxHops = 8;
    for (var i = 0; i < maxHops; i++) {
      final mw = _middlewares[page];
      if (mw == null) break;
      final decision = mw(p);
      if (decision.allow) break;
      if (decision.to == null) break;
      // apply redirect
      redirected = true;
      replace = decision.replace;
      page = decision.to as Enum;
      p = decision.params;
    }
    return _GuardResolution(
        page: page, params: p, replace: replace, redirected: redirected);
  }

  static void _commitNavigation(
    Enum page,
    Map<String, dynamic> params, {
    required bool replace,
    required bool triggeredByPopState,
  }) {
    // Update params storage
    _clearParams();
    if (params.isNotEmpty) {
      _setParams(params);
    }

    // Update current page and notify
    _currentPage = page;
    _currentPageNotifier.value = page;
    _lastRestoredPage = page;

    // Build state data
    final stateData = {
      'flutter': true,
      'page': page.name,
      if (params.isNotEmpty) 'params': jsonEncode(params),
    };

    // Commit to history depending on context
    if (triggeredByPopState) {
      // On popstate, do not push a new entry. If we redirected or need to rewrite, replace.
      if (replace) {
        _log('[JsonNavigator] ReplaceState (popstate) with: $stateData');
        web.window.history.replaceState(stateData.jsify(), '', '/');
      } else {
        // No history mutation; state already points to the entry we're restoring.
        _log(
            '[JsonNavigator] Popstate restore without history mutation: $stateData');
      }
    } else {
      if (replace) {
        _log('[JsonNavigator] Replacing state: $stateData');
        web.window.history.replaceState(stateData.jsify(), '', '/');
      } else {
        _log('[JsonNavigator] Pushing state: $stateData');
        web.window.history.pushState(stateData.jsify(), '', '/');
      }
    }

    // Persist session copy of last page
    _saveLastPage(page.name, params);

    // Notify callback
    _onPageChangeEnum?.call(page);
  }
}

class _GuardResolution {
  final Enum page;
  final Map<String, dynamic> params;
  final bool replace;
  final bool redirected;
  const _GuardResolution(
      {required this.page,
      required this.params,
      required this.replace,
      required this.redirected});
}
