# 🚀 Go Mailer SDK - Installation & Setup Guide

## 📋 Overview

This guide covers the installation, setup, and deployment of all Go Mailer SDKs across Flutter, React Native, iOS, and Android platforms. All SDKs are production-ready with proper error handling, logging, and notification click tracking.

## 🎯 What's Included

### ✅ **All SDKs Ready for Production:**
- **Flutter SDK** - Cross-platform plugin with native Android/iOS modules
- **React Native SDK** - Native module package with TypeScript support
- **iOS SDK** - Swift framework with CocoaPods support
- **Android SDK** - Kotlin library with Gradle integration

### ✅ **Complete Feature Set:**
- **API Key Registration** - Secure SDK initialization
- **User Data Management** - Email, attributes, tags
- **Push Notification Permissions** - Automatic permission requests
- **Device Token Management** - Automatic server synchronization
- **Notification Click Tracking** - Comprehensive analytics
- **Production Endpoints** - `https://api.go-mailer.com/v1` by default
- **Proper Error Handling** - Comprehensive error management
- **Configurable Logging** - Debug, Info, Warning, Error levels

---

## 📱 **Platform-Specific Deployment**

### **1. Flutter SDK**

**📦 Package Information:**
- **Name**: `go_mailer`
- **Version**: `1.0.0`
- **Location**: `/sdk/flutter/`

## **🔧 Installation Steps:**

### **Step 1: Add Dependency**
```yaml
# pubspec.yaml
dependencies:
  go_mailer:
    path: ../path/to/sdk/flutter  # For local development
    # OR from pub.dev when published:
    # go_mailer: ^1.0.0
```

### **Step 2: Firebase Setup**

