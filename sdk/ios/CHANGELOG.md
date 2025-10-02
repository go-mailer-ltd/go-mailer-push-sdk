# Changelog

## [1.3.0] - 2025-10-02

### Added
- Structured event stream & retry/backoff parity with Android.
- Pre-token event queue persisted to disk (UserDefaults) with 100 event cap (drops oldest -> `event_dropped`).
- `getSdkInfo` parity via Flutter bridge.

### Changed
- Version synchronized to 1.3.0 across platforms.

### Fixed
- Potential lost events on cold start before token registration (now restored & flushed after registration).

## [1.1.0] - 2025-01-23

### Added
- **Multi-environment support**: Choose between production, staging, and development environments
- `GoMailerEnvironment` enum with predefined endpoints
- `environment` parameter in `GoMailerConfig` for easy environment switching
- Convenience initializer: `GoMailerConfig(environment: .staging)`
- `GoMailerEnvironment.from(url:)` helper method for debugging
- Backward compatibility with explicit `baseURL` configuration

### Changed
- **Default endpoint**: Now defaults to production (`https://api.go-mailer.com/v1`)
- Enhanced README with environment configuration examples
- Improved logging shows active environment and endpoint

### Migration Guide
- Existing code continues to work without changes
- To use environments: `GoMailerConfig(environment: .staging)`
- Legacy ngrok URLs automatically upgrade to production

## [1.0.0] - 2024-09-23

### Added
- Initial release of Go Mailer Push SDK for iOS
- Native iOS push notification support via APNs
- Device registration with Go-Mailer backend
- User identification and management
- Notification permission handling
- Notification click tracking
- Custom event tracking
- Swift-native implementation with comprehensive error handling
- Production-ready default endpoints
- Configurable logging levels

### Features
- `GoMailer.setup()` - Initialize SDK with API key
- `GoMailer.setUser()` - Identify users for targeted messaging
- `GoMailer.requestNotificationPermission()` - Request notification permissions
- `GoMailer.hasNotificationPermission()` - Check permission status
- `GoMailer.trackNotificationClick()` - Track notification interactions
- `GoMailer.trackEvent()` - Track custom events
- `GoMailer.getDeviceToken()` - Get device push token

### Technical
- Native Swift implementation
- Apple Push Notification service integration
- UNUserNotificationCenter integration
- Secure API communication with Go-Mailer backend
- Comprehensive error handling and logging
- iOS 10.0+ support
- Swift 5.0+ compatibility

### Integration
- Simple AppDelegate integration
- Automatic device token handling
- Background notification support
- Foreground notification presentation
- Click tracking via UNUserNotificationCenterDelegate
