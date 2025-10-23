import 'package:flutter/material.dart';
import 'package:nopath_url_history/nopath_url_history.dart';
import 'screens/a_page.dart';
import 'screens/b_page.dart';
import 'screens/c_page.dart';

// 1️⃣ Define your pages as an enum (right in main.dart!)
enum AppPage { a, b, c }

void main() {
  // ⭐ REQUIRED: Initialize JsonNavigator BEFORE runApp()
  JsonNavigator.initialize<AppPage>(
    pages: [
      PageConfig(AppPage.a, () => const APage()),
      PageConfig(AppPage.b, () => const BPage()),
      PageConfig(AppPage.c, () => const CPage()),
    ],
    initialPage: AppPage.a,
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
      home: const JsonNavigatorWrapper(), // ⭐ REQUIRED: Use JsonNavigatorWrapper
    );
  }
}
