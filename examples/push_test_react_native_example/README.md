# Go Mailer React Native Example

This is a complete example React Native app demonstrating how to integrate the **Go Mailer Push SDK** for receiving push notifications.

## 🚀 What This Example Shows

- ✅ Installing the published `go-mailer-push-sdk` from npm
- ✅ Initializing the SDK with your API key
- ✅ Setting user data for targeted messaging
- ✅ Requesting notification permissions (Android 13+)
- ✅ Registering for push notifications
- ✅ Getting device tokens for debugging
- ✅ Tracking custom events

## 📦 Package Used

This example uses the **published npm package**:
```json
{
  "dependencies": {
    "go-mailer-push-sdk": "^1.0.2"
  }
}
```

## 🛠 Setup Instructions

### 1. Install Dependencies
```bash
npm install
```

### 2. Configure Firebase (Required)

**Android:**
- Add your `google-services.json` to `android/app/`
- Update `android/app/build.gradle` if needed

**iOS:**
- Add your `GoogleService-Info.plist` to the iOS project
- Run `cd ios && pod install`

### 3. Update API Key

In `App.tsx`, replace the API key with your actual Go-Mailer API key:
```typescript
await GoMailer.initialize({
  apiKey: 'your-actual-api-key-here',
  // baseUrl is optional - defaults to production endpoint
});
```

### 4. Run the App

**Android:**
```bash
npx react-native run-android
```

**iOS:**
```bash
npx react-native run-ios
```

## 📱 How to Use

1. **Enter Email** - Input the user's email address
2. **Request Permission** - Tap to request notification permissions
3. **Initialize SDK** - Initialize Go-Mailer with your API key
4. **Set User** - Send user data to Go-Mailer backend
5. **Register for Push** - Register device for push notifications
6. **Get Device Token** - View the FCM/APNs token for debugging
7. **Track Events** - Send sample events to Go-Mailer

## 🔧 Key Integration Points

### SDK Initialization
```typescript
import GoMailer from 'go-mailer-push-sdk';

await GoMailer.initialize({
  apiKey: 'your-api-key',
});
```

### User Registration
```typescript
await GoMailer.setUser({
  email: 'user@example.com'
});
```

### Push Notification Registration
```typescript
await GoMailer.registerForPushNotifications('user@example.com');
```

### Event Tracking
```typescript
await GoMailer.trackEvent('button_clicked', {
  button: 'subscribe',
  source: 'react_native_app'
});
```

## 🔍 Debugging

- Check the console logs for SDK initialization status
- Use "Get Device Token" to verify Firebase setup
- The status indicator shows the current SDK state
- Device token is displayed when available

## 📚 More Information

- [Go Mailer Push SDK Documentation](https://www.npmjs.com/package/go-mailer-push-sdk)
- [React Native Setup Guide](../../docs/platform-setup/react-native-setup.md)
- [Firebase Setup Guide](https://firebase.google.com/docs/react-native/setup)

---

**Go-Mailer** - Customer engagement messaging platform  
[go-mailer.com](https://go-mailer.com)
