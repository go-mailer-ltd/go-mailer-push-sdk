# Go Mailer Push SDK for Android

[![JitPack](https://jitpack.io/v/go-mailer-ltd/go-mailer-push-sdk.svg)](https://jitpack.io/#go-mailer-ltd/go-mailer-push-sdk)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![API](https://img.shields.io/badge/API-16%2B-brightgreen.svg?style=flat)](https://android-arsenal.com/api?level=16)

Receive push notifications sent by Go-Mailer in your Android app. This SDK handles device registration, user identification, and notification interaction tracking - **Go-Mailer takes care of sending the notifications**.

## What This SDK Does

- 📱 **Registers your app** to receive push notifications from Go-Mailer
- 👤 **Identifies users** so Go-Mailer knows who to send notifications to  
- 📊 **Tracks interactions** when users tap notifications
- 🔧 **Simple Integration** - just call our helper functions at the right time
- 🤖 **Native Android** - written in Kotlin with full Android integration

## Installation

### Step 1: Add JitPack Repository

Add JitPack repository to your project's `build.gradle` (Project level):

```gradle
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url 'https://jitpack.io' }
    }
}
```

### Step 2: Add Dependency

Add the dependency to your app's `build.gradle` (Module level):

```gradle
dependencies {
    implementation 'com.github.go-mailer-ltd:go-mailer-push-sdk:1.0.1'
}
```

### Step 3: Setup Firebase

1. Add your Android app to Firebase Console
2. Download `google-services.json` and place it in your `app/` directory
3. Add Firebase dependencies to your `build.gradle` (Module level):

```gradle
implementation 'com.google.firebase:firebase-messaging:23.0.0'
implementation 'com.google.firebase:firebase-core:21.0.0'
```

4. Add the Google Services plugin to your `build.gradle` (Module level):

```gradle
apply plugin: 'com.google.gms.google-services'
```

5. Add the Google Services classpath to your project's `build.gradle`:

```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

## Quick Start

**Step 1: Initialize** (call once in your `Application` class or `MainActivity`)
```kotlin
import com.gomailer.GoMailer

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Initialize Go-Mailer SDK
        GoMailer.initialize(this, "your-go-mailer-api-key")
    }
}
```

**Step 2: Identify the user** (call when user logs in or you know their email)
```kotlin
val userData = mapOf(
    "email" to "user@example.com"
    // Add any other user properties you want Go-Mailer to know about
)
GoMailer.setUser(userData)
```

**Step 3: Request permission** (call when appropriate in your UX flow)
```kotlin
// Android 13+ requires explicit permission
if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
    if (ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
        ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.POST_NOTIFICATIONS), 1)
    }
}
// User will now receive notifications sent by Go-Mailer
```

**Step 4: Track clicks** (call when a notification opens your app)
```kotlin
// Go-Mailer includes notification_id in every notification payload
val notificationId = intent.getStringExtra("notification_id")
if (notificationId != null) {
    GoMailer.trackNotificationClick(notificationId)
}
```

**That's it!** Go-Mailer will handle sending notifications to your users.

## Complete API Reference

### 1. Initialize the SDK
```kotlin
GoMailer.initialize(context: Context, apiKey: String)
```
Call this once when your app starts. **Required before using any other methods.**

### 2. Identify Users
```kotlin
val userData = mapOf(
    "email" to "user@example.com",
    "firstName" to "John",
    "lastName" to "Doe"
    // ... any other user properties
)
GoMailer.setUser(userData)
```
Tell Go-Mailer who this user is so we can send them targeted notifications.

### 3. Track Notification Interactions
```kotlin
// When user taps a notification and opens your app
GoMailer.trackNotificationClick("notification-id-from-payload")
```
**Important:** Go-Mailer includes a `notification_id` in every notification we send. Extract this from the payload and pass it to this method.

### 4. Optional: Custom Event Tracking
```kotlin
// Track custom user actions (optional)
val properties = mapOf("button_name" to "subscribe")
GoMailer.trackEvent("button_clicked", properties)
```

### 5. Get Device Information
```kotlin
// Get the device token (for debugging)
val token = GoMailer.getDeviceToken()
```

## How Go-Mailer Sends Notifications

**You don't need to worry about sending notifications** - Go-Mailer handles this for you! When we send notifications to your users, we include a `notification_id` that you'll need to extract and use for tracking clicks.

### What the notification payload looks like (for reference):

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

**Your job:** Extract the `notification_id` from the data payload and call `GoMailer.trackNotificationClick(notification_id)` when the user taps the notification.

## Handling Notification Clicks

To properly track notification clicks, you need to handle them in your activity:

```kotlin
class MainActivity : AppCompatActivity() {
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        // Initialize SDK
        GoMailer.initialize(this, "your-api-key")
        
        // Handle notification click
        handleNotificationClick(intent)
    }
    
    override fun onNewIntent(intent: Intent?) {
        super.onNewIntent(intent)
        // Handle notification click when app is already running
        if (intent != null) {
            handleNotificationClick(intent)
        }
    }
    
    private fun handleNotificationClick(intent: Intent) {
        val notificationId = intent.getStringExtra("notification_id")
        if (notificationId != null) {
            GoMailer.trackNotificationClick(notificationId)
        }
    }
}
```

## Troubleshooting

### Common Issues

**"SDK not initialized"**
- Make sure you call `GoMailer.initialize()` before any other methods

**"Notifications not received"**
- Verify your Firebase setup and `google-services.json` file
- Check that `setUser()` was called with a valid email
- Ensure Go-Mailer has your correct FCM server key

**"Click tracking not working"**
- Make sure you're extracting `notification_id` from the intent extras correctly
- Call `trackNotificationClick()` in both `onCreate()` and `onNewIntent()`

### Debug Tips

```kotlin
// Check if device token was obtained
val token = GoMailer.getDeviceToken()
if (token != null) {
    Log.d("GoMailer", "Device token: $token")
} else {
    Log.d("GoMailer", "No device token - check Firebase setup")
}
```

## Permissions

Add these permissions to your `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WAKE_LOCK" />

<!-- For Android 13+ (API level 33+) -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

## Requirements

- Android API level 16+ (Android 4.1+)
- Kotlin or Java
- Firebase project with FCM enabled
- Valid Go-Mailer account and API key

## Need Help?

- 📖 [Complete Documentation](https://docs.go-mailer.com/android)
- 💬 [Support](https://docs.go-mailer.com/support)
- 🐛 [Report Issues](https://github.com/go-mailer-ltd/go-mailer-push-sdk/issues)

---

**Go-Mailer** - Customer engagement messaging platform  
[go-mailer.com](https://go-mailer.com)
