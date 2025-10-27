import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nopath_url_history/nopath_url_history.dart';
import '../main.dart'; // Import for AppPage enum
import '../widgets/demo_top_actions.dart';

class CPage extends StatelessWidget {
  const CPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ⭐ Get parameters from previous page
    final params = JsonNavigator.getParams();

    // ⭐ Get current page as typed enum
    final currentPage = JsonNavigator.currentPageAs<AppPage>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('C Page'),
        backgroundColor: Colors.orange,
        actions: const [DemoTopActions()],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'C Page',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Page Info (Typed API):',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('currentPageAs<AppPage>() = ${currentPage?.name}'),
                        Text('Type: ${currentPage.runtimeType}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Removed String API display; using typed API exclusively in example
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Params from B:'),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(jsonEncode(params)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Test replaceTo() - replaces history without adding new entry:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  color: Colors.orange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Instructions:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        const Text('1. Click "Replace to A" below',
                            style: TextStyle(fontSize: 12)),
                        const Text('2. Press browser Back button',
                            style: TextStyle(fontSize: 12)),
                        const Text(
                            '3. You should skip C and go to B (C was replaced!)',
                            style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => JsonNavigator.navigateToEnum(
                          AppPage.a), // ⭐ Navigate (adds to history)
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Navigate to A (adds to history)'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => JsonNavigator.replaceToEnum(
                          AppPage.a), // ⭐ Replace with enum
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange),
                      icon: const Icon(Icons.swap_horiz),
                      label: const Text('Replace to A (no history)'),
                    ),
                    ElevatedButton(
                      onPressed: JsonNavigator.goBack, // ⭐ Browser back
                      child: const Text('Back'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
