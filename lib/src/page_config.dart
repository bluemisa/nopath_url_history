import 'package:flutter/widgets.dart';

/// Navigation guard decision for a page.
/// - allow: proceed to the target page
/// - redirect: go to another page (optionally with params, default using replace)
class GuardDecision<T extends Enum> {
  final bool allow;
  final T? to;
  final Map<String, dynamic> params;
  final bool replace;

  const GuardDecision._(this.allow, this.to, this.params, this.replace);

  const GuardDecision.allow() : this._(true, null, const {}, true);

  const GuardDecision.redirect(
    T to, {
    Map<String, dynamic> params = const {},
    bool replace = true,
  }) : this._(false, to, params, replace);
}

/// Page-specific middleware
typedef PageMiddleware<T extends Enum> = GuardDecision<T> Function(
  Map<String, dynamic> params,
);

/// Page configuration class
class PageConfig<T extends Enum> {
  final T page;
  final Widget Function() builder;
  final PageMiddleware<T>? middleware;

  const PageConfig(this.page, this.builder, [this.middleware]);
}
