# Android SDK Setup Guide

This guide will walk you through integrating the Go Mailer SDK into your native Android application.

## 📋 Prerequisites

- Android API Level 24 (Android 7.0) or higher
- Android Studio 4.0 or higher
- Kotlin 1.7.0 or higher
- Go-Mailer API key
- Firebase project (for push notifications)

## 🔧 Installation Steps

### Step 1: Add SDK Dependency

#### Option 1: Maven Central (When Published)
```gradle
// app/build.gradle
dependencies {
    implementation 'com.gomailer:go-mailer:1.0.0'
}
```

#### Option 2: Local Development
```gradle
// settings.gradle
include ':go-mailer'
project(':go-mailer').projectDir = new File('../path/to/sdk/android/go-mailer')

// app/build.gradle
dependencies {
    implementation project(':go-mailer')
}
```

### Step 2: Firebase Setup

1. **Create Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Create a new project or use existing one
   - Add Android app with your package name

2. **Download Configuration**
   - Download `google-services.json`
   - Place it in `app/google-services.json`

3. **Update Build Files**

   **Project-level `build.gradle`:**
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

   **App-level `build.gradle`:**
   ```gradle
   apply plugin: 'com.google.gms.google-services'

   dependencies {
       implementation platform('com.google.firebase:firebase-bom:32.7.0')
       implementation 'com.google.firebase:firebase-messaging'
       
       // Go Mailer SDK dependencies
       implementation 'androidx.core:core-ktx:1.12.0'
       implementation 'androidx.appcompat:appcompat:1.6.1'
       implementation 'com.squareup.okhttp3:okhttp:4.12.0'
       implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3'
   }
   ```

### Step 3: Permissions and Manifest

**`app/src/main/AndroidManifest.xml`:**
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- Required permissions -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="com.google.android.c2dm.permission.RECEIVE" />
    
    <application
        android:name=".MyApplication"
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:theme="@style/AppTheme">
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
        
        <!-- Firebase Messaging Service -->
        <service
            android:name=".MyFirebaseMessagingService"
            android:exported="false">
            <intent-filter>
                <action android:name="com.google.firebase.MESSAGING_EVENT" />
            </intent-filter>
        </service>
        
    </application>
</manifest>
```

### Step 4: Application Setup

**`MyApplication.kt`:**
```kotlin
import android.app.Application
import com.gomailer.GoMailer
import com.gomailer.GoMailerConfig
import com.gomailer.GoMailerLogLevel

class MyApplication : Application() {
    
    override fun onCreate() {
        super.onCreate()
        initializeGoMailer()
    }
    
    private fun initializeGoMailer() {
        val config = GoMailerConfig(
            baseUrl = "https://api.go-mailer.com/v1",
            enableAnalytics = true,
            logLevel = GoMailerLogLevel.ERROR // Use ERROR for production
        )
        
        try {
            GoMailer.initialize(this, "your_production_api_key", config)
            android.util.Log.i("GoMailer", "✅ SDK initialized successfully")
        } catch (e: Exception) {
            android.util.Log.e("GoMailer", "❌ SDK initialization failed", e)
        }
    }
}
```

### Step 5: Firebase Messaging Service

**`MyFirebaseMessagingService.kt`:**
```kotlin
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.media.RingtoneManager
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class MyFirebaseMessagingService : FirebaseMessagingService() {
    
    companion object {
        private const val TAG = "MyFCMService"
        private const val CHANNEL_ID = "go_mailer_notifications"
        private const val NOTIFICATION_ID = 1
    }
    
    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)
        
        Log.d(TAG, "📨 FCM message received from: ${remoteMessage.from}")
        
        // Handle notification payload
        remoteMessage.notification?.let { notification ->
            Log.d(TAG, "📨 Notification Title: ${notification.title}")
            Log.d(TAG, "📨 Notification Body: ${notification.body}")
            
            showNotification(
                title = notification.title ?: "Go Mailer",
                body = notification.body ?: "New notification",
                data = remoteMessage.data,
                messageId = remoteMessage.messageId
            )
        }
        
        // Handle data payload - show notification for data-only messages
        if (remoteMessage.data.isNotEmpty()) {
            Log.d(TAG, "📨 Message data payload: ${remoteMessage.data}")
            
            if (remoteMessage.notification == null) {
                showNotification(
                    title = remoteMessage.data["title"] ?: "Go Mailer",
                    body = remoteMessage.data["body"] ?: "New message received",
                    data = remoteMessage.data,
                    messageId = remoteMessage.messageId
                )
            }
        }
    }
    
    override fun onNewToken(token: String) {
        Log.d(TAG, "🔑 FCM token refreshed: ${token.take(20)}...")
        // Token refresh is handled automatically by Go Mailer SDK
    }
    
    private fun showNotification(title: String, body: String, data: Map<String, String>, messageId: String?) {
        val intent = Intent(this, MainActivity::class.java)
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
        
        // Pass notification data to activity
        data.forEach { (key, value) -> intent.putExtra(key, value) }
        
        // Add special flag to track notification click
        intent.putExtra("notification_clicked", true)
        intent.putExtra("notification_id", data["notification_id"] ?: messageId ?: "unknown")
        intent.putExtra("notification_title", title)
        intent.putExtra("notification_body", body)
        
        val pendingIntent = PendingIntent.getActivity(
            this, 
            System.currentTimeMillis().toInt(), // Unique request code
            intent, 
            PendingIntent.FLAG_ONE_SHOT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val defaultSoundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
        val notificationBuilder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_dialog_info) // Replace with your app icon
            .setContentTitle(title)
            .setContentText(body)
            .setAutoCancel(true)
            .setSound(defaultSoundUri)
            .setContentIntent(pendingIntent)
        
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        
        // Create notification channel for Android O and above
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Go Mailer Notifications",
                NotificationManager.IMPORTANCE_DEFAULT
            )
            notificationManager.createNotificationChannel(channel)
        }
        
        notificationManager.notify(NOTIFICATION_ID, notificationBuilder.build())
        Log.d(TAG, "✅ Notification displayed: $title")
    }
}
```

## 🚀 Basic Implementation

### MainActivity Example

**`MainActivity.kt`:**
```kotlin
import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import com.gomailer.GoMailer
import com.gomailer.GoMailerUser
import kotlinx.coroutines.launch