**Android Setup:**
1. Create Firebase project at [Firebase Console](https://console.firebase.google.com)
2. Add Android app with your package name
3. Download `google-services.json` → `android/app/google-services.json`
4. Update `android/build.gradle`:
```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.3.15'
}
```
5. Update `android/app/build.gradle`:
```gradle
apply plugin: 'com.google.gms.google-services'

dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-messaging'
}
```

**iOS Setup:**
1. Add iOS app to Firebase project
2. Download `GoogleService-Info.plist` → `ios/Runner/GoogleService-Info.plist`
3. Update `ios/Runner/AppDelegate.swift`:
```swift
import Firebase
import go_mailer

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

### **Step 3: Permissions & Capabilities**

**iOS:**
1. Enable Push Notifications in Xcode:
   - Select Runner target → Signing & Capabilities
   - Add "Push Notifications" capability
   - Add "Background Modes" → Check "Background processing"

**Android:**
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="com.google.android.c2dm.permission.RECEIVE" />
```

### **Step 4: Basic Implementation**

```dart
import 'package:go_mailer/go_mailer.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  
  @override
  void initState() {
    super.initState();
    initializeGoMailer();
  }

  Future<void> initializeGoMailer() async {
    try {
      // Initialize SDK
      await GoMailer.initialize(
        apiKey: 'your_production_api_key',
        config: GoMailerConfig(
          baseUrl: 'https://api.go-mailer.com/v1',
          enableAnalytics: true,
          logLevel: GoMailerLogLevel.error, // Production setting
        ),
      );

      // Set user data
      final user = GoMailerUser(email: 'user@example.com');
      await GoMailer.setUser(user);

      // Register for push notifications
      await GoMailer.registerForPushNotifications(email: 'user@example.com');
      
      print('✅ Go Mailer initialized successfully');
    } catch (e) {
      print('❌ Go Mailer initialization failed: $e');
    }
  }

  // Handle notification clicks (Android)
  Future<void> handleNotificationClick() async {
    // This should be called when app is opened from notification
    // Extract notification data from your app's launch intent
    await GoMailer.trackNotificationClick(
      notificationId: 'notification_id_from_intent',
      title: 'Notification Title',
      body: 'Notification Body',
      email: 'user@example.com',
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Go Mailer Demo')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: initializeGoMailer,
                child: Text('Initialize Go Mailer'),
              ),
              ElevatedButton(
                onPressed: handleNotificationClick,
                child: Text('Test Notification Click'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**📋 Production Checklist:**
- ✅ Update `pubspec.yaml` with correct repository URLs
- ✅ Remove `publish_to: none` when ready to publish
- ✅ Set `logLevel: GoMailerLogLevel.error` for production
- ✅ Update Firebase configuration files
- ✅ Test notification click tracking
- ✅ Configure APNs certificates for iOS
- ✅ Test on both debug and release builds

---

### **2. React Native SDK**

**📦 Package Information:**
- **Name**: `go-mailer`
- **Version**: `1.0.0`
- **Location**: `/sdk/react-native/`

**🔧 Installation:**
```bash
# For local development
npm install file:../path/to/sdk/react-native

# OR from npm when published:
# npm install go-mailer
```

**🚀 Usage:**
```typescript
import GoMailer, { GoMailerConfig, GoMailerLogLevel } from 'go-mailer';

// Initialize with production config
const config: GoMailerConfig = {
  apiKey: 'your_production_api_key',
  baseUrl: 'https://api.go-mailer.com/v1', // Production endpoint
  enableAnalytics: true,
  logLevel: GoMailerLogLevel.ERROR, // Use ERROR for production
};

await GoMailer.initialize(config);

// Set user and register for notifications
await GoMailer.setUser({ email: 'user@example.com' });
await GoMailer.registerForPushNotifications('user@example.com');
```

**📋 Production Checklist:**
- ✅ Update `package.json` with correct repository URLs
- ✅ Build TypeScript: `npm run build`
- ✅ Test native module linking on both platforms
- ✅ Set `logLevel: GoMailerLogLevel.ERROR` for production
- ✅ Update Firebase/APNs configuration

---

### **3. iOS SDK**

**📦 Framework Information:**
- **Name**: `GoMailer`
- **Version**: `1.0.0`
- **Location**: `/sdk/ios/`

**🔧 Installation (CocoaPods):**
```ruby
# Podfile
pod 'GoMailer', :path => '../path/to/sdk/ios'

# OR from CocoaPods when published:
# pod 'GoMailer', '~> 1.0.0'
```

**🚀 Usage:**
```swift
import GoMailer

// Initialize with production config
let config = GoMailerConfig()
config.baseURL = "https://api.go-mailer.com/v1" // Production endpoint
config.enableAnalytics = true
config.logLevel = .error // Use .error for production

GoMailer.initialize(apiKey: "your_production_api_key", config: config)

// Set user and register for notifications
let user = GoMailerUser(email: "user@example.com")
GoMailer.setUser(user)
GoMailer.registerForPushNotifications()
```

**📋 Production Checklist:**
- ✅ Update `GoMailer.podspec` with correct repository URLs
- ✅ Set `config.logLevel = .error` for production
- ✅ Configure APNs certificates/keys
- ✅ Test notification click tracking
- ✅ Update app's `Info.plist` for push notifications

---

### **4. Android SDK**

**📦 Library Information:**
- **Name**: `go-mailer`
- **Version**: `1.0.0`
- **Location**: `/sdk/android/`

**🔧 Installation (Gradle):**
```kotlin
// settings.gradle
include ':go-mailer'
project(':go-mailer').projectDir = new File('../path/to/sdk/android/go-mailer')

// app/build.gradle
dependencies {
    implementation project(':go-mailer')
    // OR from Maven when published:
    // implementation 'com.gomailer:go-mailer:1.0.0'
}
```

**🚀 Usage:**
```kotlin
import com.gomailer.GoMailer
import com.gomailer.GoMailerConfig
import com.gomailer.GoMailerUser
import com.gomailer.GoMailerLogLevel

// Initialize with production config
val config = GoMailerConfig(
    baseUrl = "https://api.go-mailer.com/v1", // Production endpoint
    enableAnalytics = true,
    logLevel = GoMailerLogLevel.ERROR // Use ERROR for production
)

GoMailer.initialize(this, "your_production_api_key", config)

// Set user and register for notifications
val user = GoMailerUser(email = "user@example.com")
GoMailer.setUser(user)
GoMailer.registerForPushNotifications()
```

**📋 Production Checklist:**
- ✅ Update `build.gradle` with correct repository URLs
- ✅ Set `logLevel = GoMailerLogLevel.ERROR` for production
- ✅ Configure Firebase project and `google-services.json`
- ✅ Test notification click tracking
- ✅ Update `AndroidManifest.xml` with required permissions

---

## 🔧 **Production Configuration**

### **🌐 Endpoints**
All SDKs now use production endpoints by default:
- **Production**: `https://api.go-mailer.com/v1`
- **Events**: `${BASE_URL}/events/push`
- **Contacts**: `${BASE_URL}/contacts`

### **📊 Logging Levels**
For production, use minimal logging:
- **Flutter**: `GoMailerLogLevel.error`
- **React Native**: `GoMailerLogLevel.ERROR`
- **iOS**: `.error`
- **Android**: `GoMailerLogLevel.ERROR`

### **🔐 API Keys**
- Store API keys securely (environment variables, secure storage)
- Use different API keys for development/staging/production
- Never commit API keys to version control

### **📱 Push Notification Setup**

**iOS (APNs):**
- Configure APNs certificates or keys in Apple Developer Console
- Update `Info.plist` with required capabilities
- Test with development and production certificates

**Android (FCM):**
- Configure Firebase project
- Download and include `google-services.json`
- Test with Firebase Console

---

## 🧪 **Testing Checklist**

### **✅ Pre-Production Testing**

**1. SDK Initialization:**
- [ ] SDK initializes without errors
- [ ] Proper error handling for invalid API keys
- [ ] Production endpoints are used

**2. User Registration:**
- [ ] User data sent to `/v1/contacts` endpoint
- [ ] Correct Go-Mailer payload format with `gm_mobi_push`
- [ ] HTTP 200 response received

**3. Push Notifications:**
- [ ] Device tokens generated and sent to backend
- [ ] Notifications received and displayed
- [ ] **Notification clicks tracked to `/v1/events/push`**
- [ ] Correct notification ID handling (custom or auto-generated)

**4. Error Handling:**
- [ ] Network errors handled gracefully
- [ ] Invalid configurations rejected
- [ ] Proper logging levels respected

### **🔍 Monitoring & Analytics**

**Key Metrics to Track:**
- SDK initialization success rate
- Device token registration success rate
- Notification delivery rate
- **Notification click-through rate** (primary metric)
- API response times and error rates

---

## 📦 **Publishing SDKs**

### **Flutter (pub.dev)**
```bash
cd sdk/flutter
# Remove publish_to: none from pubspec.yaml
flutter pub publish --dry-run
flutter pub publish
```

### **React Native (npm)**
```bash
cd sdk/react-native
npm publish --dry-run
npm publish
```

### **iOS (CocoaPods)**
```bash
cd sdk/ios
pod spec lint GoMailer.podspec
pod trunk push GoMailer.podspec
```

### **Android (Maven Central)**
```bash
cd sdk/android
./gradlew publishToSonatype
./gradlew closeAndReleaseSonatypeStagingRepository
```

---

## 🎯 **Summary**

### **✅ Production-Ready Features:**

1. **🎯 Focused Tracking**: Only tracks notification clicks (not receives/displays)
2. **🌐 Production Endpoints**: All SDKs default to `https://api.go-mailer.com/v1`
3. **🔧 Proper Error Handling**: Comprehensive error management across all platforms
4. **📊 Configurable Logging**: Debug/Info for development, Error for production
5. **📱 Cross-Platform**: Consistent API across Flutter, React Native, iOS, Android
6. **🔐 Secure**: No hardcoded credentials, proper API key management
7. **📋 Go-Mailer Format**: Correct payload structure with `gm_mobi_push`

### **🚀 Ready for Deployment:**

All SDKs are now production-ready and can be deployed to:
- **Flutter**: pub.dev
- **React Native**: npm registry
- **iOS**: CocoaPods
- **Android**: Maven Central

The SDKs will automatically track notification clicks and send them to your Go-Mailer backend with the correct format and endpoints! 🎉
