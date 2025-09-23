# Changelog

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
