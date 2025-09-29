# 📱 Go-Mailer SDK Team Distribution Guide

This guide shows you how to build and distribute your Go-Mailer SDK test apps to your team for testing across different environments.

## 🌍 **Available Environments**

| Environment | Endpoint | Usage |
|-------------|----------|-------|
| **Production** | `https://api.go-mailer.com/v1` | ✅ **DEFAULT** - Live environment |
| **Staging** | `https://api.gm-g7.xyz/v1` | 🧪 Pre-production testing |
| **Development** | `https://api.gm-g6.xyz/v1` | 🔧 Development testing |

---

## 🚀 **OPTION 1: Build & Distribute Apps (Recommended)**

### **📱 React Native Example**

#### **Build for iOS:**
```bash
cd examples/push_test_react_native_example

# Install dependencies
npm install
cd ios && pod install && cd ..

# Build for device (requires Apple Developer account)
npx react-native run-ios --device

# Or build .ipa for distribution
xcodebuild -workspace ios/push_test_react_native_example.xcworkspace \
           -scheme push_test_react_native_example \
           -configuration Release \
           -destination generic/platform=iOS \
           -archivePath build/push_test_react_native_example.xcarchive \
           archive

# Export .ipa
xcodebuild -exportArchive \
           -archivePath build/push_test_react_native_example.xcarchive \
           -exportPath build/ \
           -exportOptionsPlist ios/ExportOptions.plist
```

#### **Build for Android:**
```bash
cd examples/push_test_react_native_example

# Build APK for testing
cd android
./gradlew assembleRelease
cd ..

# APK will be at: android/app/build/outputs/apk/release/app-release.apk
```

#### **Distribution Options:**
- **TestFlight** (iOS): Upload .ipa to App Store Connect
- **Firebase App Distribution**: Upload APK/IPA for team testing
- **Direct sharing**: Share APK file directly with Android testers

---

### **🐦 Flutter Example**

#### **Build for iOS:**
```bash
cd examples/push_test_flutter_example

# Install dependencies
flutter pub get
cd ios && pod install && cd ..

# Build for device
flutter build ios --release

# Build .ipa for distribution
flutter build ipa --release
# IPA will be at: build/ios/ipa/push_test_flutter_example.ipa
```

#### **Build for Android:**
```bash
cd examples/push_test_flutter_example

# Build APK
flutter build apk --release
# APK will be at: build/app/outputs/flutter-apk/app-release.apk

# Or build App Bundle for Play Store
flutter build appbundle --release
```

---

### **🍎 Native iOS Example**

```bash
cd examples/push_test_ios_example

# Open in Xcode
open push_test_ios_example.xcodeproj

# Build and archive in Xcode:
# 1. Select "Any iOS Device" as destination
# 2. Product > Archive
# 3. Distribute App > Ad Hoc or Enterprise
```

---

### **🤖 Native Android Example**

```bash
cd examples/push_test_android_example

# Build APK
./gradlew assembleRelease

# APK will be at: app/build/outputs/apk/release/app-release.apk
```

---

## 🔧 **OPTION 2: Share Development Environment**

### **Prerequisites for Team Members:**

#### **React Native Setup:**
```bash
# Install Node.js, React Native CLI
npm install -g react-native-cli

# iOS: Install Xcode, CocoaPods
sudo gem install cocoapods

# Android: Install Android Studio, Java JDK
```

#### **Flutter Setup:**
```bash
# Install Flutter SDK
# Add flutter to PATH

# iOS: Install Xcode
# Android: Install Android Studio
```

### **Team Development Workflow:**

1. **Clone Repository:**
```bash
git clone https://github.com/go-mailer-ltd/go-mailer-push-sdk.git
cd go-mailer-push-sdk
```

2. **Choose Example App:**
```bash
# React Native
cd examples/push_test_react_native_example
npm install

# Flutter  
cd examples/push_test_flutter_example
flutter pub get

# iOS
cd examples/push_test_ios_example
# Open .xcodeproj in Xcode

# Android
cd examples/push_test_android_example
# Open in Android Studio
```

