# Go Mailer SDK API Reference

## Overview

The Go Mailer SDK enables your mobile app to receive push notifications and analytics from the Go-Mailer customer engagement platform. All message sending is initiated from the Go-Mailer web platform/backend. The SDK is responsible for device registration, user registration, push notification handling, and analytics.

## Table of Contents

1. [Initialization](#initialization)
2. [User & Device Registration](#user--device-registration)
3. [Push Notification Handling](#push-notification-handling)
4. [Analytics](#analytics)
5. [Configuration](#configuration)
6. [Error Handling](#error-handling)

## Initialization

### iOS (Swift)

```swift
import GoMailer

// Basic initialization
GoMailer.initialize(apiKey: "your-api-key")

// With custom configuration
let config = GoMailerConfig()
config.baseUrl = "https://staging-api.gomailer.com/v1"
config.enableAnalytics = true
config.logLevel = .debug

GoMailer.initialize(apiKey: "your-api-key", config: config)
```

### Android (Kotlin)

```kotlin
import com.gomailer.GoMailer

// Basic initialization
GoMailer.initialize(context, "your-api-key")

// With custom configuration
val config = GoMailerConfig(
    baseUrl = "https://staging-api.gomailer.com/v1",
    enableAnalytics = true,
    logLevel = GoMailerLogLevel.DEBUG
)
GoMailer.initialize(context, "your-api-key", config)
```

### Flutter (Dart)

```dart
import 'package:go_mailer/go_mailer.dart';

// Basic initialization
await GoMailer.initialize(apiKey: 'your-api-key');

// With custom configuration
final config = GoMailerConfig(
  baseUrl: 'https://staging-api.gomailer.com/v1',
  enableAnalytics: true,
  logLevel: GoMailerLogLevel.debug,
);
await GoMailer.initialize(apiKey: 'your-api-key', config: config);
```

### React Native (TypeScript)

```typescript
import GoMailer from 'go-mailer';

// Basic initialization
await GoMailer.initialize({ apiKey: 'your-api-key' });

// With custom configuration
await GoMailer.initialize({
  apiKey: 'your-api-key',
  baseUrl: 'https://staging-api.gomailer.com/v1',
  enableAnalytics: true,
  logLevel: GoMailerLogLevel.DEBUG,
});
```

## User & Device Registration

Register the current user and device with the Go-Mailer backend. This enables the platform to target push notifications to the correct device. **Important**: The user's email is automatically sent to the backend along with the device token during registration.

### iOS (Swift)

```swift
let user = GoMailerUser(email: "example@acme.com")
GoMailer.setUser(user)
GoMailer.registerForPushNotifications()
```

### Android (Kotlin)

```kotlin
val user = GoMailerUser(email = "example@acme.com")
GoMailer.setUser(user)
GoMailer.registerForPushNotifications()
```

### Flutter (Dart)

```dart
final user = GoMailerUser(email: 'example@acme.com');
await GoMailer.setUser(user);
await GoMailer.registerForPushNotifications(email: user.email);
```

### React Native (TypeScript)

```typescript
await GoMailer.setUser({ email: 'example@acme.com' });
await GoMailer.registerForPushNotifications('example@acme.com');
```

### Registration Flow

1. **Set User**: Call `setUser()` with the user's email and other information
2. **Register for Push**: Call `registerForPushNotifications()` to request permission and get device token
3. **Automatic Backend Registration**: The SDK automatically sends both the device token and user email to the backend
4. **Backend Association**: The backend associates the device token with the user's email for targeted notifications

**Note**: Always call `setUser()` before `registerForPushNotifications()` to ensure the email is available when the device token is sent to the backend.

## Push Notification Handling

The SDK automatically handles push notification registration and receipt. When a notification is received from the Go-Mailer platform, the SDK displays it and can trigger in-app events or analytics.

### iOS/Android/Flutter/React Native
- The SDK manages device token registration and updates.
- Notifications sent from the Go-Mailer platform are delivered to the app and displayed.
- You can listen for notification events (e.g., notification opened) and handle them in your app if needed.

## Analytics

The SDK can report analytics events (e.g., notification received, opened) back to the Go-Mailer backend.

### Example
```swift
GoMailer.trackEvent("notification_opened", properties: ["notificationId": "abc123"])
```

```kotlin
GoMailer.trackEvent("notification_opened", mapOf("notificationId" to "abc123"))
```

```dart
await GoMailer.trackEvent(eventName: 'notification_opened', properties: {'notificationId': 'abc123'});
```

```typescript
await GoMailer.trackEvent('notification_opened', { notificationId: 'abc123' });
```

## Configuration

- **API Key**: Required for SDK initialization.
- **Base URL**: (Optional) Override the default Go-Mailer API endpoint.
- **Analytics**: Enable or disable analytics reporting.

## Error Handling

The SDK provides error codes for initialization, registration, and analytics reporting. All message delivery is handled by the Go-Mailer backend.

## Best Practices

- Initialize the SDK as early as possible in your app lifecycle.
- Register the user and device after login or on app start.
- Do not attempt to send messages from the SDK; all messaging is managed by the Go-Mailer platform.
- Handle notification events as needed for your app's UX.

## Platform-Specific Notes

- **iOS**: Requires push notification capabilities and APNs setup.
- **Android**: Requires Firebase Cloud Messaging setup.
- **Flutter/React Native**: Follows native platform requirements. 

## Backend API Endpoints

The Go-Mailer SDK communicates with the backend using the following endpoints:

- **POST /v1/contacts** - Register device token and user information
- **POST /v1/push/send** - Send push notifications (backend only)
- **GET /v1/health/status** - Health check

### Device Registration Payload

When registering a device token, the SDK sends the following payload to `/v1/contacts`:

```json
{
  "email": "user@example.com",
  "gm_mobi_push": {
    "deviceToken": "device_token_here",
    "platform": "ios|android|flutter|react-native",
    "appVersion": "1.0.0",
    "deviceInfo": {
      "model": "iPhone 14",
      "osVersion": "16.0"
    }
  }
}
```

**Note**: The `email` field is required and must be set before calling `registerForPushNotifications()`. The SDK automatically includes this email when sending the device token to the backend. 