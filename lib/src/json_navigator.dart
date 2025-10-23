import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'page_config.dart';
import 'noop_url_strategy.dart';

/// JSON-based Navigator - Main public API
class JsonNavigator<T extends Enum> {
  // Private constructor
  JsonNavigator._();

  static final Map<Enum, Widget Function()> _routes = {};
  static Enum? _currentPage;
  static final ValueNotifier<Enum?> _currentPageNotifier = ValueNotifier<Enum?>(null);
  static bool _isInitialized = false;
  static bool _isNavigating = false;
  static Enum? _lastRestoredPage;
  static final Map<String, Enum> _nameToPage = {};

  /// Initialize and register pages
  static void initialize<T extends Enum>({
    required List<PageConfig<T>> pages,
    required T initialPage,
  }) {
    if (_isInitialized) {
      throw StateError('JsonNavigator is already initialized. Call initialize() only once.');
    }

    if (!kIsWeb) {
      throw UnsupportedError('JsonNavigator only works on Web platform');
    }

    // Set URL Strategy
    setUrlStrategy(NoOpUrlStrategy());

    // Register pages
    for (final page in pages) {
      if (_routes.containsKey(page.page)) {
        throw ArgumentError('Page ${page.page.name} is already registered.');
      }
      _routes[page.page] = page.builder;
      _nameToPage[page.page.name] = page.page;
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
    debugPrint('[JsonNavigator] Initialized with page: ${_currentPage?.name}');
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
      _clearParams();
      _currentPage = page;
      _currentPageNotifier.value = page;

      final stateData = {
        'flutter': true,
        'page': pageName,
      };
      debugPrint('[JsonNavigator] Pushing state: $stateData');
      html.window.history.pushState(stateData, '', '/');
      _saveLastPage(pageName, {});

      debugPrint('[JsonNavigator] SUCCESS - page: $pageName');
    } catch (e) {
      debugPrint('[JsonNavigator] ERROR: $e');
    } finally {
      _isNavigating = false;
    }
  }

  /// Navigate to a page (with JSON parameters)
  static void navigateToWithParams(String pageName, Map<String, dynamic> params) {
    _ensureInitialized();

    final page = _nameToPage[pageName];
    if (page == null) {
      throw ArgumentError('Page "$pageName" is not registered');
    }

    if (_isNavigating) {
      debugPrint('[JsonNavigator] Skipping - already navigating');
      return;
    }

    _isNavigating = true;
    try {
      _clearParams();
      _setParams(params);

      _currentPage = page;
      _currentPageNotifier.value = page;

      final paramsJson = jsonEncode(params);
      final stateData = {
        'flutter': true,
        'page': pageName,
        'params': paramsJson,
      };
      debugPrint('[JsonNavigator] Pushing state: $stateData');
      html.window.history.pushState(stateData, '', '/');
      _saveLastPage(pageName, params);

      debugPrint('[JsonNavigator] SUCCESS - page: $pageName, params: $params');
    } catch (e) {
      debugPrint('[JsonNavigator] ERROR: $e');
    } finally {
      _isNavigating = false;
    }
  }

  /// Go back to previous page
  static void goBack() {
    _ensureInitialized();
    if (_isNavigating) return;

    try {
      html.window.history.back();
    } catch (e) {
      debugPrint('[JsonNavigator] Go back error: $e');
    }
  }

  /// Go forward to next page
  static void goForward() {
    _ensureInitialized();
    if (_isNavigating) return;

    try {
      html.window.history.forward();
    } catch (e) {
      debugPrint('[JsonNavigator] Go forward error: $e');
    }
  }

  /// Get parameters of current page
  static Map<String, dynamic> getParams() {
    final data = html.window.sessionStorage['currentParams'];
    if (data == null || data.isEmpty) return {};

    try {
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('[JsonNavigator] Failed to parse params: $e');
      return {};
    }
  }

