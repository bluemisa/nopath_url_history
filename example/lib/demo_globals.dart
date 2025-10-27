import 'package:flutter/foundation.dart';
import 'package:nopath_url_history/nopath_url_history.dart';
// For Flutter Web cookie access (persist login across refresh)
// Using dart:html here to avoid extra deps in the example app.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Global demo state (auth + logging) for the example app
class DemoGlobals {
  static final ValueNotifier<bool> isLoggedIn = ValueNotifier<bool>(false);
  static final ValueNotifier<bool> loggingEnabled =
      ValueNotifier<bool>(kDebugMode);

  static const String _authCookieName = 'nopath_demo_auth';
  static const int _oneYearSeconds = 60 * 60 * 24 * 365;

  /// Call early (e.g., at app start) to restore persisted state.
  static void init() {
    // Restore auth from cookie
    final persisted = _readAuthCookie();
    isLoggedIn.value = persisted;

    // Ensure logging flag syncs with library on startup
    JsonNavigator.setLoggingEnabled(loggingEnabled.value);
  }

  static void toggleLogin() {
    isLoggedIn.value = !isLoggedIn.value;
  }

  static void setLogin(bool value) {
    isLoggedIn.value = value;
    _writeAuthCookie(value);
  }

  static void setLogging(bool value) {
    loggingEnabled.value = value;
    JsonNavigator.setLoggingEnabled(value);
  }

  static void toggleLogging() {
    setLogging(!loggingEnabled.value);
  }

  // --- Cookie helpers ---
  static bool _readAuthCookie() {
    try {
      final cookie = html.document.cookie ?? '';
      if (cookie.isEmpty) return false;
      for (final part in cookie.split(';')) {
        final p = part.trim();
        if (p.startsWith('$_authCookieName=')) {
          final val = p.substring(_authCookieName.length + 1);
          return val == '1' || val.toLowerCase() == 'true';
        }
      }
    } catch (_) {
      // Ignore read errors; default to logged out
    }
    return false;
  }

  static void _writeAuthCookie(bool loggedIn) {
    try {
      final val = loggedIn ? '1' : '0';
      // Persist for 1 year, limit to path=/, lax default is fine for demo
      html.document.cookie =
          '$_authCookieName=$val; max-age=$_oneYearSeconds; path=/; SameSite=Lax';
    } catch (_) {
      // Ignore write errors; in worst case state won't persist
    }
  }
}
