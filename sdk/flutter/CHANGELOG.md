# Changelog

## [1.3.0] - 2025-10-02
### Added
- iOS parity: structured event stream, retry/backoff, pre-token queue.
- Persistent disk-backed event queue (Android SharedPreferences, iOS UserDefaults).
- Queue size cap (100 events) with oldest-drop policy emitting `event_dropped`.
- `getSdkInfo()` Dart helper returning version/baseUrl/email/deviceToken.
- Added `event_dropped` event type (data includes `event` & `reason`).
- Basic email masking in logs + added `maskedEmail` field in network payload.

### Changed
- Version bumps across native layers to 1.3.0.
- Reliability docs updated to reflect persistence & parity.

### Fixed
- Potential unbounded memory growth from queued events pre-token.

### Migration
- No API breaking changes. Optional new method: `GoMailer.getSdkInfo()`.

### Notes
- Default queue limit is 100 events; customize planned for future release.

## [1.2.0] - 2025-10-02
### Added
- Android: EventChannel now emits structured SDK lifecycle & tracking events (`initialized`, `stream_ready`, `registered`, `token_failed`, `event_queued`, `event_tracked`, `event_failed`).
- Android: Exponential backoff with jitter for device token & event submission (retries on 429 & 5xx + network errors).
- Android: In-memory pre-token event queue + `flushPendingEvents()` Dart API.
- Dart: `GoMailer.flushPendingEvents()` helper.

### Changed
- Networking on Android migrated to OkHttp + Coroutines for reliability & timeouts.
- Standardized Android minimum SDK requirement at 23 (Firebase Messaging alignment).

### Known Gaps / Roadmap
- iOS parity for the structured event stream & retry/queue layer planned for a future release.
- Persistent (disk) event queue not yet implemented; current queue is in-memory.

### Migration
- If you previously targeted Android API < 23 you must raise your app minSdkVersion.
- No breaking API changes; all new capabilities are additive.

## [1.1.0] - 2025-01-23

### Added
- **Multi-environment support**: Choose between production, staging, and development environments
- `GoMailerEnvironment` enum with predefined endpoints
- `environment` parameter in `GoMailerConfig` for easy environment switching
- `getEnvironmentFromUrl()` helper function for debugging
- Backward compatibility with explicit `baseUrl` configuration

### Changed
- **Default endpoint**: Now defaults to production (`https://api.go-mailer.com/v1`)
- Enhanced README with environment configuration examples

### Migration Guide
- Existing code continues to work without changes
- To use environments: `GoMailerConfig(environment: GoMailerEnvironment.staging)`
- Legacy ngrok URLs automatically upgrade to production

## [1.0.0] - 2024-09-23

### Added
- Initial release of Go Mailer Push SDK for Flutter
- Cross-platform support for iOS and Android push notifications
- Device registration with Go-Mailer backend
- User identification and management
- Notification permission handling
- Notification click tracking
- Custom event tracking
- APNs support for iOS
- FCM support for Android
- TypeScript-like API with comprehensive error handling
- Production-ready default endpoints
- Configurable logging levels

### Features
- `GoMailer.initialize()` - Initialize SDK with API key
- `GoMailer.setUser()` - Identify users for targeted messaging
- `GoMailer.requestNotificationPermission()` - Request notification permissions
- `GoMailer.checkNotificationPermission()` - Check permission status
- `GoMailer.trackNotificationClick()` - Track notification interactions
- `GoMailer.trackEvent()` - Track custom events
- `GoMailer.getDeviceToken()` - Get device push token

### Technical
- Flutter plugin architecture with platform channels
- Native iOS implementation in Swift
- Native Android implementation in Kotlin
- Firebase Cloud Messaging integration
- Apple Push Notification service integration
- Secure API communication with Go-Mailer backend
- Comprehensive error handling and logging