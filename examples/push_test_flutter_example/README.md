# Go Mailer Flutter Example

This is a complete example Flutter app demonstrating how to integrate the **Go Mailer Push SDK** for receiving push notifications.

## 🚀 What This Example Shows

- ✅ Installing the published `go_mailer_push_sdk` from pub.dev
- ✅ Initializing the SDK with your API key
- ✅ Setting user data for targeted messaging
- ✅ Requesting notification permissions
- ✅ Registering for push notifications (FCM/APNs)
- ✅ Getting device tokens for debugging
- ✅ Tracking custom events
- ✅ Handling background messages
- ✅ Complete step-by-step flow

## 📦 Package Used

This example uses the **published pub.dev package**:
```yaml
dependencies:
  go_mailer_push_sdk: ^1.0.0
```

## 🛠 Setup Instructions

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Configure Firebase (Required)

**Android:**
- Add your `google-services.json` to `android/app/`
- Ensure `build.gradle` files are properly configured

**iOS:**
- Add your `GoogleService-Info.plist` to `ios/Runner/`
- Run `cd ios && pod install`

### 3. Update API Key

In `lib/main.dart`, replace the API key with your actual Go-Mailer API key:
```dart
const apiKey = 'your-actual-api-key-here';
```

### 4. Run the App

**Android:**
```bash
flutter run -d android
```

**iOS:**
```bash
flutter run -d ios
```

## 📱 How to Use

### 🚀 **Recommended: Complete Flow**
1. **Enter Email** - Input the user's email address
2. **Tap "Test Complete Flow"** - This will:
   - Send user data to Go-Mailer backend
   - Register for push notifications
   - Get device token
   - Track sample events

### 📋 **Alternative: Step by Step**
1. **Send User Data** - Send user info to backend
2. **Request Notification Permission** - Enable push notifications
3. **Track Sample Events** - Send custom events

## 🔧 Key Integration Points

### SDK Initialization
```dart
import 'package:go_mailer_push_sdk/go_mailer.dart';

await GoMailer.initialize(
  apiKey: 'your-api-key',
  config: GoMailerConfig(
    // baseUrl defaults to production endpoint
    enableAnalytics: true,
    logLevel: GoMailerLogLevel.debug,
  ),
);
```

### User Registration
```dart
final user = GoMailerUser(email: 'user@example.com');
await GoMailer.setUser(user);
```

### Push Notification Registration
```dart
await GoMailer.registerForPushNotifications(email: 'user@example.com');
```

### Event Tracking
```dart
await GoMailer.trackEvent(
  eventName: 'button_clicked',
  properties: {
    'button_name': 'subscribe',
    'source': 'flutter_app'
  },
);
```

### Background Message Handling
```dart
// Background message handler (already configured)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📱 Background message received: ${message.notification?.title}');
  // The native GoMailerFirebaseMessagingService handles display and tracking
}

// Register the handler
FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
```

## 📊 Status Indicators

The app shows real-time status for:
- ✅ **User Data**: Whether user info was sent to backend
- ✅ **Notifications**: Whether push notifications were requested
- ✅ **Event Tracking**: Whether event tracking is available

## 🔍 Debugging

- Check the console logs for detailed SDK operation info
- Use the "Test Complete Flow" button for end-to-end testing
- Status indicators show current state of each feature
- Device token is logged when available

## 🔧 Firebase Configuration

### Android (`android/app/build.gradle`)
```gradle
dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-messaging'
}
```

### iOS (automatically configured via CocoaPods)
```ruby
# ios/Podfile - automatically included
pod 'Firebase/Messaging'
```

## 📚 More Information

- [Go Mailer Push SDK on pub.dev](https://pub.dev/packages/go_mailer_push_sdk)
- [Flutter Setup Guide](../../docs/platform-setup/flutter-setup.md)
- [Firebase Flutter Setup](https://firebase.google.com/docs/flutter/setup)

---

**Go-Mailer** - Customer engagement messaging platform  
[go-mailer.com](https://go-mailer.com)