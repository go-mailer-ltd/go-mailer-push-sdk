# Flutter SDK Setup Guide

This guide will walk you through integrating the Go Mailer SDK into your Flutter application.

## 📋 Prerequisites

- Flutter 3.0.0 or higher
- Dart 2.17.0 or higher
- Go-Mailer API key
- Firebase project (for push notifications)

## 🔧 Installation Steps

### Step 1: Add Dependency

Add the Go Mailer SDK to your `pubspec.yaml`:

```yaml
dependencies:
  go_mailer: ^1.0.0  # From pub.dev when published
  # OR for local development:
  # go_mailer:
  #   path: ../path/to/sdk/flutter
```

Run:
```bash
flutter pub get
```

### Step 2: Firebase Setup

#### Android Firebase Setup

1. **Create Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Create a new project or use existing one
   - Add Android app with your package name (from `android/app/build.gradle`)

2. **Download Configuration**
   - Download `google-services.json`
   - Place it in `android/app/google-services.json`

3. **Update Build Files**

   **`android/build.gradle`:**
   ```gradle
   buildscript {
     dependencies {
       classpath 'com.google.gms:google-services:4.3.15'
     }
   }
   ```

   **`android/app/build.gradle`:**
   ```gradle
   apply plugin: 'com.google.gms.google-services'

   dependencies {
     implementation platform('com.google.firebase:firebase-bom:32.7.0')
     implementation 'com.google.firebase:firebase-messaging'
   }
   ```

#### iOS Firebase Setup

1. **Add iOS App to Firebase**
   - In Firebase Console, add iOS app
   - Use Bundle ID from `ios/Runner.xcodeproj`

2. **Download Configuration**
   - Download `GoogleService-Info.plist`
   - Add to `ios/Runner/` directory in Xcode

3. **Update AppDelegate**

   **`ios/Runner/AppDelegate.swift`:**
   ```swift
   import UIKit
   import Flutter
   import Firebase

   @UIApplicationMain
   @objc class AppDelegate: FlutterAppDelegate {
     override func application(
       _ application: UIApplication,
       didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
     ) -> Bool {
       FirebaseApp.configure()
       GeneratedPluginRegistrant.register(with: self)
       return super.application(application, didFinishLaunchingWithOptions: launchOptions)
     }
   }
   ```

### Step 3: Platform Permissions

#### iOS Permissions

1. **Enable Capabilities in Xcode:**
   - Open `ios/Runner.xcworkspace`
   - Select Runner target → Signing & Capabilities
   - Add "Push Notifications" capability
   - Add "Background Modes" → Check "Background processing"

2. **Update Info.plist (Optional):**
   ```xml
   <!-- ios/Runner/Info.plist -->
   <key>UIBackgroundModes</key>
   <array>
     <string>background-processing</string>
   </array>
   ```

#### Android Permissions

**`android/app/src/main/AndroidManifest.xml`:**
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="com.google.android.c2dm.permission.RECEIVE" />

<application>
  <!-- Your existing application configuration -->
</application>
```

### Step 4: Background Message Handling (Important!)

For Flutter, you need to handle background messages:

**`lib/main.dart`:**
```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_mailer/go_mailer.dart';

