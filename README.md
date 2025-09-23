# Go Mailer SDK

A cross-platform mobile SDK for customer engagement messaging that enables businesses to receive push notifications from the Go-Mailer platform in their mobile apps.

## Features

- **Cross-Platform Support**: iOS, Android, Flutter, and React Native
- **Push Notification Registration**: Registers device and user with Go-Mailer backend
- **Notification Handling**: Receives and displays push notifications sent from the Go-Mailer platform
- **Analytics**: Tracks notification delivery, opens, and user events
- **Security**: End-to-end encryption for message delivery

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

### iOS
```bash
# Using CocoaPods
pod 'GoMailer'

# Using Swift Package Manager
dependencies: [
    .package(url: "https://github.com/your-org/go-mailer-ios.git", from: "1.0.0")
]
```

### Android
```gradle
// Add to build.gradle
implementation 'com.gomailer:go-mailer:1.0.0'
```

### Flutter
```yaml
# Add to pubspec.yaml
dependencies:
  go_mailer: ^1.0.0
```

### React Native
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