  /// Get current page name
  static String? get currentPageName => _currentPage?.name;

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
      throw StateError('JsonNavigator is not initialized. Call initialize() first.');
    }
  }

  static void _clearParams() {
    html.window.sessionStorage.remove('currentParams');
  }

  static void _setParams(Map<String, dynamic> params) {
    html.window.sessionStorage['currentParams'] = jsonEncode(params);
  }

  static void _setupBrowserListener() {
    html.window.onPopState.listen((event) {
      try {
        final state = event.state;
        debugPrint('[JsonNavigator] PopState event: $state');

        if (state != null && state is Map && state['flutter'] == true) {
          final pageName = state['page']?.toString();
          final paramsJson = state['params']?.toString();

          if (pageName != null) {
            debugPrint('[JsonNavigator] Restoring to page: $pageName');
            _restoreAppStateSync(pageName, paramsJson);
          } else {
            debugPrint('[JsonNavigator] No page in state');
            _handleInvalidState();
          }
        } else {
          debugPrint('[JsonNavigator] Invalid state');
          _handleInvalidState();
        }
      } catch (e) {
        debugPrint('[JsonNavigator] PopState error: $e');
        _handleInvalidState();
      }
    });
  }

  static void _restoreAppStateSync(String pageName, String? paramsJson) {
    try {
      final page = _nameToPage[pageName];
      if (page != null) {
        _clearParams();

        if (paramsJson != null && paramsJson.isNotEmpty) {
          try {
            final params = jsonDecode(paramsJson) as Map<String, dynamic>;
            _setParams(params);
            debugPrint('[JsonNavigator] Restored params: $params');
          } catch (e) {
            debugPrint('[JsonNavigator] Failed to parse params: $e');
          }
        }

        _currentPage = page;
        _currentPageNotifier.value = page;
        _lastRestoredPage = page;

        debugPrint('[JsonNavigator] Restored to: $pageName${paramsJson != null ? ' with params' : ''}');
      }
    } catch (e) {
      debugPrint('[JsonNavigator] RestoreAppStateSync error: $e');
    }
  }

  static void _handleInvalidState() {
    final targetPage = _lastRestoredPage ?? _currentPage;
    if (targetPage == null) return;

    debugPrint('[JsonNavigator] Redirecting to ${targetPage.name}');
    _currentPage = targetPage;
    _currentPageNotifier.value = targetPage;

    final params = getParams();
    final stateData = {
      'flutter': true,
      'page': targetPage.name,
      if (params.isNotEmpty) 'params': jsonEncode(params),
    };
    debugPrint('[JsonNavigator] ReplaceState with: $stateData');
    html.window.history.replaceState(stateData, '', '/');
    _saveLastPage(targetPage.name, params);
  }

  static void _setInitialBrowserState() {
    try {
      final lastPageData = html.window.sessionStorage['lastPage'];
      if (lastPageData != null && lastPageData.isNotEmpty) {
        debugPrint('[JsonNavigator] sessionStorage already has data, skipping');
        return;
      }

      if (_currentPage == null) return;

      final params = getParams();
      final stateData = {
        'flutter': true,
        'page': _currentPage!.name,
        if (params.isNotEmpty) 'params': jsonEncode(params),
      };
      debugPrint('[JsonNavigator] Setting initial state: $stateData');
      html.window.history.replaceState(stateData, '', '/');
      _saveLastPage(_currentPage!.name, params);
    } catch (e) {
      debugPrint('[JsonNavigator] SetInitialBrowserState error: $e');
    }
  }

  static void _saveLastPage(String pageName, Map<String, dynamic> params) {
    try {
      final data = {
        'page': pageName,
        'params': params,
      };
      html.window.sessionStorage['lastPage'] = jsonEncode(data);
      debugPrint('[JsonNavigator] Saved to sessionStorage: $data');
    } catch (e) {
      debugPrint('[JsonNavigator] Save last page error: $e');
    }
  }

  static void _restoreLastPage() {
    try {
      // 브라우저 history state를 먼저 확인
      final currentState = html.window.history.state;
      if (currentState != null && currentState is Map && currentState['flutter'] == true) {
        final pageName = currentState['page']?.toString();
        final paramsJson = currentState['params']?.toString();

        if (pageName != null) {
          final page = _nameToPage[pageName];
          if (page != null) {
            if (paramsJson != null && paramsJson.isNotEmpty) {
              try {
                final params = jsonDecode(paramsJson) as Map<String, dynamic>;
                _setParams(params);
                debugPrint('[JsonNavigator] Restored params from history.state: $params');
              } catch (e) {
                debugPrint('[JsonNavigator] Failed to parse params from history.state: $e');
              }
            }
            _currentPage = page;
            _currentPageNotifier.value = page;
            _lastRestoredPage = page;

            // sessionStorage도 업데이트
            _saveLastPage(pageName, getParams());

            debugPrint('[JsonNavigator] Restored from history.state: $pageName');
            return;
          }
        }
      }

      // Fallback: sessionStorage에서 복원
      final lastPageData = html.window.sessionStorage['lastPage'];
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
                debugPrint('[JsonNavigator] Restored params from sessionStorage: $params');
              }
              _currentPage = page;
              _currentPageNotifier.value = page;
              _lastRestoredPage = page;

              debugPrint('[JsonNavigator] Restored from sessionStorage: $pageName');
              return;
            }
          }
        } catch (e) {
          debugPrint('[JsonNavigator] Failed to parse sessionStorage data: $e');
        }
      }

      debugPrint('[JsonNavigator] No restore data');
    } catch (e) {
      debugPrint('[JsonNavigator] Restore last page error: $e');
    }
  }
}
