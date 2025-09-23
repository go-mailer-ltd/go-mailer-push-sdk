# React Native SDK Setup Guide

This guide will walk you through integrating the Go Mailer SDK into your React Native application.

## 📋 Prerequisites

- React Native 0.60.0 or higher
- Node.js 16+ and npm/yarn
- Go-Mailer API key
- Firebase project (for push notifications)
- Platform-specific development environment (Xcode for iOS, Android Studio for Android)

## 🔧 Installation Steps

### Step 1: Add Dependency

Install the Go Mailer SDK:

```bash
npm install go-mailer
# OR
yarn add go-mailer

# For iOS, install CocoaPods dependencies
cd ios && pod install && cd ..
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
   - Use Bundle ID from `ios/YourApp.xcodeproj`

2. **Download Configuration**
   - Download `GoogleService-Info.plist`
   - Add to your iOS project in Xcode (drag and drop into project)

3. **Update AppDelegate**

   **`ios/YourApp/AppDelegate.mm`:**
   ```objc
   #import <Firebase/Firebase.h>

   @implementation AppDelegate

   - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
   {
     [FIRApp configure];
     
     // Your existing React Native setup
     self.moduleName = @"YourApp";
     self.initialProps = @{};
     
     return [super application:application didFinishLaunchingWithOptions:launchOptions];
   }

   @end
   ```

### Step 3: Platform Permissions

#### iOS Permissions

1. **Enable Capabilities in Xcode:**
   - Open `ios/YourApp.xcworkspace`
   - Select your app target → Signing & Capabilities
   - Add "Push Notifications" capability
   - Add "Background Modes" → Check "Background App Refresh"

2. **Update Info.plist:**
   ```xml
   <!-- ios/YourApp/Info.plist -->
   <key>UIBackgroundModes</key>
   <array>
     <string>background-fetch</string>
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

### Step 4: Metro Configuration (Important!)

Update your Metro configuration to resolve the SDK properly:

**`metro.config.js`:**
```js
const {getDefaultConfig, mergeConfig} = require('@react-native/metro-config');

const defaultConfig = getDefaultConfig(__dirname);

const config = {
  resolver: {
    alias: {
      'go-mailer': require.resolve('go-mailer'),
    },
  },
};

module.exports = mergeConfig(defaultConfig, config);
```

## 🚀 Basic Implementation

### Complete Example