class MainActivity : AppCompatActivity() {
    
    companion object {
        private const val TAG = "MainActivity"
    }
    
    private lateinit var statusText: TextView
    private lateinit var initButton: Button
    private lateinit var registerButton: Button
    private lateinit var trackEventButton: Button
    
    private var isInitialized = false
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        setupViews()
        setupClickListeners()
        
        // Check if app was opened from notification
        handleNotificationClick()
        
        // Check if Go Mailer is already initialized
        checkInitializationStatus()
    }
    
    override fun onNewIntent(intent: Intent?) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleNotificationClick()
    }
    
    private fun setupViews() {
        statusText = findViewById(R.id.statusText)
        initButton = findViewById(R.id.initButton)
        registerButton = findViewById(R.id.registerButton)
        trackEventButton = findViewById(R.id.trackEventButton)
        
        statusText.text = "Not initialized"
        registerButton.isEnabled = false
        trackEventButton.isEnabled = false
    }
    
    private fun setupClickListeners() {
        initButton.setOnClickListener { initializeGoMailer() }
        registerButton.setOnClickListener { setUserAndRegister() }
        trackEventButton.setOnClickListener { trackCustomEvent() }
    }
    
    private fun checkInitializationStatus() {
        // In a real app, you might check if SDK is already initialized
        // For this example, we assume it's initialized in Application class
        isInitialized = true
        updateUI()
    }
    
    private fun initializeGoMailer() {
        statusText.text = "Initializing..."
        
        lifecycleScope.launch {
            try {
                // SDK should already be initialized in Application class
                // This is just for demonstration
                isInitialized = true
                statusText.text = "SDK initialized successfully"
                updateUI()
                
                Log.i(TAG, "✅ Go Mailer initialized successfully")
            } catch (e: Exception) {
                statusText.text = "Initialization failed: ${e.message}"
                Log.e(TAG, "❌ Go Mailer initialization failed", e)
            }
        }
    }
    
    private fun setUserAndRegister() {
        if (!isInitialized) return
        
        statusText.text = "Setting user..."
        
        lifecycleScope.launch {
            try {
                // Set user data
                val user = GoMailerUser(
                    email = "user@example.com",
                    firstName = "John",
                    lastName = "Doe",
                    customAttributes = mapOf(
                        "subscription_tier" to "premium",
                        "last_purchase" to "2024-01-15"
                    ),
                    tags = listOf("vip", "mobile_user", "android")
                )
                
GoMailer.setUser(user)

                // Register for push notifications
                GoMailer.registerForPushNotifications()
                
                statusText.text = "User registered for notifications"
                Log.i(TAG, "✅ User registered successfully")
                
            } catch (e: Exception) {
                statusText.text = "Registration failed: ${e.message}"
                Log.e(TAG, "❌ User registration failed", e)
            }
        }
    }
    
    private fun trackCustomEvent() {
        if (!isInitialized) return
        
        lifecycleScope.launch {
            try {
                val properties = mapOf(
                    "action_type" to "button_click",
                    "screen" to "main",
                    "timestamp" to System.currentTimeMillis()
                )
                
                GoMailer.trackEvent("user_action", properties)
                
                statusText.text = "Custom event tracked"
                Log.i(TAG, "✅ Custom event tracked")
                
            } catch (e: Exception) {
                statusText.text = "Event tracking failed: ${e.message}"
                Log.e(TAG, "❌ Event tracking failed", e)
            }
        }
    }
    
    private fun handleNotificationClick() {
        val wasClickedFromNotification = intent.getBooleanExtra("notification_clicked", false)
        
        if (wasClickedFromNotification) {
            val notificationId = intent.getStringExtra("notification_id") ?: "unknown"
            val notificationTitle = intent.getStringExtra("notification_title") ?: "Unknown"
            val notificationBody = intent.getStringExtra("notification_body") ?: ""
            
            Log.d(TAG, "👆 Notification clicked! ID: $notificationId")
            Log.d(TAG, "👆 Title: $notificationTitle")
            Log.d(TAG, "👆 Body: $notificationBody")
            
            // Track the notification click event
            lifecycleScope.launch {
                try {
                    GoMailer.trackNotificationClick(
                        notificationId = notificationId,
                        title = notificationTitle,
                        body = notificationBody,
                        email = "user@example.com" // Use actual user email
                    )
                    
                    Log.d(TAG, "📊 ✅ Notification click tracked successfully!")
                    statusText.text = "🎉 Notification click tracked!"
                    
                } catch (e: Exception) {
                    Log.e(TAG, "❌ Failed to track notification click", e)
                    statusText.text = "❌ Failed to track notification click"
                }
            }
        }
    }
    
    private fun updateUI() {
        initButton.isEnabled = !isInitialized
        registerButton.isEnabled = isInitialized
        trackEventButton.isEnabled = isInitialized
    }
}
```

### Layout Example

**`res/layout/activity_main.xml`:**
```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:padding="16dp">

    <TextView
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="Go Mailer Android Demo"
        android:textSize="24sp"
        android:textStyle="bold"
        android:gravity="center"
        android:layout_marginBottom="24dp" />

    <androidx.cardview.widget.CardView
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginBottom="16dp">

        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="vertical"
            android:padding="16dp">

            <TextView
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="Status:"
                android:textStyle="bold"
                android:layout_marginBottom="8dp" />

            <TextView
                android:id="@+id/statusText"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:text="Not initialized"
                android:textColor="@android:color/darker_gray" />

        </LinearLayout>

    </androidx.cardview.widget.CardView>

    <Button
        android:id="@+id/initButton"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="Initialize Go Mailer"
        android:layout_marginBottom="8dp" />

    <Button
        android:id="@+id/registerButton"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="Set User &amp; Register"
        android:layout_marginBottom="8dp" />

    <Button
        android:id="@+id/trackEventButton"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="Track Custom Event"
        android:layout_marginBottom="8dp" />

