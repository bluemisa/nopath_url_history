import 'package:flutter_web_plugins/flutter_web_plugins.dart';

/// NoOp URL Strategy - Completely bypasses Flutter's default routing
class NoOpUrlStrategy extends HashUrlStrategy {
  @override
  String prepareExternalUrl(String internalUrl) {
    return '#/';
  }

  @override
  String getPath() {
    return '/';
  }

  @override
  Object? getState() {
    return null;
  }

  @override
  void pushState(Object? state, String title, String url) {
    // Ignore Flutter's pushState
  }

  @override
  void replaceState(Object? state, String title, String url) {
    // Ignore Flutter's replaceState
  }

  @override
  Future<void> go(int count) async {
    // Ignore Flutter's go
  }
}
