# Go Mailer Push SDK for Flutter

[![pub package](https://img.shields.io/pub/v/go_mailer_push_sdk.svg)](https://pub.dev/packages/go_mailer_push_sdk)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Receive push notifications sent by Go-Mailer in your Flutter app. This SDK handles device registration, user identification, and notification interaction tracking - **Go-Mailer takes care of sending the notifications**.

## What This SDK Does

- 📱 **Registers your app** to receive push notifications from Go-Mailer
- 👤 **Identifies users** so Go-Mailer knows who to send notifications to  
- 📊 **Tracks interactions** when users tap notifications
- 🔧 **Simple Integration** - just call our helper functions at the right time
- 📱 **Cross-Platform** - works on both iOS and Android

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  go_mailer_push_sdk: ^1.0.0
```

Then run:
```bash
flutter pub get
```

### iOS Setup

1. Enable Push Notifications capability in Xcode
2. Configure APNs certificates in your Apple Developer account
3. The SDK handles APNs registration automatically

### Android Setup

1. Add Firebase to your Flutter project
2. Place `google-services.json` in `android/app/`
3. The SDK handles FCM registration automatically

## Quick Start

**Step 1: Initialize** (call once when your app starts)
```dart
import 'package:go_mailer_push_sdk/go_mailer.dart';

await GoMailer.initialize(
  apiKey: 'your-go-mailer-api-key',
);
```

**Step 2: Identify the user** (call when user logs in or you know their email)
```dart
await GoMailer.setUser({
  'email': 'user@example.com',
  // Add any other user properties you want Go-Mailer to know about
});
```

**Step 3: Request permission** (call when appropriate in your UX flow)
```dart
bool granted = await GoMailer.requestNotificationPermission();
if (granted) {
  // User will now receive notifications sent by Go-Mailer
}
```

**Step 4: Track clicks** (call when a notification opens your app)
```dart
// Go-Mailer includes notification_id in every notification payload
await GoMailer.trackNotificationClick('notification-id-from-payload');
```

**That's it!** Go-Mailer will handle sending notifications to your users.

## Complete API Reference

### 1. Initialize the SDK
```dart
await GoMailer.initialize(
  apiKey: 'your-go-mailer-api-key',
  logLevel: GoMailerLogLevel.info, // optional
);
```
Call this once when your app starts. **Required before using any other methods.**

### 2. Identify Users
```dart
await GoMailer.setUser({
  'email': 'user@example.com',
  'firstName': 'John',
  'lastName': 'Doe',
  // ... any other user properties
});
```
Tell Go-Mailer who this user is so we can send them targeted notifications.

### 3. Handle Permissions
```dart
// Request permission to show notifications
bool granted = await GoMailer.requestNotificationPermission();

// Check current permission status
bool hasPermission = await GoMailer.checkNotificationPermission();
```
iOS requires explicit permission. Android grants it automatically in most cases.

### 4. Track Notification Interactions
```dart
// When user taps a notification and opens your app
await GoMailer.trackNotificationClick('notification-id-from-payload');
```
**Important:** Go-Mailer includes a `notification_id` in every notification we send. Extract this from the payload and pass it to this method.

### 5. Optional: Custom Event Tracking
```dart
// Track custom user actions (optional)
await GoMailer.trackEvent('button_clicked', {
  'button_name': 'subscribe'
});
```

### 6. Get Device Information
```dart
// Get the device token (for debugging)
String? token = await GoMailer.getDeviceToken();
```

## How Go-Mailer Sends Notifications

**You don't need to worry about sending notifications** - Go-Mailer handles this for you! When we send notifications to your users, we include a `notification_id` that you'll need to extract and use for tracking clicks.

### What the notification payload looks like (for reference):

**iOS:**
```json
{
  "aps": {
    "alert": {
      "title": "Hello from Go-Mailer!",
      "body": "Your notification message"
    }
  },
  "notification_id": "abc123",
  "your_custom_data": "any_value"
}
```

**Android:**
```json
{
  "notification": {
    "title": "Hello from Go-Mailer!",
    "body": "Your notification message"
  },
  "data": {
    "notification_id": "abc123",
    "your_custom_data": "any_value"
  }
}
```

**Your job:** Extract the `notification_id` and call `GoMailer.trackNotificationClick(notification_id)` when the user taps the notification.

## Troubleshooting

### Common Issues

**"SDK not initialized"**
- Make sure you call `GoMailer.initialize()` before any other methods

**"Permission denied" on iOS**
- iOS requires explicit permission. Call `requestNotificationPermission()`
- Check your app's notification settings in iOS Settings

**"Notifications not received"**
- Verify your Firebase setup (Android) or APNs certificates (iOS)
- Check that `setUser()` was called with a valid email
- Ensure Go-Mailer has your correct push certificates/keys

**"Click tracking not working"**
- Make sure you're extracting `notification_id` from the payload correctly
- Call `trackNotificationClick()` when the notification opens your app, not when it's received

## Example Implementation

```dart
import 'package:flutter/material.dart';
import 'package:go_mailer_push_sdk/go_mailer.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialize on app start
    _initializeGoMailer();
  }

  Future<void> _initializeGoMailer() async {
    await GoMailer.initialize(apiKey: 'your-api-key');
  }

  Future<void> _handleLogin(String email) async {
    // Identify user after login
    await GoMailer.setUser({'email': email});
    
    // Request permission at the right moment
    bool granted = await GoMailer.requestNotificationPermission();
    if (granted) {
      print('User will receive Go-Mailer notifications');
    }
  }

  // Handle notification clicks (implementation depends on your navigation)
  Future<void> _handleNotificationClick(Map<String, dynamic> data) async {
    final notificationId = data['notification_id'];
    if (notificationId != null) {
      await GoMailer.trackNotificationClick(notificationId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Your app content
    );
  }
}
```

## Requirements

- Flutter >= 2.0.0
- Dart >= 2.12.0
- iOS 10.0+ / Android API level 16+
- Valid Go-Mailer account and API key

## Need Help?

- 📖 [Complete Documentation](https://docs.go-mailer.com/flutter)
- 💬 [Support](https://docs.go-mailer.com/support)
- 🐛 [Report Issues](https://github.com/go-mailer/go-mailer-flutter/issues)

---

**Go-Mailer** - Customer engagement messaging platform  
[go-mailer.com](https://go-mailer.com)