</LinearLayout>
```

## 📱 Notification Click Tracking

### Automatic Click Detection

The Android implementation requires manual detection of notification clicks. The example above shows how to:

1. **Add Intent Extras**: In `MyFirebaseMessagingService`, add notification data to the intent
2. **Detect Click**: In `MainActivity`, check for the `notification_clicked` flag
3. **Track Event**: Call `GoMailer.trackNotificationClick()` with the notification data

### Custom Notification Data

To include custom notification IDs in your server-sent notifications:

**FCM Payload Example:**
```json
{
  "to": "device_token_here",
  "data": {
    "notification_id": "custom_123456",
    "title": "Welcome!",
    "body": "Thanks for using our app",
    "campaign_id": "welcome_series_1"
  },
  "notification": {
    "title": "Welcome!",
    "body": "Thanks for using our app"
  }
}
```

## 🔧 Advanced Configuration

### Custom Configuration Options

```kotlin
        val config = GoMailerConfig(
            baseUrl = "https://api.go-mailer.com/v1",
    enableAnalytics = true,
    logLevel = GoMailerLogLevel.ERROR // DEBUG, INFO, WARN, ERROR
)

GoMailer.initialize(this, "your_api_key", config)
```

### User Management

```kotlin
// Set user with all attributes
val user = GoMailerUser(
    email = "user@example.com",
    firstName = "John",
    lastName = "Doe",
    customAttributes = mapOf(
        "subscription_tier" to "premium",
        "last_purchase_date" to "2024-01-15",
        "total_purchases" to 25,
        "device_model" to Build.MODEL,
        "android_version" to Build.VERSION.RELEASE
    ),
    tags = listOf("vip", "mobile_user", "android")
)

