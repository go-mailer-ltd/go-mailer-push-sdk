import Flutter
import UIKit

public class GoMailerPlugin: NSObject, FlutterPlugin, UNUserNotificationCenterDelegate {
  var deviceTokenResult: FlutterResult?
  var email: String?
  var apiKey: String?
  var currentDeviceToken: String?
  var baseUrl: String = "https://api.go-mailer.com/v1"

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "go_mailer", binaryMessenger: registrar.messenger())
    let instance = GoMailerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    // Register for remote notification callbacks
    NotificationCenter.default.addObserver(
      instance, selector: #selector(instance.didRegisterForRemoteNotifications(_:)),
      name: NSNotification.Name("GoMailerDidRegisterForRemoteNotifications"), object: nil)
    NotificationCenter.default.addObserver(
      instance, selector: #selector(instance.didFailToRegisterForRemoteNotifications(_:)),
      name: NSNotification.Name("GoMailerDidFailToRegisterForRemoteNotifications"), object: nil)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "initialize":
      debugPrint("🚀 Initializing Go Mailer plugin")
      if let args = call.arguments as? [String: Any] {
        self.apiKey = args["apiKey"] as? String
        debugPrint("✅ API Key set: \(String(describing: self.apiKey?.prefix(10)))...")
        
        // Extract baseUrl from config if provided
        if let config = args["config"] as? [String: Any],
           let configBaseUrl = config["baseUrl"] as? String {
          self.baseUrl = configBaseUrl
          debugPrint("🌐 Base URL set: \(self.baseUrl)")
        }
      }
      result(nil)
      
    case "registerForPushNotifications":
      debugPrint("📱 Registering for push notifications")
      self.deviceTokenResult = result
      if let args = call.arguments as? [String: Any] {
        self.email = args["email"] as? String
        debugPrint("📧 Email set for registration: \(self.email ?? "nil")")
      }
      
      UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
        if granted {
          debugPrint("✅ Notification permission granted")
          DispatchQueue.main.async {
            // Register for remote notifications with the correct topic
            let application = UIApplication.shared
            application.registerForRemoteNotifications()
            
            // Set up notification categories if needed
            let center = UNUserNotificationCenter.current()
            center.delegate = self
          }
        } else {
          debugPrint("❌ Notification permission denied: \(error?.localizedDescription ?? "Unknown")")
          result(FlutterError(
            code: "PERMISSION_DENIED", 
            message: "User denied notification permission",
            details: error?.localizedDescription))
        }
      }
      
    case "setUser":
      debugPrint("👤 Setting user data")
      if let args = call.arguments as? [String: Any] {
        self.email = args["email"] as? String
        debugPrint("📧 User email set: \(self.email ?? "nil")")
      }
      result(nil)
      
    case "getDeviceToken":
      debugPrint("🔑 Getting device token")
      if let token = currentDeviceToken {
        debugPrint("✅ Returning stored device token: \(token.prefix(20))...")
        result(token)
      } else {
        debugPrint("⚠️ No device token available yet")
        result(nil)
      }
      
    case "trackEvent":
      debugPrint("📊 Tracking event")
      if let args = call.arguments as? [String: Any] {
        let eventName = args["eventName"] as? String ?? "unknown"
        let properties = args["properties"] as? [String: Any]
        debugPrint("📊 Event: \(eventName), Properties: \(properties ?? [:])")
        
        // Send event to backend
        sendEventToServer(eventName: eventName, properties: properties, email: self.email ?? "")
      }
      result(nil)
      
    case "setUserAttributes":
      debugPrint("🏷️ Setting user attributes")
      result(nil)
      
    case "addUserTags":
      debugPrint("➕ Adding user tags")
      result(nil)
      
    case "removeUserTags":
      debugPrint("➖ Removing user tags")
      result(nil)
      
    case "setAnalyticsEnabled":
      debugPrint("📈 Setting analytics enabled")
      result(nil)
      
    case "setLogLevel":
      debugPrint("📝 Setting log level")
      result(nil)
      
    default:
      debugPrint("❌ Method not implemented: \(call.method)")
      result(FlutterMethodNotImplemented)
    }
  }

  // These methods should be called from AppDelegate
  @objc func didRegisterForRemoteNotifications(_ notification: Notification) {
    guard let deviceToken = notification.userInfo?["deviceToken"] as? Data else {
      debugPrint("❌ No device token in notification")
      deviceTokenResult?(FlutterError(code: "NO_TOKEN", message: "No device token", details: nil))
      return
    }
    
    let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
    let token = tokenParts.joined()
    
    // Store the device token
    currentDeviceToken = token
    debugPrint("✅ Device token received and stored: \(token.prefix(20))...")
    
    // Return the token to Flutter
    deviceTokenResult?(token)
    deviceTokenResult = nil
    
    // Send to server
    sendDeviceTokenToServer(token: token, email: self.email ?? "")
  }

  @objc func didFailToRegisterForRemoteNotifications(_ notification: Notification) {
    let error = notification.userInfo?["error"] as? Error
    deviceTokenResult?(
      FlutterError(
        code: "REGISTER_FAILED", message: "Failed to register for remote notifications",
        details: error?.localizedDescription))
    deviceTokenResult = nil
  }

  func sendDeviceTokenToServer(token: String, email: String) {
    // Use the correct endpoint for registering contacts
    let url = URL(string: "\(baseUrl)/contacts")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    if let apiKey = self.apiKey {
      request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    }
    
    // Use the correct payload structure that matches the backend API
    let bundleId = Bundle.main.bundleIdentifier ?? "com.gomailer.pushTestFlutterExample"
    let body: [String: Any] = [
      "email": email,
      "gm_mobi_push": [
        "deviceToken": token,
        "platform": "ios",
        "bundleId": bundleId,
        "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
      ]
    ]
    
    request.httpBody = try? JSONSerialization.data(withJSONObject: body)
    
    debugPrint("📤 Sending device token to backend: \(url)")
    debugPrint("📦 Payload: \(body)")
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
      if let error = error {
        debugPrint("❌ Failed to send device token: \(error)")
      } else if let httpResponse = response as? HTTPURLResponse {
        debugPrint("✅ Device token sent to server. Status: \(httpResponse.statusCode)")
        if let data = data, let responseString = String(data: data, encoding: .utf8) {
          debugPrint("📥 Response: \(responseString)")
        }
      }
    }
    task.resume()
  }
  
  func sendEventToServer(eventName: String, properties: [String: Any]?, email: String) {
    // Use the events endpoint for tracking analytics events
    let url = URL(string: "\(baseUrl)/events/push")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    if let apiKey = self.apiKey {
      request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    }
    
    // Create event payload
    let bundleId = Bundle.main.bundleIdentifier ?? "com.gomailer.pushTestFlutterExample"
    let body: [String: Any] = [
      "email": email,
      "eventName": eventName,
      "properties": properties ?? [:],
      "platform": "ios",
      "bundleId": bundleId,
      "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown",
      "timestamp": ISO8601DateFormatter().string(from: Date())
    ]
    
    request.httpBody = try? JSONSerialization.data(withJSONObject: body)
    
    debugPrint("📊 Sending event to backend: \(url)")
    debugPrint("📦 Event payload: \(body)")
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
      if let error = error {
        debugPrint("❌ Failed to send event: \(error)")
      } else if let httpResponse = response as? HTTPURLResponse {
        debugPrint("✅ Event sent to server. Status: \(httpResponse.statusCode)")
        if let data = data, let responseString = String(data: data, encoding: .utf8) {
          debugPrint("📥 Response: \(responseString)")
        }
      }
    }
    task.resume()
  }
  
  // MARK: - UNUserNotificationCenterDelegate
  
  public func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    debugPrint("📱 Notification received while app is in foreground")
    // Show the notification even when app is in foreground
    completionHandler([.alert, .badge, .sound])
  }
  
  public func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    debugPrint("📱 Notification tapped")
    
    // Extract notification data
    let notification = response.notification
    let userInfo = notification.request.content.userInfo
    let notificationId = userInfo["notification_id"] as? String ?? "unknown"
    let title = notification.request.content.title ?? "Unknown"
    let body = notification.request.content.body ?? ""
    
    debugPrint("📱 Notification details - ID: \(notificationId), Title: \(title)")
    
    // Track notification click event
    let properties: [String: Any] = [
      "notification_id": notificationId,
      "notification_title": title,
      "notification_body": body,
      "action_identifier": response.actionIdentifier,
      "user_info": userInfo,
      "click_timestamp": ISO8601DateFormatter().string(from: Date())
    ]
    
    sendEventToServer(eventName: "notification_clicked", properties: properties, email: self.email ?? "")
    
    completionHandler()
  }
}
