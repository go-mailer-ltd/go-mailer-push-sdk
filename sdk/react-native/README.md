# Go Mailer Push SDK for React Native

[![npm version](https://badge.fury.io/js/go-mailer-push-sdk.svg)](https://badge.fury.io/js/go-mailer-push-sdk)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Receive push notifications sent by Go-Mailer in your React Native app. This SDK handles device registration, user identification, and notification interaction tracking - **Go-Mailer takes care of sending the notifications**.

## What This SDK Does

- 📱 **Registers your app** to receive push notifications from Go-Mailer
- 👤 **Identifies users** so Go-Mailer knows who to send notifications to  
- 📊 **Tracks interactions** when users tap notifications
- 🔧 **Simple Integration** - just call our helper functions at the right time
- 📱 **Cross-Platform** - works on both iOS and Android

## Installation

```bash
npm install go-mailer-push-sdk
# or
yarn add go-mailer-push-sdk
```

### iOS Setup

1. Add to your `Podfile`:
```ruby
pod 'GoMailer', :path => '../node_modules/go-mailer-push-sdk/ios'
```

2. Run:
```bash
cd ios && pod install
```

3. Enable Push Notifications capability in Xcode
4. Configure APNs certificates in your Apple Developer account

### Android Setup

1. Add Firebase to your Android project
2. Place `google-services.json` in `android/app/`
3. The SDK handles FCM registration automatically

## Quick Start

**Step 1: Initialize** (call once when your app starts)
```typescript
import GoMailer from 'go-mailer-push-sdk';

await GoMailer.initialize({
  apiKey: 'your-go-mailer-api-key'
});
```

**Step 2: Identify the user** (call when user logs in or you know their email)
```typescript
await GoMailer.setUser({
  email: 'user@example.com'
  // Add any other user properties you want Go-Mailer to know about
});
```

**Step 3: Request permission** (call when appropriate in your UX flow)
```typescript
const granted = await GoMailer.requestNotificationPermission();
if (granted) {
  // User will now receive notifications sent by Go-Mailer
}
```

**Step 4: Track clicks** (call when a notification opens your app)
```typescript
// Go-Mailer includes notification_id in every notification payload
await GoMailer.trackNotificationClick('notification-id-from-payload');
```

**That's it!** Go-Mailer will handle sending notifications to your users.

## Complete API Reference

### 1. Initialize the SDK
```typescript
await GoMailer.initialize({
  apiKey: 'your-go-mailer-api-key'
})
```
Call this once when your app starts. **Required before using any other methods.**

### 2. Identify Users
```typescript
await GoMailer.setUser({
  email: 'user@example.com',
  firstName: 'John',
  lastName: 'Doe'
  // ... any other user properties
})
```
Tell Go-Mailer who this user is so we can send them targeted notifications.

### 3. Handle Permissions
```typescript
// Request permission to show notifications
const granted = await GoMailer.requestNotificationPermission()

// Check current permission status
const status = await GoMailer.checkNotificationPermission()
```
iOS requires explicit permission. Android grants it automatically in most cases.

### 4. Track Notification Interactions
```typescript
// When user taps a notification and opens your app
await GoMailer.trackNotificationClick('notification-id-from-payload')
```
**Important:** Go-Mailer includes a `notification_id` in every notification we send. Extract this from the payload and pass it to this method.

### 5. Optional: Custom Event Tracking
```typescript
// Track custom user actions (optional)
await GoMailer.trackEvent('button_clicked', { 
  button_name: 'subscribe' 
})
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

```typescript
import GoMailer from 'go-mailer-push-sdk';
import { useEffect } from 'react';

export default function App() {
  useEffect(() => {
    // Initialize on app start
    GoMailer.initialize({ apiKey: 'your-api-key' });
  }, []);

  const handleLogin = async (email: string) => {
    // Identify user after login
    await GoMailer.setUser({ email });
    
    // Request permission at the right moment
    const granted = await GoMailer.requestNotificationPermission();
    if (granted) {
      console.log('User will receive Go-Mailer notifications');
    }
  };

  // Handle notification clicks (implementation depends on your navigation)
  const handleNotificationClick = (notificationData: any) => {
    const notificationId = notificationData.notification_id;
    if (notificationId) {
      GoMailer.trackNotificationClick(notificationId);
    }
  };

  return (
    // Your app content
  );
}
```

## Requirements

- React Native >= 0.60.0
- iOS 10.0+ / Android API level 16+
- Valid Go-Mailer account and API key

## Need Help?

- 📖 [Complete Documentation](https://docs.go-mailer.com/react-native)
- 💬 [Support](https://docs.go-mailer.com/support)
- 🐛 [Report Issues](https://github.com/go-mailer/go-mailer-react-native/issues)

---

**Go-Mailer** - Customer engagement messaging platform  
[go-mailer.com](https://go-mailer.com)
