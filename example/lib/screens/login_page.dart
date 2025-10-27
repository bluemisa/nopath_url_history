import 'package:flutter/material.dart';
import 'package:nopath_url_history/nopath_url_history.dart';
import '../demo_globals.dart';
import '../main.dart';
import '../widgets/demo_top_actions.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // No deep-link forward in this demo: login always lands on A

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Required'),
        backgroundColor: Colors.red,
        actions: const [DemoTopActions()],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'This page is protected by a demo auth guard.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ValueListenableBuilder<bool>(
                  valueListenable: DemoGlobals.isLoggedIn,
                  builder: (context, loggedIn, _) => Card(
                    color: loggedIn ? Colors.green.shade50 : Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(
                                loggedIn
                                    ? Icons.verified_user
                                    : Icons.lock_outline,
                                color: loggedIn ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                loggedIn
                                    ? 'Logged in (demo)'
                                    : 'Not logged in',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              // Toggle remains for quick testing
                              Switch.adaptive(
                                value: loggedIn,
                                onChanged: (v) => DemoGlobals.setLogin(v),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'In this demo, logging in always takes you to A.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        if (!DemoGlobals.isLoggedIn.value) {
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              const SnackBar(
                                content: Text('Login required. Please sign in.'),
                                behavior: SnackBarBehavior.floating,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          return;
                        }
                        JsonNavigator.navigateToEnum(AppPage.a);
                      },
                      icon: const Icon(Icons.home_outlined),
                      label: const Text('Go to A'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Login button: enable login and go to A (replace to avoid back to login)
                        DemoGlobals.setLogin(true);
                        JsonNavigator.replaceToEnum(AppPage.a);
                      },
                      icon: const Icon(Icons.login),
                      label: const Text('Login and go to A (replaceToEnum)'),
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

// DemoTopActions moved to widgets/demo_top_actions.dart to avoid circular imports
