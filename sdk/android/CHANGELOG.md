# Changelog

All notable changes to the Go Mailer Push SDK for Android will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.0] - 2025-10-02

### Added
- Persistent disk-backed event queue (SharedPreferences) with 100 event cap & oldest drop policy (`event_dropped`).
- Parity with iOS for retry/backoff & pre-token queue semantics.
- `getSdkInfo` method when accessed via Flutter plugin.

### Changed
- Version bump to 1.3.0.

### Fixed
- Potential unbounded queue growth before token registration.

## [1.1.0] - 2025-01-23
## [1.2.0] - 2025-10-02

### Added
- Structured EventChannel interoperability (when used via Flutter plugin) emitting: `initialized`, `stream_ready`, `registered`, `register_failed`, `token_failed`, `event_queued`, `event_tracked`, `event_failed`, `notification_clicked`.
- Exponential backoff with jitter for device token and event submission (retries on 429 & 5xx + network errors).
- In-memory pre-token event queue with manual flush API (`flushPendingEvents`).

### Changed
- Replaced raw HttpURLConnection logic with OkHttp + Coroutines for consistent timeout & retry control.
- Standardized minimum supported Android API level to 23 (Firebase Messaging alignment).
- Dynamic bundleId extraction from application context.

### Known Limitations
- Event queue is in-memory only (not persisted across process restarts).

### Migration
- Raise your application `minSdkVersion` to 23 if still below.
- No breaking API changes; all new capabilities are additive.

---

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
