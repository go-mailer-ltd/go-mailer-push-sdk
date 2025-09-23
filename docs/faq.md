# Frequently Asked Questions

## General Questions

### What is the Go Mailer SDK?
The Go Mailer SDK is a cross-platform mobile SDK that enables businesses to receive push notifications from the Go-Mailer customer engagement platform in their mobile apps. It supports iOS, Android, Flutter, and React Native.

### How does the SDK work?
1. **Integration**: Businesses integrate the SDK into their mobile apps
2. **Registration**: The SDK registers the device and user with Go-Mailer backend
3. **Messaging**: Businesses send messages from the Go-Mailer web platform
4. **Delivery**: Messages are delivered as push notifications to registered devices
5. **Analytics**: The SDK tracks delivery, opens, and user events

### What platforms are supported?
- **iOS**: Native Swift/Objective-C SDK
- **Android**: Native Kotlin/Java SDK  
- **Flutter**: Dart plugin for Flutter apps
- **React Native**: JavaScript/TypeScript wrapper

### Is the SDK free to use?
The SDK is open source and free to use. However, you'll need a Go-Mailer account to send push notifications. Check our [pricing page](https://gomailer.com/pricing) for account details.

## Technical Questions

### What are the minimum requirements?
- **iOS**: iOS 13.0+, Xcode 14.0+
- **Android**: API level 21+, Android Studio Arctic Fox+
- **Flutter**: Flutter 3.0.0+, Dart 2.17.0+
- **React Native**: Node.js 16.0.0+, React Native 0.70.0+

### Do I need a Firebase project?
- **Android**: Yes, Firebase Cloud Messaging is required
- **iOS**: No, Apple Push Notification Service (APNs) is used
- **Flutter/React Native**: Yes, Firebase is required for cross-platform support

