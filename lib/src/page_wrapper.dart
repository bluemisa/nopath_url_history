import 'package:flutter/material.dart';
import 'json_navigator.dart';

/// Page wrapper widget - Automatically displays current page
class JsonNavigatorWrapper extends StatelessWidget {
  const JsonNavigatorWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Enum?>(
      valueListenable: JsonNavigator.currentPageNotifier,
      builder: (context, page, _) {
        if (page == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return _buildPage(page);
      },
    );
  }

  Widget _buildPage(Enum page) {
    final widget = JsonNavigator.getPageWidget(page);

    if (widget == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Page "${page.name}" is not registered',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Please register this page using JsonNavigator.initialize()'),
            ],
          ),
        ),
      );
    }

    return widget;
  }
}
