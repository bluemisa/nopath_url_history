import 'package:flutter/material.dart';
import 'package:nopath_url_history/nopath_url_history.dart';
import 'screens/a_page.dart';
import 'screens/b_page.dart';
import 'screens/c_page.dart';
import 'screens/login_page.dart';
import 'demo_globals.dart';

// 1️⃣ Define your pages as an enum (right in main.dart!)
enum AppPage { login, a, b, c }

void main() {
  // Restore persisted demo state (e.g., login cookie) before init
  DemoGlobals.init();
  // ⭐ REQUIRED: Initialize JsonNavigator BEFORE runApp()
  JsonNavigator.initialize<AppPage>(
    pages: [
      PageConfig(AppPage.login, () => const LoginPage()),
      PageConfig(AppPage.a, () => const APage()),
      // Protect B and C with a simple auth guard
      PageConfig(
        AppPage.b,
        () => const BPage(),
        (params) => DemoGlobals.isLoggedIn.value
            ? const GuardDecision.allow()
            : GuardDecision.redirect(
                AppPage.login,
                replace: true,
              ),
      ),
      PageConfig(
        AppPage.c,
        () => const CPage(),
        (params) => DemoGlobals.isLoggedIn.value
            ? const GuardDecision.allow()
            : GuardDecision.redirect(
                AppPage.login,
                replace: true,
              ),
      ),
    ],
    // Start on Login page regardless of auth state
    initialPage: AppPage.login,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'URL History Navigation Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home:
          const JsonNavigatorWrapper(), // ⭐ REQUIRED: Use JsonNavigatorWrapper
    );
  }
}