3. **Environment Selection:**
- **React Native**: Use the in-app environment selector
- **Flutter**: Modify `main.dart` to change environment
- **iOS**: Modify `AppDelegate.swift` to change environment  
- **Android**: Modify `MainActivity.kt` to change environment

---

## 📦 **OPTION 3: Use Published SDKs**

Your team can create their own test apps using the published SDKs:

### **React Native:**
```bash
npx react-native init GoMailerTest
cd GoMailerTest
npm install go-mailer-push-sdk@1.1.0
```

### **Flutter:**
```yaml
# pubspec.yaml
dependencies:
  go_mailer_push_sdk: ^1.1.0
```

### **iOS:**
```ruby
# Podfile
pod 'GoMailerPushSDK', '~> 1.1.0'
```

### **Android:**
```gradle
// build.gradle
dependencies {
    implementation 'com.github.go-mailer-ltd:go-mailer-push-sdk:android-v1.1.0'
}
```

---

## 🎯 **Distribution Services**

### **Firebase App Distribution (Recommended)**

1. **Setup:**
```bash
npm install -g firebase-tools
firebase login
firebase init appdistribution
```

2. **Upload Builds:**
```bash
# iOS
firebase appdistribution:distribute build/Runner.ipa \
  --app YOUR_IOS_APP_ID \
  --groups "testers"

# Android  
firebase appdistribution:distribute app-release.apk \
  --app YOUR_ANDROID_APP_ID \
  --groups "testers"
```

### **TestFlight (iOS Only)**

1. Upload .ipa to App Store Connect
2. Add testers via TestFlight
3. Testers get automatic notifications

### **Direct Distribution**

- **Android**: Share APK files directly (enable "Unknown Sources")
- **iOS**: Requires Enterprise certificate or developer provisioning

---

## 📋 **Testing Checklist for Team**

### **Environment Testing:**
- [ ] **Production**: Test with live Go-Mailer endpoint
- [ ] **Staging**: Test with staging environment  
- [ ] **Development**: Test with development environment

### **Feature Testing:**
- [ ] **SDK Initialization**: Verify successful initialization
- [ ] **User Registration**: Test email/user data submission
- [ ] **Push Permissions**: Test notification permission flow
- [ ] **Device Token**: Verify token generation and submission
- [ ] **Notification Delivery**: Test notification receipt
- [ ] **Click Tracking**: Test notification click tracking
- [ ] **Environment Switching**: Test environment selector (React Native)

### **Platform Testing:**
- [ ] **iOS Physical Device**: Test on actual iPhone/iPad
- [ ] **Android Physical Device**: Test on actual Android device
- [ ] **iOS Simulator**: Basic functionality testing
- [ ] **Android Emulator**: Basic functionality testing

---

## 🔑 **API Keys for Testing**

Provide your team with appropriate API keys for each environment:

```typescript
// Example configuration for testers
const API_KEYS = {
  production: 'your-production-api-key',
  staging: 'your-staging-api-key', 
  development: 'your-development-api-key',
};
```

---

## 🆘 **Troubleshooting**

### **Common Issues:**

1. **"SDK not initialized"**
   - Ensure `initialize()` is called before other methods
   - Check API key validity

2. **"No device token"**
   - Verify Firebase/APNs setup
   - Check notification permissions

3. **"Network error"**
   - Verify environment endpoint accessibility
   - Check API key for selected environment

4. **Build failures**
   - Clear caches: `npm start --reset-cache` (RN), `flutter clean` (Flutter)
   - Reinstall dependencies
   - Check platform-specific setup

---

## 📞 **Support**

For issues with:
- **SDK functionality**: Check SDK documentation
- **Build/distribution**: Check platform-specific build guides
- **Environment access**: Verify endpoint accessibility and API keys

---

**Happy testing!** 🚀
