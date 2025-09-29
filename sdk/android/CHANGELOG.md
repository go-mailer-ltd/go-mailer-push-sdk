# Changelog

All notable changes to the Go Mailer Push SDK for Android will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2025-01-23

### Added
- **Multi-environment support**: Choose between production, staging, and development environments
- `GoMailerEnvironment` enum with predefined endpoints (PRODUCTION, STAGING, DEVELOPMENT)
- `environment` parameter in `GoMailerConfig` for easy environment switching
- `GoMailerEnvironment.fromUrl()` helper method for debugging
- `getEffectiveBaseUrl()` method in `GoMailerConfig`
- Backward compatibility with explicit `baseUrl` configuration

### Changed
- **Default endpoint**: Now defaults to production (`https://api.go-mailer.com/v1`)
- Enhanced README with environment configuration examples
- Improved logging shows active environment and endpoint

### Migration Guide
- Existing code continues to work without changes
- To use environments: `GoMailerConfig(environment = GoMailerEnvironment.STAGING)`
- Legacy ngrok URLs automatically upgrade to production

## [1.0.1] - 2025-01-23

### Added
- Initial release of Go Mailer Push SDK for Android
- Device registration with Go-Mailer backend
- User identification and data synchronization
- Push notification permission handling
- Notification click tracking
- Firebase Cloud Messaging (FCM) integration
- Production-ready endpoint configuration
- Comprehensive error handling and logging
- Support for Android API 16+ (Android 4.1+)

### Features
- `GoMailer.initialize()` - Initialize SDK with API key
- `GoMailer.setUser()` - Identify users for targeted messaging
- `GoMailer.trackNotificationClick()` - Track notification interactions
- `GoMailer.trackEvent()` - Custom event tracking
- `GoMailer.getDeviceToken()` - Get FCM device token for debugging

### Technical Details
- Written in Kotlin with full Android integration
- Supports Firebase Cloud Messaging (FCM)
- Uses OkHttp for reliable network requests
- Kotlin Coroutines for async operations
- Minimum SDK: API 16 (Android 4.1)
- Target SDK: API 34 (Android 14)

## [Unreleased]

### Planned
- Enhanced notification customization options
- Offline message queuing
- Advanced analytics and reporting
- Rich media notification support
