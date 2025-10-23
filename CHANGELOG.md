# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