// Top-level function for background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📱 Background message received: ${message.messageId}');
  // Background messages are handled automatically by Go Mailer
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Register background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  runApp(MyApp());
}
```

## 🚀 Basic Implementation

### Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:go_mailer/go_mailer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Register background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  runApp(MyApp());
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📱 Background message received: ${message.messageId}');
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isInitialized = false;
  String _status = 'Not initialized';

  @override
  void initState() {
    super.initState();
    _initializeGoMailer();
  }

  Future<void> _initializeGoMailer() async {
    try {
      setState(() => _status = 'Initializing...');

      // Initialize Go Mailer SDK
      await GoMailer.initialize(
        apiKey: 'your_production_api_key', // Replace with your API key
        config: GoMailerConfig(
          baseUrl: 'https://api.go-mailer.com/v1',
          enableAnalytics: true,
          logLevel: GoMailerLogLevel.info, // Use .error for production
        ),
      );

      setState(() {
        _isInitialized = true;
        _status = 'SDK initialized successfully';
      });

    } catch (e) {
      setState(() => _status = 'Initialization failed: $e');
      print('❌ Go Mailer initialization failed: $e');
    }
  }

  Future<void> _setUserAndRegister() async {
    if (!_isInitialized) return;

    try {
      setState(() => _status = 'Setting user...');

      // Set user data
      final user = GoMailerUser(
        email: 'user@example.com', // Replace with actual user email
        firstName: 'John',
        lastName: 'Doe',
      );
      await GoMailer.setUser(user);

      // Register for push notifications
      await GoMailer.registerForPushNotifications(email: user.email!);

      setState(() => _status = 'User registered for notifications');

    } catch (e) {
      setState(() => _status = 'Registration failed: $e');
      print('❌ User registration failed: $e');
    }
  }

  // Call this when app is opened from notification (Android)
  Future<void> _handleNotificationClick() async {
    if (!_isInitialized) return;

    try {
      // In a real app, extract this data from the launch intent
      await GoMailer.trackNotificationClick(
        notificationId: 'test_notification_id',
        title: 'Test Notification',
        body: 'This is a test notification',
        email: 'user@example.com',
      );

      setState(() => _status = 'Notification click tracked');

    } catch (e) {
      setState(() => _status = 'Click tracking failed: $e');
      print('❌ Notification click tracking failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Go Mailer Flutter Demo'),
          backgroundColor: Colors.blue,
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text(_status),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isInitialized ? null : _initializeGoMailer,
                child: Text('Initialize Go Mailer'),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isInitialized ? _setUserAndRegister : null,
                child: Text('Set User & Register for Notifications'),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isInitialized ? _handleNotificationClick : null,
                child: Text('Test Notification Click Tracking'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## 📱 Handling Notification Clicks

### Android Click Handling

For Android, you need to detect when the app is opened from a notification and call the tracking method:

```dart
class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initializeGoMailer();
    _checkForNotificationClick(); // Check on app start
  }

  Future<void> _checkForNotificationClick() async {
    // In a real implementation, you would:
    // 1. Check the launch intent for notification data
    // 2. Extract notification_id, title, body from intent extras
    // 3. Call GoMailer.trackNotificationClick() with the data
    
    // This is handled automatically by the native Android module
    // when you call the trackNotificationClick method
  }
}
```

### iOS Click Handling

iOS click handling is automatic - the SDK automatically detects and tracks notification clicks through the system delegate methods.

## 🔧 Advanced Configuration

### Custom Configuration

```dart
await GoMailer.initialize(
  apiKey: 'your_api_key',
  config: GoMailerConfig(
    baseUrl: 'https://api.go-mailer.com/v1',
    enableAnalytics: true,
    logLevel: GoMailerLogLevel.error, // For production
  ),
);
```

### User Attributes and Tags

```dart
// Set user with attributes
final user = GoMailerUser(
  email: 'user@example.com',
  firstName: 'John',
  lastName: 'Doe',
  customAttributes: {
    'subscription_tier': 'premium',
    'last_purchase': '2024-01-15',
  },
  tags: ['vip', 'mobile_user'],
);
await GoMailer.setUser(user);
```

### Custom Event Tracking

```dart
// Track custom events
await GoMailer.trackEvent(
  eventName: 'user_action',
  properties: {
    'action_type': 'button_click',
    'screen': 'home',
    'timestamp': DateTime.now().toIso8601String(),
  },
);
```

## ✅ Production Checklist

### Before Publishing

- [ ] Replace test API key with production API key
- [ ] Set `logLevel: GoMailerLogLevel.error` for production
- [ ] Test on both debug and release builds
- [ ] Verify Firebase configuration for production
- [ ] Test notification delivery on real devices
- [ ] Verify notification click tracking works
- [ ] Test user registration flow
- [ ] Configure APNs certificates for iOS production

### Firebase Configuration

- [ ] Configure FCM for Android production
- [ ] Set up APNs authentication key for iOS
- [ ] Test notifications from Firebase Console
- [ ] Verify server key configuration (if using server-side sending)

### Testing

- [ ] Test app installation and first launch
- [ ] Test notification permission request
- [ ] Test notification delivery (foreground/background)
- [ ] Test notification click tracking
- [ ] Test user data synchronization
- [ ] Test on multiple devices and OS versions

## 🐛 Troubleshooting

### Common Issues

**1. SDK Initialization Fails**
```
Solution: Check API key and network connection
```

**2. Notifications Not Received**
```
Solution: 
- Verify Firebase configuration
- Check notification permissions
- Test with Firebase Console first
```

**3. iOS Build Fails**
```
Solution:
- Run `cd ios && pod install`
- Clean build folder in Xcode
- Verify GoogleService-Info.plist is added
```

**4. Android Build Fails**
```
Solution:
- Verify google-services.json is in correct location
- Check Gradle plugin versions
- Run `flutter clean && flutter pub get`
```

### Debug Logging

Enable debug logging to troubleshoot issues:

```dart
await GoMailer.initialize(
  apiKey: 'your_api_key',
  config: GoMailerConfig(
    logLevel: GoMailerLogLevel.debug, // Enable debug logs
  ),
);
```

## 📚 Next Steps

- [API Reference](../api-reference.md) - Complete method documentation
- [Usage Examples](../usage-examples.md) - More code examples
- [Troubleshooting](../troubleshooting.md) - Common issues and solutions
- [FAQ](../faq.md) - Frequently asked questions

## 🆘 Support

Need help? Here are your options:

1. **Documentation**: Check our [complete documentation](../getting-started.md)
2. **Examples**: Review the [example applications](../../examples/push_test_flutter_example/)
3. **Issues**: Open an issue on [GitHub](https://github.com/go-mailer/go-mailer-mobile-push)
4. **Email**: Contact support@gomailer.com

---

**✅ You're all set!** Your Flutter app should now be ready to receive and track push notifications with Go Mailer.