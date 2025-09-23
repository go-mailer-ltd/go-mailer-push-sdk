# Go-Mailer Android Example App

This is an example Android app that demonstrates how to integrate and use the Go-Mailer SDK for push notifications.

## Features

- Initialize the Go-Mailer SDK
- Request notification permissions
- Register for push notifications
- Send user data to backend
- Get device token
- Handle incoming push notifications

## Setup Instructions

### 1. Prerequisites

- Android Studio (latest version)
- Android SDK (API level 24+)
- Firebase project with FCM enabled

### 2. Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select existing one
3. Add Android app to your project:
   - Package name: `com.example.push_test_android_example`
   - App nickname: `Go-Mailer Test`
4. Download `google-services.json` and place it in the `app/` directory
5. Enable Cloud Messaging in Firebase Console

### 3. Build and Run

1. Open the project in Android Studio
2. Sync Gradle files
3. Build the project
4. Run on a real device (push notifications don't work on emulator)

### 4. Configuration

Update the API key in `MainActivity.kt`:

```kotlin
private const val API_KEY = "your_actual_api_key_here"
```

## Project Structure

```
push_test_android_example/
├── app/
│   ├── src/main/
│   │   ├── java/com/example/push_test_android_example/
│   │   │   ├── MainActivity.kt
│   │   │   └── GoMailerFirebaseMessagingService.kt
│   │   ├── res/layout/
│   │   │   └── activity_main.xml
│   │   └── AndroidManifest.xml
│   └── build.gradle
├── build.gradle
├── settings.gradle
└── gradle/wrapper/
    └── gradle-wrapper.properties
```

## Dependencies

- **Go-Mailer SDK**: Local library module
- **Firebase**: FCM for push notifications
- **OkHttp**: HTTP client for API calls
- **Kotlin Coroutines**: Async operations

## Usage

1. **Initialize SDK**: The SDK is automatically initialized when the app starts
2. **Request Permission**: Tap "Request Notification Permission" to grant notification access
3. **Enter Email**: Type your email address in the input field
4. **Send User Data**: Tap "Send User Data to Backend" to register with the backend
5. **Get Device Token**: Tap "Get Device Token" to see the FCM token
6. **Test Notifications**: Send push notifications from your backend to test

## Troubleshooting

### Common Issues

1. **Build Errors**: Make sure all dependencies are synced
2. **FCM Token Not Received**: Check Firebase configuration and internet connection
3. **Notifications Not Showing**: Verify notification permissions are granted
4. **Backend Connection Failed**: Check API key and network connectivity

### Logs

Check Logcat for detailed logs:
- Tag: `MainActivity` - App-level logs
- Tag: `GoMailerManager` - SDK logs
- Tag: `GoMailerFCMService` - FCM service logs

## Next Steps

1. Test the basic functionality
2. Customize the UI and user experience
3. Implement custom notification handling
4. Add analytics and tracking
5. Integrate with your backend services

## Support

For issues or questions, check the main Go-Mailer documentation or create an issue in the repository. 