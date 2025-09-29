# Go Mailer Push SDK for iOS

[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/GoMailerPushSDK.svg)](https://cocoapods.org/pods/GoMailerPushSDK)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/cocoapods/p/GoMailerPushSDK.svg?style=flat)](https://cocoapods.org/pods/GoMailerPushSDK)

Receive push notifications sent by Go-Mailer in your iOS app. This SDK handles device registration, user identification, and notification interaction tracking - **Go-Mailer takes care of sending the notifications**.

## What This SDK Does

- 📱 **Registers your app** to receive push notifications from Go-Mailer
- 👤 **Identifies users** so Go-Mailer knows who to send notifications to  
- 📊 **Tracks interactions** when users tap notifications
- 🔧 **Simple Integration** - just call our helper functions at the right time
- 🍎 **Native iOS** - written in Swift with full iOS integration

## Installation

### CocoaPods

Add this to your `Podfile`:

```ruby
pod 'GoMailerPushSDK'
```

Then run:
```bash
pod install
```

### Manual Installation

1. Download the latest release from GitHub
2. Drag `GoMailer.framework` into your Xcode project
3. Add to "Embedded Binaries" in your target settings

## Setup

### 1. Enable Push Notifications

In Xcode, go to your target's **Signing & Capabilities** and add:
- **Push Notifications** capability
- **Background Modes** capability (select "Remote notifications")

### 2. Configure APNs

1. Create APNs certificates in your Apple Developer account
2. Upload your certificates to Go-Mailer dashboard
3. The SDK handles APNs registration automatically

## Quick Start

**Step 1: Initialize** (call once in `AppDelegate.swift`)
```swift
import GoMailerPushSDK

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Initialize Go-Mailer SDK (defaults to production)
    GoMailer.initialize(apiKey: "your-go-mailer-api-key")
    return true
}
```

### Environment Configuration

The SDK supports multiple environments for testing:

```swift
// Production (default)
let config = GoMailerConfig()
config.environment = .production // https://api.go-mailer.com/v1
GoMailer.initialize(apiKey: "your-api-key", config: config)

// Staging
let config = GoMailerConfig()
config.environment = .staging // https://api.gm-g7.xyz/v1
GoMailer.initialize(apiKey: "your-api-key", config: config)

// Development
let config = GoMailerConfig()
config.environment = .development // https://api.gm-g6.xyz/v1
GoMailer.initialize(apiKey: "your-api-key", config: config)

// Custom endpoint
let config = GoMailerConfig()
config.baseURL = "https://your-custom-endpoint.com/v1"
GoMailer.initialize(apiKey: "your-api-key", config: config)

// Convenience initializer
let config = GoMailerConfig(environment: .development)
GoMailer.initialize(apiKey: "your-api-key", config: config)
```

**Step 2: Identify the user** (call when user logs in or you know their email)
```swift
GoMailer.setUser([
    "email": "user@example.com"
    // Add any other user properties you want Go-Mailer to know about
])
```

**Step 3: Request permission** (call when appropriate in your UX flow)
```swift
GoMailer.requestNotificationPermission { granted in
    if granted {
        // User will now receive notifications sent by Go-Mailer
    }
}
```

**Step 4: Track clicks** (call when a notification opens your app)
```swift
// Go-Mailer includes notification_id in every notification payload
GoMailer.trackNotificationClick("notification-id-from-payload")
```

**That's it!** Go-Mailer will handle sending notifications to your users.

## Complete API Reference

### 1. Initialize the SDK
```swift
GoMailer.setup(apiKey: "your-go-mailer-api-key")
```
Call this once in `AppDelegate.didFinishLaunchingWithOptions`. **Required before using any other methods.**

### 2. Identify Users
```swift
GoMailer.setUser([
    "email": "user@example.com",
    "firstName": "John",
    "lastName": "Doe"
    // ... any other user properties
])
```
Tell Go-Mailer who this user is so we can send them targeted notifications.

### 3. Handle Permissions
```swift
// Request permission to show notifications
GoMailer.requestNotificationPermission { granted in
    print("Permission granted: \\(granted)")
}

// Check current permission status
let hasPermission = GoMailer.hasNotificationPermission()
```
iOS requires explicit permission from users to show notifications.

### 4. Track Notification Interactions
```swift
// When user taps a notification and opens your app
GoMailer.trackNotificationClick("notification-id-from-payload")
```
**Important:** Go-Mailer includes a `notification_id` in every notification we send. Extract this from the payload and pass it to this method.

### 5. Optional: Custom Event Tracking
```swift
// Track custom user actions (optional)
GoMailer.trackEvent("button_clicked", properties: [
    "button_name": "subscribe"
])
```

### 6. Get Device Information
```swift
// Get the device token (for debugging)
let token = GoMailer.getDeviceToken()
```

## AppDelegate Integration

Here's a complete `AppDelegate.swift` example:

```swift
import UIKit
import GoMailer

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Initialize Go-Mailer SDK
        GoMailer.setup(apiKey: "your-go-mailer-api-key")
        
        return true
    }
    
    // MARK: - Push Notification Handling
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // SDK handles token registration automatically
        GoMailer.didRegisterForRemoteNotifications(with: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \\(error)")
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // Extract notification_id and track the click
        let userInfo = response.notification.request.content.userInfo
        if let notificationId = userInfo["notification_id"] as? String {
            GoMailer.trackNotificationClick(notificationId)
        }
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
}
```

## How Go-Mailer Sends Notifications

**You don't need to worry about sending notifications** - Go-Mailer handles this for you! When we send notifications to your users, we include a `notification_id` that you'll need to extract and use for tracking clicks.

### What the notification payload looks like (for reference):

```json
{
  "aps": {
    "alert": {
      "title": "Hello from Go-Mailer!",
      "body": "Your notification message"
    },
    "sound": "default"
  },
  "notification_id": "abc123",
  "your_custom_data": "any_value"
}
```

**Your job:** Extract the `notification_id` and call `GoMailer.trackNotificationClick(notification_id)` when the user taps the notification.

## Troubleshooting

### Common Issues

**"SDK not initialized"**
- Make sure you call `GoMailer.setup()` in `AppDelegate.didFinishLaunchingWithOptions`

**"Permission denied"**
- iOS requires explicit permission. Call `requestNotificationPermission()`
- Check your app's notification settings in iOS Settings app

**"Notifications not received"**
- Verify your APNs certificates are uploaded to Go-Mailer
- Check that `setUser()` was called with a valid email
- Ensure your app has the Push Notifications capability enabled

**"Click tracking not working"**
- Make sure you're extracting `notification_id` from the payload correctly
- Call `trackNotificationClick()` in the `UNUserNotificationCenterDelegate` method
- Ensure the delegate is properly set up

### Debug Tips

```swift
// Enable debug logging (remove in production)
GoMailer.setLogLevel(.debug)

// Check if device token was obtained
if let token = GoMailer.getDeviceToken() {
    print("Device token: \\(token)")
} else {
    print("No device token - check permissions and certificates")
}
```

## Requirements

- iOS 10.0+
- Xcode 12+
- Swift 5.0+
- Valid Go-Mailer account and API key
- APNs certificates configured

## Need Help?

- 📖 [Complete Documentation](https://docs.go-mailer.com/ios)
- 💬 [Support](https://docs.go-mailer.com/support)
- 🐛 [Report Issues](https://github.com/go-mailer/go-mailer-ios/issues)

---

**Go-Mailer** - Customer engagement messaging platform  
[go-mailer.com](https://go-mailer.com)
