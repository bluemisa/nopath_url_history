import 'package:flutter/widgets.dart';

/// Page configuration class
class PageConfig<T extends Enum> {
  final T page;
  final Widget Function() builder;

  const PageConfig(this.page, this.builder);
}
