# Changelog

All notable changes to the Go Mailer SDK project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-XX

### Added
- **Initial release of Go Mailer SDK**
- **Cross-platform push notifications** for iOS, Android, Flutter, and React Native
- **Automatic notification click tracking** with comprehensive analytics
- **User data management** with support for attributes, tags, and segmentation
- **Production-ready architecture** with proper error handling and logging
- **Complete documentation** with platform-specific setup guides

### Features by Platform

#### Flutter SDK
- ✅ Cross-platform plugin with native iOS/Android modules
- ✅ Automatic Firebase integration for push notifications
- ✅ Background message handling support
- ✅ TypeScript-style configuration with GoMailerConfig
- ✅ Comprehensive error handling with GoMailerException

#### React Native SDK
- ✅ Native module package with full TypeScript support
- ✅ Automatic linking for React Native 0.60+
- ✅ iOS and Android native modules included
- ✅ Event listeners for push notification events
- ✅ Metro configuration support

#### iOS SDK
- ✅ Native Swift framework with CocoaPods support
- ✅ Automatic notification click detection via UNUserNotificationCenter
- ✅ APNs integration with custom notification ID support
- ✅ SwiftUI and UIKit compatibility
- ✅ Comprehensive delegate pattern implementation

#### Android SDK
- ✅ Native Kotlin library with Gradle integration
- ✅ Firebase Cloud Messaging (FCM) integration
- ✅ Manual notification click tracking via Intent detection
- ✅ ProGuard/R8 compatibility
- ✅ Background service support

### Technical Features
- **API Endpoints**: Production endpoint `https://api.go-mailer.com/v1`
- **Device Token Management**: Automatic registration to `/contacts` endpoint
- **Event Tracking**: Notification clicks sent to `/events/push` endpoint
- **Payload Format**: Go-Mailer specific format with `gm_mobi_push` structure
- **Error Handling**: Comprehensive error management across all platforms
- **Logging**: Configurable log levels (Debug, Info, Warning, Error)
- **Version Consistency**: All SDKs use version 1.0.0

### Supported Capabilities
1. ✅ **API Key Registration** - Secure SDK initialization
2. ✅ **User Data Management** - Email, attributes, tags, custom properties
3. ✅ **Push Notification Permissions** - Automatic permission requests
4. ✅ **Device Token Synchronization** - Automatic server registration
5. ✅ **Notification Click Tracking** - Comprehensive analytics with custom IDs

### Platform Requirements
- **Flutter**: Flutter 3.0.0+, Dart 2.17.0+
- **React Native**: React Native 0.60.0+, Node.js 16+
- **iOS**: iOS 12.0+, Xcode 14.0+, Swift 5.0+
- **Android**: API Level 24+, Android Studio 4.0+, Kotlin 1.7.0+

### Documentation
- **Complete setup guides** for all platforms
- **API reference** with method documentation
- **Code examples** for common use cases
- **Troubleshooting guides** with common issues and solutions
- **Production deployment** checklist and best practices

### Package Distribution
- **Flutter**: Available on [pub.dev](https://pub.dev/packages/go_mailer)
- **React Native**: Available on [npm](https://www.npmjs.com/package/go-mailer)
- **iOS**: Available on [CocoaPods](https://cocoapods.org/pods/GoMailer)
- **Android**: Available on [Maven Central](https://search.maven.org/artifact/com.gomailer/go-mailer)

---

## Future Roadmap

### Planned for v1.1.0
- [ ] Enhanced analytics with custom event properties
- [ ] Rich push notification support (images, actions)
- [ ] A/B testing integration
- [ ] Advanced user segmentation features
- [ ] Performance optimizations

### Planned for v1.2.0
- [ ] Web SDK support
- [ ] Real-time messaging capabilities
- [ ] Enhanced debugging tools
- [ ] Advanced notification scheduling

---

## Migration Guide

### From Development to v1.0.0
If you were using development versions, update your endpoints:
- Old: `https://419c321798d9.ngrok-free.app/v1`
- New: `https://api.go-mailer.com/v1`

The SDKs automatically handle this migration, but update your configuration for clarity.

---

## Support

- **Documentation**: [docs.go-mailer.com](https://docs.go-mailer.com)
- **GitHub Issues**: [github.com/go-mailer/go-mailer-mobile-push/issues](https://github.com/go-mailer/go-mailer-mobile-push/issues)
- **Email Support**: support@gomailer.com

---

**Thank you for using Go Mailer SDK!** 🚀