```typescript
import React, {useEffect, useState} from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Alert,
  ScrollView,
} from 'react-native';
import GoMailer, {GoMailerLogLevel} from 'go-mailer';

const App = () => {
  const [isInitialized, setIsInitialized] = useState(false);
  const [status, setStatus] = useState('Not initialized');

  useEffect(() => {
    initializeGoMailer();
  }, []);

  const initializeGoMailer = async () => {
    try {
      setStatus('Initializing...');

      // Initialize Go Mailer SDK
      await GoMailer.initialize({
        apiKey: 'your_production_api_key', // Replace with your API key
        baseUrl: 'https://api.go-mailer.com/v1',
        enableAnalytics: true,
        logLevel: GoMailerLogLevel.INFO, // Use ERROR for production
      });

      setIsInitialized(true);
      setStatus('SDK initialized successfully');
      console.log('✅ Go Mailer initialized successfully');

    } catch (error) {
      setStatus(`Initialization failed: ${error}`);
      console.error('❌ Go Mailer initialization failed:', error);
    }
  };

  const setUserAndRegister = async () => {
    if (!isInitialized) return;

    try {
      setStatus('Setting user...');

      // Set user data
      await GoMailer.setUser({
        email: 'user@example.com', // Replace with actual user email
        firstName: 'John',
        lastName: 'Doe',
      });

      // Register for push notifications
      await GoMailer.registerForPushNotifications('user@example.com');

      setStatus('User registered for notifications');
      console.log('✅ User registered successfully');

    } catch (error) {
      setStatus(`Registration failed: ${error}`);
      console.error('❌ User registration failed:', error);
    }
  };

  const handleNotificationClick = async () => {
    if (!isInitialized) return;

    try {
      // In a real app, this data would come from the notification that opened the app
      await GoMailer.trackNotificationClick(
        'test_notification_id',
        'Test Notification',
        'This is a test notification',
        'user@example.com'
      );

      setStatus('Notification click tracked');
      console.log('✅ Notification click tracked');

    } catch (error) {
      setStatus(`Click tracking failed: ${error}`);
      console.error('❌ Notification click tracking failed:', error);
    }
  };

  const trackCustomEvent = async () => {
    if (!isInitialized) return;

    try {
      await GoMailer.trackEvent('user_action', {
        action_type: 'button_click',
        screen: 'home',
        timestamp: new Date().toISOString(),
      });

      Alert.alert('Success', 'Custom event tracked!');
      console.log('✅ Custom event tracked');

    } catch (error) {
      Alert.alert('Error', `Event tracking failed: ${error}`);
      console.error('❌ Event tracking failed:', error);
    }
  };

  return (
    <ScrollView style={styles.container}>
      <Text style={styles.title}>Go Mailer React Native Demo</Text>
      
      <View style={styles.statusCard}>
        <Text style={styles.statusLabel}>Status:</Text>
        <Text style={styles.statusText}>{status}</Text>
      </View>

      <TouchableOpacity
        style={[styles.button, isInitialized && styles.buttonDisabled]}
        onPress={initializeGoMailer}
        disabled={isInitialized}>
        <Text style={styles.buttonText}>Initialize Go Mailer</Text>
      </TouchableOpacity>

      <TouchableOpacity
        style={[styles.button, !isInitialized && styles.buttonDisabled]}
        onPress={setUserAndRegister}
        disabled={!isInitialized}>
        <Text style={styles.buttonText}>Set User & Register</Text>
      </TouchableOpacity>

      <TouchableOpacity
        style={[styles.button, !isInitialized && styles.buttonDisabled]}
        onPress={handleNotificationClick}
        disabled={!isInitialized}>
        <Text style={styles.buttonText}>Test Notification Click</Text>
      </TouchableOpacity>

      <TouchableOpacity
        style={[styles.button, !isInitialized && styles.buttonDisabled]}
        onPress={trackCustomEvent}
        disabled={!isInitialized}>
        <Text style={styles.buttonText}>Track Custom Event</Text>
      </TouchableOpacity>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 16,
    backgroundColor: '#f5f5f5',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 20,
    color: '#333',
  },
  statusCard: {
    backgroundColor: 'white',
    padding: 16,
    borderRadius: 8,
    marginBottom: 16,
    elevation: 2,
    shadowOffset: {width: 0, height: 2},
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  statusLabel: {
    fontSize: 16,
    fontWeight: 'bold',
    marginBottom: 8,
    color: '#333',
  },
  statusText: {
    fontSize: 14,
    color: '#666',
  },
  button: {
    backgroundColor: '#007AFF',
    padding: 16,
    borderRadius: 8,
    marginBottom: 12,
    alignItems: 'center',
  },
  buttonDisabled: {
    backgroundColor: '#ccc',
  },
  buttonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
});

export default App;
```

## 📱 Handling Notification Clicks

### Android Click Handling

For Android, you need to detect when the app is opened from a notification:

```typescript
import {useEffect} from 'react';
import {AppState, Linking} from 'react-native';
import GoMailer from 'go-mailer';

const useNotificationClickHandler = () => {
  useEffect(() => {
    // Handle app opened from notification
    const handleAppStateChange = (nextAppState: string) => {
      if (nextAppState === 'active') {
        // Check if app was opened from notification
        checkForNotificationClick();
      }
    };

    const subscription = AppState.addEventListener('change', handleAppStateChange);
    
    // Check on initial app launch
    checkForNotificationClick();

    return () => subscription?.remove();
  }, []);

  const checkForNotificationClick = async () => {
    try {
      // In a real implementation, you would:
      // 1. Check the launch intent for notification data
      // 2. Extract notification_id, title, body from intent
      // 3. Call GoMailer.trackNotificationClick() with the data
      
      // For now, this is handled by calling trackNotificationClick manually
      // when you detect the notification data
    } catch (error) {
      console.error('Error checking notification click:', error);
    }
  };
};

// Use in your main component
const App = () => {
  useNotificationClickHandler();
  
  // Rest of your component...
};
```

### iOS Click Handling

iOS click handling is automatic - the SDK automatically detects and tracks notification clicks through the native iOS module.

## 🔧 Advanced Configuration

### TypeScript Support

