# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.2] - 2025-10-27

### Added
- `JsonNavigator.replaceTo()` - Replace current page without adding to history (perfect for login flows)
- `onPageChange` callback parameter in `initialize()` - Get notified when page changes
- `enableLogging` parameter in `initialize()` - Control debug logging (defaults to `kDebugMode`)
- **Type-safe Enum-based APIs** - New typed navigation methods for compile-time safety
  - `navigateToEnum<T>(T page)` - Navigate using enum without parameters
  - `navigateToEnumWithParams<T>(T page, Map<String, dynamic> params)` - Navigate using enum with parameters
  - `replaceToEnum<T>(T page, {Map<String, dynamic>? params})` - Replace current page using enum
  - `currentPageAs<T>()` - Get current page as typed enum value
- **Page Middleware/Guard System** - Protect pages with authentication and authorization guards
  - `GuardDecision<T>` class for navigation guard decisions (allow/redirect)
  - `PageMiddleware<T>` typedef for page-level guard functions
  - Optional middleware parameter in `PageConfig` constructor (3rd positional argument)
  - Guards run on all navigation methods (navigate, replace, back/forward, refresh)

### Features
- `replaceTo`/`replaceToEnum` ideal for authentication flows - prevents users from navigating back to login page after successful login
- onPageChange callback is now triggered on all navigation methods (navigateTo, navigateToWithParams, replaceTo, and browser back/forward)
- Compile-time type checking prevents navigation errors with typed APIs
- IDE auto-completion support for type-safe page navigation
- Runtime validation ensures enum type consistency
- Throws `StateError` when accessed with incorrect enum type
- Logging can be disabled in production by setting `enableLogging: false`
- Full backward compatibility - String-based APIs still work
- **Middleware features:**
  - Redirect chains up to 8 hops (prevents infinite loops)
  - `GuardDecision.redirect()` defaults to `replace: true` to avoid leaving protected pages in history
  - Guards evaluated during popstate (browser back/forward) and page restoration
  - Perfect for authentication, authorization, and conditional navigation

### Fixed
- `onPageChange` callback is now properly triggered during page restoration (refresh, back/forward navigation)
- Fixed issue where refreshing the page wouldn't restore the correct page state in callback

### Validation Improvements
- `initialPage` is now validated to be in the registered pages list
- Empty pages list now throws `ArgumentError` during initialization

### Documentation
- Updated README with Typed API examples
- Enhanced example app to use Typed APIs exclusively (String APIs deprecated in examples)
- Added comprehensive replaceTo behavior tests in example app
- Added comprehensive middleware usage example with authentication guard pattern
- Documented GuardDecision.allow() and GuardDecision.redirect() patterns
- Included best practices to avoid redirect loops
- Example app demonstrates type-safe navigation patterns

### Package Improvements
- Added `platforms: web` to pubspec.yaml for proper pub.dev platform declaration
- Updated .pubignore to exclude pubspec.lock for library packages

## [0.1.1] - 2025-10-23

### Fixed
- Replaced deprecated `dart:html` with `package:web` and `dart:js_interop`
- Fixed code formatting issues to meet pub.dev standards
- Updated all browser API calls to use the new web package API

## [0.1.0] - 2025-10-23

### Added
- Initial release of NoPath URL History
- `JsonNavigator` class for managing navigation without URL changes
- `PageConfig` class for page configuration
- `JsonNavigatorWrapper` widget for automatic page display
- `NoOpUrlStrategy` to bypass Flutter's default routing
- Support for JSON parameters in navigation
- Browser back/forward button support
- State persistence using History API and SessionStorage
- Enum-based type-safe page definitions
- Automatic state restoration on page refresh

### Features
- `JsonNavigator.initialize()` - Initialize navigator with pages
- `JsonNavigator.navigateTo()` - Navigate without parameters
- `JsonNavigator.navigateToWithParams()` - Navigate with JSON parameters
- `JsonNavigator.getParams()` - Get current page parameters
- `JsonNavigator.goBack()` - Browser back navigation
- `JsonNavigator.goForward()` - Browser forward navigation
- `JsonNavigator.currentPageName` - Get current page name

### Documentation
- Comprehensive README.md with examples
- API reference documentation
- Quick start guide
- Complete example application

## [Unreleased]

### Planned
- Additional helper methods for parameter validation
- Optional query parameter support
- Navigation guards/middleware
- Enhanced error handling
- Performance optimizations
