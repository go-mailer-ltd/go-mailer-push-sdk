# iOS SDK Setup Guide

This guide will walk you through integrating the Go Mailer SDK into your native iOS application.

## 📋 Prerequisites

- iOS 12.0 or higher
- Xcode 14.0 or higher
- Swift 5.0 or higher
- Go-Mailer API key
- Apple Developer Account (for push notifications)

## 🔧 Installation Steps

### Step 1: Install via CocoaPods

Add the Go Mailer SDK to your `Podfile`:

```ruby
# Podfile
platform :ios, '12.0'

target 'YourApp' do
  use_frameworks!
  
  # Go Mailer SDK
  pod 'GoMailer', '~> 1.0.0'  # From CocoaPods when published
  # OR for local development:
  # pod 'GoMailer', :path => '../path/to/sdk/ios'
  
  # Firebase for push notifications
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
end
```

Install dependencies:
```bash
cd ios
pod install
```

### Step 2: Firebase Setup

1. **Create Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Create a new project or use existing one
   - Add iOS app with your Bundle ID

2. **Download Configuration**
   - Download `GoogleService-Info.plist`
   - Add to your Xcode project (drag and drop, ensure it's added to target)

3. **Initialize Firebase**

   **`AppDelegate.swift`:**
   ```swift
   import UIKit
   import Firebase
   import GoMailer

   @main
   class AppDelegate: UIResponder, UIApplicationDelegate {

       func application(_ application: UIApplication, 
                       didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
           
           // Configure Firebase
           FirebaseApp.configure()
           
           // Initialize Go Mailer
           initializeGoMailer()
           
           return true
       }
       
       private func initializeGoMailer() {
           let config = GoMailerConfig()
           config.baseURL = "https://api.go-mailer.com/v1"
           config.enableAnalytics = true
           config.logLevel = .error // Use .error for production
           
           GoMailer.initialize(apiKey: "your_production_api_key", config: config)
       }
   }
   ```

### Step 3: Push Notification Setup

#### Enable Push Notifications in Xcode

1. **Add Capabilities:**
   - Select your project target
   - Go to "Signing & Capabilities"
   - Add "Push Notifications" capability
   - Add "Background Modes" capability
   - Check "Background App Refresh"

#### Configure APNs

1. **Create APNs Key (Recommended):**
   - Go to [Apple Developer Console](https://developer.apple.com)
   - Certificates, Identifiers & Profiles → Keys
   - Create new key with "Apple Push Notifications service (APNs)" enabled
   - Download the `.p8` file and note the Key ID and Team ID

2. **Upload to Firebase:**
   - In Firebase Console → Project Settings → Cloud Messaging
   - Upload your APNs key (.p8 file)
   - Enter Key ID and Team ID

#### Update AppDelegate for Push Notifications

```swift
import UIKit
import Firebase
import GoMailer
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, 
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Configure Firebase
        FirebaseApp.configure()
        
        // Set up notifications
        setupNotifications()
        
        // Initialize Go Mailer
        initializeGoMailer()
        
        return true
    }
    
    private func setupNotifications() {
        UNUserNotificationCenter.current().delegate = self
        
        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    private func initializeGoMailer() {
        let config = GoMailerConfig()
        config.baseURL = "https://api.go-mailer.com/v1"
        config.enableAnalytics = true
        config.logLevel = .error // Use .error for production
        
        GoMailer.initialize(apiKey: "your_production_api_key", config: config)
    }
    
    // MARK: - Push Notification Delegates
    
    func application(_ application: UIApplication, 
                    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // This is handled automatically by Go Mailer SDK
        print("✅ Device token registered successfully")
    }
    
    func application(_ application: UIApplication, 
                    didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ Failed to register for remote notifications: \(error)")
    }
    
    // Handle notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                               willPresent notification: UNNotification, 
                               withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.alert, .badge, .sound])
    }
    
    // Handle notification tap - this is handled automatically by Go Mailer SDK
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                               didReceive response: UNNotificationResponse, 
                               withCompletionHandler completionHandler: @escaping () -> Void) {
        // Notification click tracking is handled automatically by Go Mailer SDK
        completionHandler()
    }
}
```

## 🚀 Basic Implementation

### Complete Example

```swift
import UIKit
import GoMailer

class ViewController: UIViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var initializeButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var trackEventButton: UIButton!
    
    private var isInitialized = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        statusLabel.text = "Not initialized"
        registerButton.isEnabled = false
        trackEventButton.isEnabled = false
    }
    
    @IBAction func initializeButtonTapped(_ sender: UIButton) {
        initializeGoMailer()
    }
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        setUserAndRegister()
    }
    
    @IBAction func trackEventButtonTapped(_ sender: UIButton) {
        trackCustomEvent()
    }
    
    private func initializeGoMailer() {
        statusLabel.text = "Initializing..."
        
        let config = GoMailerConfig()
        config.baseURL = "https://api.go-mailer.com/v1"
        config.enableAnalytics = true
        config.logLevel = .info // Use .error for production
        
        GoMailer.initialize(apiKey: "your_production_api_key", config: config)
        
        // SDK initialization is synchronous, but we simulate async for UI
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isInitialized = true
            self.statusLabel.text = "SDK initialized successfully"
            self.initializeButton.isEnabled = false
            self.registerButton.isEnabled = true
            self.trackEventButton.isEnabled = true
            
            print("✅ Go Mailer initialized successfully")
        }
    }
    
    private func setUserAndRegister() {
        guard isInitialized else { return }
        
        statusLabel.text = "Setting user..."
        
        // Set user data
        let user = GoMailerUser(
            email: "user@example.com",
            attributes: [
                "firstName": "John",
                "lastName": "Doe",
                "subscription_tier": "premium"
            ],
            tags: ["vip", "mobile_user"]
        )
        
        GoMailer.setUser(user)
        
        // Register for push notifications
        GoMailer.registerForPushNotifications()
        
        statusLabel.text = "User registered for notifications"
        print("✅ User registered successfully")
    }
    
    private func trackCustomEvent() {
        guard isInitialized else { return }
        
        let properties: [String: Any] = [
            "action_type": "button_click",
            "screen": "main",
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        
        GoMailer.trackEvent("user_action", properties: properties)
        
        let alert = UIAlertController(title: "Success", 
                                    message: "Custom event tracked!", 
                                    preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
        
        print("✅ Custom event tracked")
    }
}
```

### SwiftUI Implementation

```swift
import SwiftUI
import GoMailer

struct ContentView: View {
    @State private var isInitialized = false
    @State private var status = "Not initialized"
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Go Mailer iOS Demo")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Status:")
                    .fontWeight(.bold)
                Text(status)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            Button("Initialize Go Mailer") {
                initializeGoMailer()
            }
            .disabled(isInitialized)
            
            Button("Set User & Register") {
                setUserAndRegister()
            }
            .disabled(!isInitialized)
            
            Button("Track Custom Event") {
                trackCustomEvent()
            }
            .disabled(!isInitialized)
            
            Spacer()
        }
        .padding()
    }
    
    private func initializeGoMailer() {
        status = "Initializing..."
        
        let config = GoMailerConfig()
        config.baseURL = "https://api.go-mailer.com/v1"
        config.enableAnalytics = true
        config.logLevel = .error // Use .error for production
        
        GoMailer.initialize(apiKey: "your_production_api_key", config: config)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isInitialized = true
            status = "SDK initialized successfully"
            print("✅ Go Mailer initialized successfully")
        }
    }
    
    private func setUserAndRegister() {
        guard isInitialized else { return }
        
        status = "Setting user..."
        
        let user = GoMailerUser(
            email: "user@example.com",
            attributes: ["firstName": "John", "lastName": "Doe"],
            tags: ["vip", "mobile_user"]
        )
        
        GoMailer.setUser(user)
        GoMailer.registerForPushNotifications()
        
        status = "User registered for notifications"
        print("✅ User registered successfully")
    }
    
    private func trackCustomEvent() {
        guard isInitialized else { return }
        
        let properties: [String: Any] = [
            "action_type": "button_click",
            "screen": "main",
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        
        GoMailer.trackEvent("user_action", properties: properties)
        print("✅ Custom event tracked")
    }
}
```

## 📱 Notification Click Tracking

### Automatic Click Tracking

The iOS SDK automatically handles notification click tracking. When a user taps on a notification:

1. The system calls the notification delegate methods
2. Go Mailer SDK automatically extracts notification data
3. Sends a `notification_clicked` event to your backend
4. Includes notification ID, title, body, and timestamp

### Custom Notification Data

To include custom notification IDs in your server-sent notifications:

**APNs Payload Example:**
```json
{
  "aps": {
    "alert": {
      "title": "Welcome!",
      "body": "Thanks for using our app"
    },
    "badge": 1,
    "sound": "default"
  },
  "notification_id": "custom_123456",
  "campaign_id": "welcome_series_1",
  "user_segment": "new_users"
}
```

The SDK will automatically use `notification_id` from the payload, or fall back to the system-generated identifier.

## 🔧 Advanced Configuration

### Custom Configuration Options

```swift
let config = GoMailerConfig()
config.baseURL = "https://api.go-mailer.com/v1"
config.enableAnalytics = true
config.logLevel = .error // .debug, .info, .warning, .error

GoMailer.initialize(apiKey: "your_api_key", config: config)
```

### User Management

```swift
// Set user with all attributes
let user = GoMailerUser(
    email: "user@example.com",
    attributes: [
        "firstName": "John",
        "lastName": "Doe",
        "subscription_tier": "premium",
        "last_purchase_date": "2024-01-15",
        "total_purchases": 25
    ],
    tags: ["vip", "mobile_user", "ios"]
)

GoMailer.setUser(user)

// Update user attributes
GoMailer.setUserAttributes([
    "last_login": ISO8601DateFormatter().string(from: Date()),
    "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
])

// Add/remove tags
GoMailer.addUserTags(["premium_subscriber"])
GoMailer.removeUserTags(["trial_user"])
```

### Event Tracking

```swift
// Track events with properties
GoMailer.trackEvent("product_viewed", properties: [
    "product_id": "12345",
    "category": "electronics",
    "price": 299.99,
    "currency": "USD"
])

// Track user actions
GoMailer.trackEvent("button_clicked", properties: [
    "button_name": "checkout",
    "screen": "product_detail",
    "timestamp": ISO8601DateFormatter().string(from: Date())
])
```

### Device Token Management

```swift
// Get current device token
if let token = GoMailer.getDeviceToken() {
    print("Current device token: \(token)")
}

// Listen for token updates
NotificationCenter.default.addObserver(
    forName: NSNotification.Name("GoMailerDeviceTokenUpdated"),
    object: nil,
    queue: .main
) { notification in
    if let token = notification.userInfo?["token"] as? String {
        print("Device token updated: \(token)")
    }
}
```

## ✅ Production Checklist

### Before App Store Submission

- [ ] Replace test API key with production API key
- [ ] Set `config.logLevel = .error` for production
- [ ] Configure production APNs certificates/keys
- [ ] Test on physical devices (push notifications don't work in simulator)
- [ ] Test notification delivery and click tracking
- [ ] Verify user registration flow
- [ ] Test app launch from notifications
- [ ] Review and test all notification scenarios

### APNs Configuration

- [ ] Create and configure APNs authentication key
- [ ] Upload APNs key to Firebase Console
- [ ] Test with Firebase Console first
- [ ] Verify production vs development certificates
- [ ] Test on TestFlight build

### App Store Requirements

- [ ] Add notification usage description to Info.plist
- [ ] Test notification permission request flow
- [ ] Ensure graceful handling of permission denial
- [ ] Test app functionality without notifications enabled

### Info.plist Configuration

```xml
<!-- Info.plist -->
<key>NSUserNotificationUsageDescription</key>
<string>This app uses notifications to keep you updated with important information.</string>

<key>UIBackgroundModes</key>
<array>
    <string>background-fetch</string>
</array>
```

## 🐛 Troubleshooting

### Common Issues

**1. SDK Not Found**
```
Solution: Ensure pod install completed successfully
cd ios && pod install
```

**2. Notifications Not Received**
```
Solution:
- Check APNs configuration in Firebase
- Verify device is registered for notifications
- Test with Firebase Console first
- Check device token is valid
```

**3. Build Errors**
```
Solution:
- Clean build folder (Cmd+Shift+K)
- Delete derived data
- Re-run pod install
```

**4. Notification Click Not Tracked**
```
Solution:
- Verify AppDelegate implements UNUserNotificationCenterDelegate
- Check notification payload includes notification_id
- Review console logs for tracking events
```

### Debug Information

Enable debug logging to troubleshoot:

```swift
let config = GoMailerConfig()
config.logLevel = .debug // Enable debug logs
GoMailer.initialize(apiKey: "your_api_key", config: config)
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
2. **Examples**: Review the [example applications](../../examples/push_test_ios_example/)
3. **Issues**: Open an issue on [GitHub](https://github.com/go-mailer/go-mailer-mobile-push)
4. **Email**: Contact support@gomailer.com

---

**✅ You're all set!** Your iOS app should now be ready to receive and track push notifications with Go Mailer.