GoMailer.setUser(user)

// Update user attributes
GoMailer.setUserAttributes(mapOf(
    "last_login" to System.currentTimeMillis(),
    "app_version" to BuildConfig.VERSION_NAME
))

// Add/remove tags
GoMailer.addUserTags(listOf("premium_subscriber"))
GoMailer.removeUserTags(listOf("trial_user"))
```

### Event Tracking

```kotlin
// Track events with properties
GoMailer.trackEvent("product_viewed", mapOf(
    "product_id" to "12345",
    "category" to "electronics",
    "price" to 299.99,
    "currency" to "USD"
))

// Track user actions
GoMailer.trackEvent("button_clicked", mapOf(
    "button_name" to "checkout",
    "screen" to "product_detail",
    "timestamp" to System.currentTimeMillis()
))
```

### Device Token Management

```kotlin
// Get current device token
val token = GoMailer.getDeviceToken()
if (token != null) {
    Log.d("GoMailer", "Current device token: $token")
}
```

## ✅ Production Checklist

### Before Play Store Release

- [ ] Replace test API key with production API key
- [ ] Set `logLevel = GoMailerLogLevel.ERROR` for production
- [ ] Configure production Firebase project
- [ ] Test on physical devices
- [ ] Test notification delivery and click tracking
- [ ] Verify user registration flow
- [ ] Test app launch from notifications
- [ ] Review and test all notification scenarios
- [ ] Test on different Android versions

### Firebase Configuration

- [ ] Configure FCM for Android production
- [ ] Test notifications from Firebase Console
- [ ] Verify server key configuration (if using server-side sending)
- [ ] Set up proper notification channels for Android O+

### App Bundle/APK

- [ ] Test with signed release build
- [ ] Verify ProGuard/R8 rules (if using obfuscation)
- [ ] Test notification permissions on Android 13+
- [ ] Verify background app restrictions don't affect notifications

### ProGuard/R8 Rules (if needed)

**`proguard-rules.pro`:**
```
# Go Mailer SDK
-keep class com.gomailer.** { *; }
-keep class com.gomailer.models.** { *; }

# OkHttp
-dontwarn okhttp3.**
-keep class okhttp3.** { *; }

# Coroutines
-keepclassmembernames class kotlinx.** {
    volatile <fields>;
}
```

## 🐛 Troubleshooting

### Common Issues

**1. SDK Not Found**
```
Solution: 
- Verify Gradle configuration
- Check settings.gradle includes correct path
- Clean and rebuild project
```

**2. Notifications Not Received**
```
Solution:
- Check Firebase configuration
- Verify google-services.json is correct
- Test with Firebase Console first
- Check device token is valid
- Verify app is not in battery optimization
```

**3. Build Errors**
```
Solution:
- Clean project (Build → Clean Project)
- Invalidate caches (File → Invalidate Caches and Restart)
- Check Gradle and plugin versions
```

**4. Notification Click Not Tracked**
```
Solution:
- Verify intent extras are set correctly
- Check MainActivity handles onNewIntent
- Review console logs for tracking events
- Ensure user email is set before tracking
```

### Debug Information

Enable debug logging to troubleshoot:

```kotlin
val config = GoMailerConfig(
    logLevel = GoMailerLogLevel.DEBUG // Enable debug logs
)
GoMailer.initialize(this, "your_api_key", config)
```

### Testing Notifications

Test notifications using Firebase Console:

1. Go to Firebase Console → Cloud Messaging
2. Send test notification to your device token
3. Include custom data in "Additional options"
4. Verify notification appears and click tracking works

## 📚 Next Steps

- [API Reference](../api-reference.md) - Complete method documentation
- [Usage Examples](../usage-examples.md) - More code examples
- [Troubleshooting](../troubleshooting.md) - Common issues and solutions
- [FAQ](../faq.md) - Frequently asked questions

## 🆘 Support

Need help? Here are your options:

1. **Documentation**: Check our [complete documentation](../getting-started.md)
2. **Examples**: Review the [example applications](../../examples/push_test_android_example/)
3. **Issues**: Open an issue on [GitHub](https://github.com/go-mailer/go-mailer-mobile-push)
4. **Email**: Contact support@gomailer.com

---

**✅ You're all set!** Your Android app should now be ready to receive and track push notifications with Go Mailer.