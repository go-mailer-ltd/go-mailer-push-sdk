# Go Mailer SDK

[![Build Status](https://github.com/go-mailer-ltd/go-mailer-push-sdk/actions/workflows/ci.yml/badge.svg)](https://github.com/go-mailer-ltd/go-mailer-push-sdk/actions)
[![JitPack](https://jitpack.io/v/go-mailer-ltd/go-mailer-push-sdk.svg)](https://jitpack.io/#go-mailer-ltd/go-mailer-push-sdk)
[![CocoaPods](https://img.shields.io/cocoapods/v/GoMailerPushSDK.svg)](https://cocoapods.org/pods/GoMailerPushSDK)
[![Pub Version](https://img.shields.io/pub/v/go_mailer_push_sdk)](https://pub.dev/packages/go_mailer_push_sdk)
[![npm version](https://img.shields.io/npm/v/go-mailer)](https://www.npmjs.com/package/go-mailer)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A cross-platform mobile SDK for customer engagement messaging that enables businesses to receive push notifications from the Go-Mailer platform in their mobile apps.

## Features

- **Cross-Platform Support**: iOS, Android, Flutter, and React Native
- **Push Notification Registration**: Registers device and user with Go-Mailer backend
- **Notification Handling**: Receives and displays push notifications sent from the Go-Mailer platform
- **Analytics**: Tracks notification delivery, opens, and user events
- **Security & Privacy**: End-to-end encryption for message delivery, API key masking, email masking
- **Reliability Layer**: Persistent offline event queue with backoff + jitter, queue capacity protection, structured event stream

## How It Works

1. **SDK Integration**: Businesses integrate the Go-Mailer SDK into their mobile apps.
2. **Device Registration**: The SDK registers the device and user with the Go-Mailer backend.
3. **Message Sending**: Businesses use the Go-Mailer web platform to send messages to their users. The Go-Mailer backend delivers these as push notifications to registered devices.
4. **Notification Handling**: The SDK receives and displays notifications, and can report analytics/events back to the Go-Mailer backend.

## Supported Platforms

- **iOS**: Native Swift/Objective-C SDK
- **Android**: Native Kotlin/Java SDK
- **Flutter**: Dart plugin for Flutter apps
- **React Native**: JavaScript/TypeScript wrapper

## Quick Start

### iOS (Swift)
```swift
import GoMailer

// Initialize the SDK
GoMailer.initialize(apiKey: "your-api-key")

// Register for push notifications
GoMailer.registerForPushNotifications()

// Set the current user
let user = GoMailerUser(email: "user-email")
GoMailer.setUser(user)
```

### Android (Kotlin)
```kotlin
import com.gomailer.GoMailer

// Initialize the SDK
GoMailer.initialize(context, "your-api-key")

// Register for push notifications
GoMailer.registerForPushNotifications()

// Set the current user
val user = GoMailerUser(email = "user-email")
GoMailer.setUser(user)
```

### Flutter (Dart)
```dart
import 'package:go_mailer/go_mailer.dart';

// Initialize the SDK
await GoMailer.initialize(apiKey: 'your-api-key');

// Register for push notifications
await GoMailer.registerForPushNotifications();

// Set the current user
final user = GoMailerUser(email: 'user-email');
await GoMailer.setUser(user);
```

### React Native (JavaScript)
```javascript
import GoMailer from 'go-mailer';

// Initialize the SDK
await GoMailer.initialize({ apiKey: 'your-api-key' });

// Register for push notifications
await GoMailer.registerForPushNotifications();

// Set the current user
await GoMailer.setUser({ email: 'user-email' });
```

## Installation

### iOS (CocoaPods)
```ruby
target 'YourAppTarget' do
  pod 'GoMailerPushSDK', '~> 1.3.0'
end
```

Then:
```bash
pod install
```

After installation import and initialize:
```swift
import GoMailer

GoMailer.initialize(apiKey: "your-api-key")
```

### Android (JitPack)
Add JitPack repository and dependency (group uses GitHub style):
```gradle
// settings.gradle or dependencyResolutionManagement
maven { url 'https://jitpack.io' }

// module build.gradle
implementation 'com.github.go-mailer-ltd:go-mailer-push-sdk:1.3.0'
```

### Flutter
```yaml
# Add to pubspec.yaml
dependencies:
  go_mailer_push_sdk: ^1.3.0
```

### React Native

## Current Release Versions

| Platform | Version |
|----------|---------|
| Flutter Plugin | 1.3.0 |
| Android Library | 1.3.0 |
| iOS (CocoaPods) | 1.3.0 |
| React Native Package | 1.3.0 |

## Reliability & Privacy Highlights (v1.3.0)

- Structured event taxonomy (initialized, stream_ready, registered, event_queued, event_tracked, event_failed, event_dropped, notification_clicked)
- Persistent queue (SharedPreferences / UserDefaults) with capacity cap (100) + drop signaling
- Exponential backoff with jitter for network operations
- API key & email masking; additional maskedEmail field in analytics payloads
- Diagnostic API: getSdkInfo for runtime verification

## Manual Publishing (Summary)

See `scripts/release.sh` for pre-flight checks. Summary steps:

1. Tag & push: `git tag -a v1.3.0 -m "Go Mailer SDK 1.3.0" && git push origin v1.3.0`
2. Flutter publish: `(cd sdk/flutter && dart pub publish)`
3. Android (JitPack) — no action needed beyond tagging; consumers pull via JitPack.
4. React Native: `(cd sdk/react-native && npm publish --access public)`
5. iOS standalone pod: `(cd sdk/ios && pod trunk push GoMailerPushSDK.podspec --allow-warnings)`

For CI automation, see `.github/workflows/ci.yml` and create a separate publish workflow gating on tags.

```bash
npm install go-mailer
# or
yarn add go-mailer
```

## Configuration

- **API Keys**: Get your API key from the Go-Mailer dashboard and initialize the SDK with it.
- **Push Notification Setup**: Follow platform-specific setup guides for push notification certificates and configuration.

## Documentation

- [Getting Started Guide](./docs/getting-started.md) - Complete integration guide
- [API Reference](./docs/api-reference.md) - Complete SDK documentation
- [Platform Setup Guides](./docs/platform-setup/) - Platform-specific installation and configuration
  - [iOS Setup](./docs/platform-setup/ios-setup.md)
  - [Android Setup](./docs/platform-setup/android-setup.md)
  - [Flutter Setup](./docs/platform-setup/flutter-setup.md)
  - [React Native Setup](./docs/platform-setup/react-native-setup.md)

## License

MIT License - see [LICENSE](LICENSE) for details. 