### How do I get my API key?
1. Sign up for a Go-Mailer account at [gomailer.com](https://gomailer.com)
2. Navigate to the Developer section in your dashboard
3. Generate a new API key for your mobile app
4. Copy the API key for SDK initialization

### Can I use a custom API endpoint?
Yes, you can configure a custom API endpoint for testing or staging environments:

```swift
// iOS
let config = GoMailerConfig()
config.baseUrl = "https://staging-api.gomailer.com/v1"
GoMailer.initialize(apiKey: "your-api-key", config: config)
```

```kotlin
// Android
val config = GoMailerConfig(
    baseUrl = "https://staging-api.gomailer.com/v1"
)
GoMailer.initialize(context, "your-api-key", config)
```

```dart
// Flutter
final config = GoMailerConfig(
  baseUrl: 'https://staging-api.gomailer.com/v1',
);
await GoMailer.initialize(apiKey: 'your-api-key', config: config);
```

```javascript
// React Native
const config = {
  apiKey: 'your-api-key',
  baseUrl: 'https://staging-api.gomailer.com/v1',
};
await GoMailer.initialize(config);
```

## Integration Questions

### How do I handle user login/logout?
```swift
// iOS - Set user on login
let user = GoMailerUser(email: "user@example.com")
GoMailer.setUser(user)

// Clear user on logout
GoMailer.clearUser()
```

```kotlin
// Android - Set user on login
val user = GoMailerUser(email = "user@example.com")
GoMailer.setUser(user)

// Clear user on logout
GoMailer.clearUser()
```

```dart
// Flutter - Set user on login
final user = GoMailerUser(email: 'user@example.com');
await GoMailer.setUser(user);

// Clear user on logout
await GoMailer.clearUser();
```

```javascript
// React Native - Set user on login
await GoMailer.setUser({ email: 'user@example.com' });

// Clear user on logout
await GoMailer.clearUser();
```

### Can I send push notifications from my app?
No, the Go Mailer SDK is designed to receive push notifications, not send them. Push notifications are sent from the Go-Mailer web platform/backend. This ensures:

- **Security**: Only authorized users can send messages
- **Compliance**: Messages follow platform guidelines
- **Analytics**: Centralized tracking and reporting
- **Scalability**: Efficient message delivery infrastructure

### How do I test push notifications?
1. **Build and run** your app on a physical device
2. **Grant permissions** when prompted for push notifications
3. **Go to Go-Mailer dashboard** and navigate to Push Notifications
4. **Send a test notification** to your device
5. **Verify** the notification appears

### What happens if the user denies push notification permissions?
If the user denies push notification permissions:
- The SDK will still initialize
- Device registration will fail
- No push notifications will be received
- You can request permissions again later

### Can I customize notification appearance?
Yes, you can customize notification appearance through platform-specific configuration:

- **iOS**: Use notification service extensions
- **Android**: Configure notification channels and styles
- **Flutter/React Native**: Use local notification plugins

## Analytics and Tracking

### What analytics are tracked?
The SDK automatically tracks:
- **Device registration** success/failure
- **User registration** success/failure
- **Push notification delivery**
- **Notification opens**
- **App launch from notifications**

### Can I disable analytics?
Yes, you can disable analytics in the configuration:

```swift
// iOS
let config = GoMailerConfig()
config.enableAnalytics = false
GoMailer.initialize(apiKey: "your-api-key", config: config)
```

```kotlin
// Android
val config = GoMailerConfig(
    enableAnalytics = false
)
GoMailer.initialize(context, "your-api-key", config)
```

```dart
// Flutter
final config = GoMailerConfig(
  enableAnalytics: false,
);
await GoMailer.initialize(apiKey: 'your-api-key', config: config);
```

```javascript
// React Native
const config = {
  apiKey: 'your-api-key',
  enableAnalytics: false,
};
await GoMailer.initialize(config);
```

### How do I access analytics data?
Analytics data is available in your Go-Mailer dashboard:
1. Log in to your Go-Mailer account
2. Navigate to the Analytics section
3. View delivery rates, open rates, and user engagement metrics

## Troubleshooting

### My app crashes on startup
Common causes and solutions:
1. **Missing dependencies**: Ensure all required packages are installed
2. **Incorrect API key**: Verify your API key is correct
3. **Network issues**: Check internet connectivity
4. **Platform setup**: Verify platform-specific configuration

### Push notifications aren't working
Check these common issues:
1. **Permissions**: Ensure push notification permissions are granted
2. **Platform setup**: Verify iOS/Android configuration
3. **Firebase setup**: Check Firebase project configuration
4. **Device registration**: Verify device is registered with Go-Mailer

### How do I enable debug logging?
Enable debug logging to get more detailed information:

```swift
// iOS
let config = GoMailerConfig()
config.logLevel = .debug
GoMailer.initialize(apiKey: "your-api-key", config: config)
```

```kotlin
// Android
val config = GoMailerConfig(
    logLevel = GoMailerLogLevel.DEBUG
)
GoMailer.initialize(context, "your-api-key", config)
```

```dart
// Flutter
final config = GoMailerConfig()
  ..logLevel = GoMailerLogLevel.debug;
await GoMailer.initialize(apiKey: 'your-api-key', config: config);
```

```javascript
// React Native
const config = {
  apiKey: 'your-api-key',
  logLevel: 'debug',
};
await GoMailer.initialize(config);
```

## Support and Community

### Where can I get help?
- **Documentation**: [Getting Started Guide](./getting-started.md)
- **API Reference**: [Complete SDK documentation](./api-reference.md)
- **Platform Setup**: [Platform-specific guides](./platform-setup/)
- **Troubleshooting**: [Common issues and solutions](./troubleshooting.md)
- **Support**: Email support@gomailer.com
- **GitHub**: [Issues and discussions](https://github.com/your-org/go-mailer-mobile-push)

### How do I report a bug?
1. Check if the issue is already reported
2. Enable debug logging and collect logs
3. Create a new GitHub issue with:
   - Platform and SDK version
   - Steps to reproduce
   - Error logs and screenshots
   - Device and OS information

### Can I contribute to the SDK?
Yes! We welcome contributions:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

### Where can I find examples?
Check our [examples directory](../../examples/) for sample applications:
- iOS native app example
- Android native app example
- Flutter app example
- React Native app example

## Still Have Questions?

If you can't find the answer here:
1. Check our [comprehensive documentation](./getting-started.md)
2. Search [GitHub issues](https://github.com/your-org/go-mailer-mobile-push/issues)
3. Contact support at support@gomailer.com
4. Join our [community discussions](https://github.com/your-org/go-mailer-mobile-push/discussions) 