The SDK includes full TypeScript definitions. For better type safety:

```typescript
import GoMailer, {
  GoMailerConfig,
  GoMailerLogLevel,
  GoMailerUser,
} from 'go-mailer';

const config: GoMailerConfig = {
  apiKey: 'your_api_key',
  baseUrl: 'https://api.go-mailer.com/v1',
  enableAnalytics: true,
  logLevel: GoMailerLogLevel.ERROR, // For production
};

const user: GoMailerUser = {
  email: 'user@example.com',
  firstName: 'John',
  lastName: 'Doe',
  customAttributes: {
    subscription_tier: 'premium',
    last_purchase: '2024-01-15',
  },
  tags: ['vip', 'mobile_user'],
};
```

### Event Listeners

Listen to SDK events:

```typescript
useEffect(() => {
  // Listen to push notification events
  const subscription = GoMailer.onPushNotification((event) => {
    console.log('Push notification event:', event);
  });

  return () => subscription.remove();
}, []);
```

### Error Handling

Implement comprehensive error handling:

```typescript
const initializeWithErrorHandling = async () => {
  try {
    await GoMailer.initialize(config);
  } catch (error) {
    if (error.code === 'INVALID_API_KEY') {
      Alert.alert('Error', 'Invalid API key. Please check your configuration.');
    } else if (error.code === 'NETWORK_ERROR') {
      Alert.alert('Error', 'Network error. Please check your connection.');
    } else {
      Alert.alert('Error', `Initialization failed: ${error.message}`);
    }
  }
};
```

## ✅ Production Checklist

### Before Publishing

- [ ] Replace test API key with production API key
- [ ] Set `logLevel: GoMailerLogLevel.ERROR` for production
- [ ] Test on both debug and release builds
- [ ] Verify Firebase configuration for production
- [ ] Test notification delivery on real devices
- [ ] Verify notification click tracking works
- [ ] Test user registration flow
- [ ] Configure APNs certificates for iOS production

### Build Configuration

**For iOS Release:**
```bash
cd ios && pod install
# Build for release in Xcode or:
npx react-native run-ios --configuration Release
```

**For Android Release:**
```bash
cd android
./gradlew assembleRelease
# Or build AAB for Play Store:
./gradlew bundleRelease
```

### Testing

- [ ] Test app installation and first launch
- [ ] Test notification permission request
- [ ] Test notification delivery (foreground/background)
- [ ] Test notification click tracking
- [ ] Test user data synchronization
- [ ] Test on multiple devices and OS versions

## 🐛 Troubleshooting

### Common Issues

**1. Native Module Not Found**
```bash
# Solution: Reinstall and rebuild
rm -rf node_modules
npm install
cd ios && pod install && cd ..
npx react-native run-ios # or run-android
```

**2. Metro Resolution Issues**
```bash
# Solution: Reset Metro cache
npx react-native start --reset-cache
```

**3. iOS Build Fails**
```bash
# Solution: Clean and reinstall pods
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
```

**4. Android Build Fails**
```bash
# Solution: Clean Gradle cache
cd android
./gradlew clean
cd ..
```

### Debug Logging

Enable debug logging to troubleshoot issues:

```typescript
await GoMailer.initialize({
  apiKey: 'your_api_key',
  logLevel: GoMailerLogLevel.DEBUG, // Enable debug logs
});
```

### Network Issues

If you're having network connectivity issues:

```typescript
// Test with a custom endpoint
await GoMailer.initialize({
  apiKey: 'your_api_key',
  baseUrl: 'https://your-custom-endpoint.com/v1',
});
```

## 📚 Next Steps

- [API Reference](../api-reference.md) - Complete method documentation
- [Usage Examples](../usage-examples.md) - More code examples
- [Troubleshooting](../troubleshooting.md) - Common issues and solutions
- [FAQ](../faq.md) - Frequently asked questions

## 🆘 Support

Need help? Here are your options:

1. **Documentation**: Check our [complete documentation](../getting-started.md)
2. **Examples**: Review the [example applications](../../examples/push_test_react_native_example/)
3. **Issues**: Open an issue on [GitHub](https://github.com/go-mailer/go-mailer-mobile-push)
4. **Email**: Contact support@gomailer.com

---

**✅ You're all set!** Your React Native app should now be ready to receive and track push notifications with Go Mailer.