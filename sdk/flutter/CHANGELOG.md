# Changelog

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