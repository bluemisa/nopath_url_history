# NoPath URL History

A Flutter Web navigation library that uses browser history API without changing URLs. Perfect for single-page applications that need complex navigation with JSON parameters while keeping the URL fixed.

[![pub package](https://img.shields.io/pub/v/nopath_url_history.svg)](https://pub.dev/packages/nopath_url_history)
[![Live Demo](https://img.shields.io/badge/demo-live-success)](https://bluemisa.github.io/nopath_url_history/)

**[🚀 Try Live Demo](https://bluemisa.github.io/nopath_url_history/)**

## Features

- **Fixed URL Navigation**: URL stays at `/` while navigation works perfectly
- **Complex JSON Parameters**: Pass entire objects between pages without URL encoding
- **Browser Back Button**: Full support for browser back button navigation
- **Browser Forward Button**: Full support for browser forward button navigation
- **Page Refresh Support**: Maintains current page and parameters even after refresh (F5)
- **State Persistence**: Uses browser History API and SessionStorage for reliable state management
- **Type-Safe**: Enum-based page definitions prevent typos
- **Simple API**: Easy to integrate and use with minimal setup

## Why NoPath URL History?

Traditional Flutter Web routing changes URLs (`/home`, `/profile`, `/settings`), which can lead to:
- Security concerns with exposed URL structures
- Complex URL encoding for parameters
- Difficulty handling complex nested objects
- Unwanted direct URL access

NoPath URL History solves these problems by:
- Keeping URL fixed at `/`
- Storing navigation state in browser History API
- Supporting full JSON objects as parameters
- Maintaining browser navigation UX

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  nopath_url_history: ^0.1.0
```

Then run:
```bash
flutter pub get
```

## Quick Start

### Step 1: Define Your Pages

```dart
enum AppPage {
  home,
  profile,
  settings,
}
```

### Step 2: Initialize Before runApp() ⭐

```dart
void main() {
  // ⭐ REQUIRED: Initialize JsonNavigator BEFORE runApp()
  JsonNavigator.initialize<AppPage>(
    pages: [
      PageConfig(AppPage.home, () => const HomePage()),
      PageConfig(AppPage.profile, () => const ProfilePage()),
      PageConfig(AppPage.settings, () => const SettingsPage()),
    ],
    initialPage: AppPage.home,
  );

  runApp(const MyApp());
}
```

### Step 3: Use the Wrapper Widget ⭐

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: const JsonNavigatorWrapper(), // ⭐ REQUIRED: Use wrapper
    );
  }
}
```

### Step 4: Navigate & Get Parameters ⭐

```dart
// ⭐ Navigate WITHOUT parameters
JsonNavigator.navigateTo('profile');

// ⭐ Navigate WITH JSON parameters (complex objects supported!)
JsonNavigator.navigateToWithParams('profile', {
  'userId': 123,
  'settings': {
    'theme': 'dark',
    'notifications': true,
  },
  'tags': ['developer', 'flutter'],
});

// ⭐ Get parameters in destination page
final params = JsonNavigator.getParams();
final userId = params['userId'];
final theme = params['settings']['theme'];

// ⭐ Browser back/forward navigation
JsonNavigator.goBack();
JsonNavigator.goForward();
```

> **💡 Pro Tip**: Page names are strings (`'profile'`, `'home'`) that match your enum names. The enum is only for type-safe configuration!

## Complete Example

Here's a full working example showing all the key features:

```dart
import 'package:flutter/material.dart';
import 'package:nopath_url_history/nopath_url_history.dart';

// 1️⃣ Define your pages as an enum
enum AppPage { home, details }

void main() {
  // 2️⃣ ⭐ Initialize BEFORE runApp()
  JsonNavigator.initialize<AppPage>(
    pages: [
      PageConfig(AppPage.home, () => const HomePage()),
      PageConfig(AppPage.details, () => const DetailsPage()),
    ],
    initialPage: AppPage.home,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NoPath URL History Demo',
      home: const JsonNavigatorWrapper(), // 3️⃣ ⭐ Use the wrapper
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // 4️⃣ ⭐ Navigate WITH parameters (page name as string)
            JsonNavigator.navigateToWithParams('details', {
              'title': 'Product Details',
              'price': 99.99,
              'inStock': true,
              'features': ['Feature 1', 'Feature 2'],
            });
          },
          child: const Text('Go to Details with Data'),
        ),
      ),
    );
  }
}

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 5️⃣ ⭐ Get parameters from previous page
    final params = JsonNavigator.getParams();

    return Scaffold(
      appBar: AppBar(
        title: Text(params['title'] ?? 'Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => JsonNavigator.goBack(), // 6️⃣ ⭐ Browser back
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Price: \$${params['price']}'),
            Text('In Stock: ${params['inStock']}'),
            const SizedBox(height: 20),
            Text('Features: ${params['features']?.join(", ")}'),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => JsonNavigator.goForward(), // ⭐ Browser forward
              child: const Text('Forward'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 🎯 What This Example Shows:

| Feature | Code Example | Description |
|---------|--------------|-------------|
| **Initialization** | `JsonNavigator.initialize<AppPage>(...)` | Must be called before `runApp()` |
| **Wrapper Widget** | `JsonNavigatorWrapper()` | Automatically displays current page |
| **Navigate with Params** | `navigateToWithParams('details', {...})` | Pass complex JSON objects |
| **Get Params** | `JsonNavigator.getParams()` | Retrieve data in destination |
| **Browser Back** | `JsonNavigator.goBack()` | Navigate to previous page |
| **Browser Forward** | `JsonNavigator.goForward()` | Navigate to next page |

### 💡 Key Takeaways:

✅ **Enum for Type Safety**: `AppPage` enum prevents typos during setup
✅ **String for Navigation**: Use `'home'`, `'details'` when navigating
✅ **No URL Encoding**: Pass objects directly as Dart Maps
✅ **Browser Buttons Work**: Back/forward buttons function automatically
✅ **Refresh Persistence**: State survives page refresh (F5)

## API Reference

### JsonNavigator

#### `initialize<T extends Enum>`
Initialize the navigator with page configurations.

```dart
JsonNavigator.initialize<AppPage>(
  pages: [
    PageConfig(AppPage.home, () => const HomePage()),
    // ... more pages
  ],
  initialPage: AppPage.home,
);
```

#### `navigateTo(String pageName)`
Navigate to a page without parameters.

```dart
JsonNavigator.navigateTo('home');
```

#### `navigateToWithParams(String pageName, Map<String, dynamic> params)`
Navigate to a page with JSON parameters.

```dart
JsonNavigator.navigateToWithParams('profile', {
  'userId': 123,
  'data': { /* complex object */ },
});
```

#### `getParams()`
Get parameters of the current page.

```dart
final params = JsonNavigator.getParams();
```

#### `goBack()`
Navigate to the previous page.

```dart
JsonNavigator.goBack();
```

#### `goForward()`
Navigate to the next page.

```dart
JsonNavigator.goForward();
```

#### `currentPageName`
Get the current page name.

```dart
final pageName = JsonNavigator.currentPageName;
```

### PageConfig

Configuration class for defining pages.

```dart
PageConfig(AppPage.home, () => const HomePage())
```

### JsonNavigatorWrapper

Wrapper widget that automatically displays the current page.

```dart
home: const JsonNavigatorWrapper()
```

## How It Works

This library achieves URL-free navigation while maintaining browser features through a clever combination of web APIs:

### 1. URL Strategy Override
Uses a custom `NoOpUrlStrategy` that extends `HashUrlStrategy` and overrides all URL-changing methods:
- `prepareExternalUrl()` always returns `#/`
- `pushState()`, `replaceState()`, and `go()` are all no-ops
- This completely prevents Flutter from modifying the browser URL

### 2. History State Storage
Stores navigation data directly in the browser's History API:
```javascript
window.history.pushState({
  flutter: true,
  page: 'pageName',
  params: '{"key": "value"}'
}, '', '/');
```
This allows the back/forward buttons to work without changing the URL.

### 3. SessionStorage Backup
Uses `window.sessionStorage` as a secondary storage:
- Stores last page and parameters
- Survives page refreshes (F5)
- Cleared when tab/browser is closed
- Acts as a fallback when history.state is unavailable

### 4. PopState Event Listener
Listens to `window.onPopState` events to detect browser navigation:
- Captures back button clicks
- Captures forward button clicks
- Restores the correct page and parameters from history.state
- Prevents Flutter's default navigation behavior

### 5. ValueNotifier for UI Updates
Uses Flutter's `ValueNotifier<Enum?>` pattern:
- Triggers UI rebuilds when page changes
- `JsonNavigatorWrapper` listens to this notifier
- Automatically displays the correct page widget
- Efficient, reactive UI updates

## Platform Support

- ✅ Web (Chrome, Safari, Firefox, Edge)
- ❌ Mobile (iOS, Android)
- ❌ Desktop (Windows, macOS, Linux)

This library is **Web-only** and will throw an `UnsupportedError` on non-web platforms.

## Use Cases

### Perfect For:
- **Admin Dashboards**: Hide internal URL structure from users and prevent direct URL sharing
- **Internal Tools**: Employee-only applications where URL access control is needed
- **Complex State Transfer**: Applications that need to pass large objects or nested data between screens
- **Single Page Apps**: Traditional SPA behavior where URL doesn't matter
- **Secure Applications**: Apps where exposing route structure could be a security concern

### Real-World Examples:
- Company admin panel with sensitive page names
- CRM systems with complex filtering/search states
- Data analysis tools with multiple visualization states
- Internal workflow management tools
- Employee scheduling and management systems

## Important Notes & Limitations

### ⚠️ Before You Use

**This library is designed for specific use cases. Make sure it fits your needs:**

✅ **Use this library if:**
- You want to hide your URL structure
- You don't need shareable URLs
- You don't need deep linking
- Your app is internal/private
- You need to pass complex JSON between pages

❌ **Don't use this library if:**
- You need SEO (search engine optimization)
- Users need to share/bookmark specific pages
- You need deep linking from external sources
- You want traditional web navigation behavior
- Your app needs to be crawled by search engines

### Technical Limitations

1. **Web-Only**: Only works on Flutter Web. Will throw `UnsupportedError` on mobile/desktop platforms.

2. **Fixed URL**: URL is always fixed at `/` or `#/`. You cannot have different URLs for different pages.

3. **No Deep Linking**: Users cannot directly navigate to a specific page by entering a URL.

4. **SessionStorage Dependency**: State is stored in browser's sessionStorage:
   - Lost when the browser tab is closed
   - Lost when user clears browser data
   - Not shared between browser tabs

5. **Same-Tab Only**: Each browser tab has independent navigation state. Opening a new tab starts fresh.

6. **Not SEO-Friendly**: Since URL doesn't change, search engines cannot index individual pages.

### Initialization Requirements

- Must call `JsonNavigator.initialize()` before `runApp()`
- Can only initialize once per application lifecycle
- All pages must be registered during initialization
- Initial page is required

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

Created for internal tools and admin dashboards that need flexible navigation without URL exposure.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.
