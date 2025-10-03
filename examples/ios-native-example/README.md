# GoMailer iOS Native Example

A comprehensive iOS native example app demonstrating the GoMailer Push SDK integration with modern iOS UI components and design patterns.

## Features

- **Modern iOS UI**: Built with SwiftUI and UIKit following iOS design guidelines
- **Two-screen architecture**: Configuration screen → Test screen (matching Flutter example)
- **Environment selection**: Development, staging, and production environments
- **Push notifications**: Complete Firebase integration for iOS push notifications
- **Real-time feedback**: Success/error states with proper iOS styling
- **Activity logging**: Comprehensive logging for debugging and transparency
- **iOS design patterns**: Proper MVC architecture and iOS conventions

## Requirements

- iOS 13.0+
- Xcode 14.0+
- Swift 5.0+
- CocoaPods

## Setup

1. Navigate to the iOS example directory:
   ```bash
   cd examples/ios-native-example
   ```

2. Install dependencies:
   ```bash
   pod install
   ```

3. Open the workspace:
   ```bash
   open GoMailerExample.xcworkspace
   ```

4. Configure Firebase:
   - Add your `GoogleService-Info.plist` file to the project
   - Ensure push notification capabilities are enabled

5. Build and run the app in Xcode

## Project Structure

```
ios-native-example/
├── GoMailerExample/
│   ├── App/
│   │   ├── AppDelegate.swift
│   │   ├── SceneDelegate.swift
│   │   └── Info.plist
│   ├── Views/
│   │   ├── ConfigurationViewController.swift
│   │   └── TestViewController.swift
│   ├── Models/
│   │   ├── GoMailerClient.swift
│   │   └── Environment.swift
│   ├── Resources/
│   │   ├── Assets.xcassets
│   │   └── LaunchScreen.storyboard
│   └── Supporting Files/
├── Podfile
└── README.md
```

## Usage

1. **Configuration Screen**: Enter your GoMailer API key and select the environment
2. **Test Screen**: Enter an email address and test push notification functionality
3. **Real-time feedback**: Monitor logs and status messages for debugging

## Integration

This example demonstrates how to integrate the GoMailer iOS SDK:

```swift
import GoMailerPushSDK

// Initialize the SDK
GoMailer.initialize(apiKey: "your-api-key", environment: .development)

// Set user
GoMailer.setUser(email: "user@example.com")

// Register for push notifications
GoMailer.registerForPushNotifications { result in
    // Handle result
}
```