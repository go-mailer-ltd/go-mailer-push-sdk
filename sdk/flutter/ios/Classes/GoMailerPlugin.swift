import Flutter
import UIKit
import UserNotifications

public class GoMailerPlugin: NSObject, FlutterPlugin, UNUserNotificationCenterDelegate, FlutterStreamHandler {
  var deviceTokenResult: FlutterResult?
  var email: String?
  var apiKey: String?
  var currentDeviceToken: String?
  var baseUrl: String = "https://api.go-mailer.com/v1"
  private var eventSink: FlutterEventSink?
  // Reliability state
  private var pendingEvents: [(name: String, properties: [String: Any]?, email: String)] = []
  private let backoffMaxAttempts = 5
  private let backoffBaseDelay: Double = 0.5 // seconds
  private let backoffFactor: Double = 2.0
  private let backoffJitter: Double = 0.15 // seconds
  private let sdkVersion = "1.3.0"
  private let maxPendingEvents = 100

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "go_mailer", binaryMessenger: registrar.messenger())
    let instance = GoMailerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    
  // Register event channel for push notification events
  let eventChannel = FlutterEventChannel(name: "go_mailer_events", binaryMessenger: registrar.messenger())
  eventChannel.setStreamHandler(instance)
    
    NotificationCenter.default.addObserver(
      instance,
      selector: #selector(instance.didRegisterForRemoteNotifications(_:)),
      name: NSNotification.Name("GoMailerDidRegisterForRemoteNotifications"),
      object: nil
    )
    
    NotificationCenter.default.addObserver(
      instance,
      selector: #selector(instance.didFailToRegisterForRemoteNotifications(_:)),
      name: NSNotification.Name("GoMailerDidFailToRegisterForRemoteNotifications"),
      object: nil
    )
    // Restore any persisted queued events
    instance.restorePendingEventsIfNeeded()
  }

  // MARK: - FlutterStreamHandler
  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    debugPrint("📬 EventChannel: onListen called")
    self.eventSink = events
    emitEvent(type: "stream_ready", data: [:])
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    debugPrint("📬 EventChannel: onCancel called")
    self.eventSink = nil
    return nil
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
  switch call.method {
    case "initialize":
      debugPrint("🚀 Initializing Go Mailer plugin")
      if let args = call.arguments as? [String: Any] {
        self.apiKey = args["apiKey"] as? String
        if let key = self.apiKey {
          let masked = key.count > 6 ? String(key.prefix(6)) + "***" : key
          debugPrint("✅ API Key set (masked): \(masked)")
        } else {
          debugPrint("✅ API Key set (masked): null")
        }
        
        if let config = args["config"] as? [String: Any],
           let configBaseUrl = config["baseUrl"] as? String {
          self.baseUrl = configBaseUrl
          debugPrint("🌐 Base URL set: \(self.baseUrl)")
        }
      }
  emitEvent(type: "initialized", data: ["baseUrl": baseUrl, "email": email ?? ""])    
  result(nil)
      
    case "registerForPushNotifications":
      debugPrint("📱 Registering for push notifications")
      self.deviceTokenResult = result
      if let args = call.arguments as? [String: Any] {
        self.email = args["email"] as? String
  debugPrint("📧 Email set for registration: \(maskEmail(self.email))")
      }
      
      UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
        if granted {
          debugPrint("✅ Notification permission granted")
          DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
            let center = UNUserNotificationCenter.current()
            center.delegate = self
          }
        } else {
          debugPrint("❌ Notification permission denied: \(error?.localizedDescription ?? "Unknown")")
          result(FlutterError(
            code: "PERMISSION_DENIED",
            message: "User denied notification permission",
            details: error?.localizedDescription
          ))
        }
      }
      
    case "setUser":
      debugPrint("👤 Setting user data")
      if let args = call.arguments as? [String: Any] {
        self.email = args["email"] as? String
  debugPrint("📧 User email set: \(maskEmail(self.email))")
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
  debugPrint("📊 Event: \(eventName), Properties: \(properties ?? [:]), email=\(maskEmail(self.email))")
        queueOrSendEvent(name: eventName, properties: properties, email: self.email ?? "")
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
      
    case "flushPendingEvents":
      flushPendingEvents()
      result(nil)
    case "getSdkInfo":
      let info: [String: Any] = [
        "version": sdkVersion,
        "baseUrl": baseUrl,
        "email": email ?? "",
        "deviceToken": currentDeviceToken ?? ""
      ]
      result(info)
    default:
      debugPrint("❌ Method not implemented: \(call.method)")
      result(FlutterMethodNotImplemented)
    }
  }

  @objc func didRegisterForRemoteNotifications(_ notification: Notification) {
    guard let deviceToken = notification.userInfo?["deviceToken"] as? Data else {
      debugPrint("❌ No device token in notification")
      deviceTokenResult?(FlutterError(code: "NO_TOKEN", message: "No device token", details: nil))
      return
    }
    
    let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
    let token = tokenParts.joined()
    
    currentDeviceToken = token
    debugPrint("✅ Device token received: \(token.prefix(20))...")
    
    deviceTokenResult?(token)
    deviceTokenResult = nil
    
    // Send token event to Flutter if listener is active
    emitEvent(type: "registered", data: ["deviceToken": token, "email": email ?? ""])    
    
    sendDeviceTokenToServer(token: token, email: self.email ?? "")
  }

  @objc func didFailToRegisterForRemoteNotifications(_ notification: Notification) {
    let error = notification.userInfo?["error"] as? Error
    deviceTokenResult?(
      FlutterError(
        code: "REGISTER_FAILED",
        message: "Failed to register for remote notifications",
        details: error?.localizedDescription
      )
    )
    deviceTokenResult = nil
    
    emitEvent(type: "register_failed", data: ["error": error?.localizedDescription ?? "unknown"])    
  }

  func sendDeviceTokenToServer(token: String, email: String) {
    let bundleId = Bundle.main.bundleIdentifier ?? "unknown.bundle"
    let payload: [String: Any] = [
      "email": email,
      "maskedEmail": maskEmail(email),
      "gm_mobi_push": [
        "deviceToken": token,
        "platform": "ios",
        "bundleId": bundleId,
        "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown",
        "timestamp": ISO8601DateFormatter().string(from: Date())
      ]
    ]
    let url = URL(string: "\(baseUrl)/contacts")!
    var req = URLRequest(url: url)
    req.httpMethod = "POST"
    req.setValue("application/json", forHTTPHeaderField: "Content-Type")
    if let apiKey = apiKey { req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization") }
    req.httpBody = try? JSONSerialization.data(withJSONObject: payload)
    performRequestWithBackoff(label: "token_registration", requestBuilder: { return req }) { success, terminal in
      if !success && terminal {
        self.emitEvent(type: "token_failed", data: [:])
      } else if success {
        // Flush any queued events now that token registered
        self.flushPendingEvents()
      }
    }
  }
  
  func sendEventToServer(eventName: String, properties: [String: Any]?, email: String) {
    let bundleId = Bundle.main.bundleIdentifier ?? "unknown.bundle"
    let body: [String: Any] = [
      "email": email,
      "maskedEmail": maskEmail(email),
      "eventName": eventName,
      "properties": properties ?? [:],
      "platform": "ios",
      "bundleId": bundleId,
      "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown",
      "timestamp": ISO8601DateFormatter().string(from: Date())
    ]
    let url = URL(string: "\(baseUrl)/events/push")!
    var req = URLRequest(url: url)
    req.httpMethod = "POST"
    req.setValue("application/json", forHTTPHeaderField: "Content-Type")
    if let apiKey = apiKey { req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization") }
    req.httpBody = try? JSONSerialization.data(withJSONObject: body)
    performRequestWithBackoff(label: "event_\(eventName)", requestBuilder: { return req }) { success, terminal in
      if success {
        self.emitEvent(type: "event_tracked", data: ["event": eventName])
      } else if terminal {
        self.emitEvent(type: "event_failed", data: ["event": eventName])
      }
    }
  }
  
  // MARK: - UNUserNotificationCenterDelegate
  
  public func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    debugPrint("📱 Notification received while app is in foreground")
    completionHandler([.alert, .badge, .sound])
  }
  
  public func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    debugPrint("📱 Notification tapped")
    
  let notification = response.notification
    let userInfo = notification.request.content.userInfo
    let notificationId = userInfo["notification_id"] as? String ?? "unknown"
    let title = notification.request.content.title
    let body = notification.request.content.body
    
    debugPrint("📱 Notification details - ID: \(notificationId), Title: \(title ?? "Unknown")")
    
    let properties: [String: Any] = [
      "notification_id": notificationId,
      "notification_title": title ?? "Unknown",
      "notification_body": body ?? "",
      "action_identifier": response.actionIdentifier,
      "user_info": userInfo,
      "click_timestamp": ISO8601DateFormatter().string(from: Date())
    ]
    
    sendEventToServer(eventName: "notification_clicked", properties: properties, email: self.email ?? "")

    // Forward event to Flutter listeners
    emitEvent(type: "notification_clicked", data: [
      "id": notificationId,
      "title": title ?? "",
      "body": body ?? "",
      "userInfo": userInfo
    ])
    
    completionHandler()
  }
}

// MARK: - Reliability Helpers
extension GoMailerPlugin {
  private func emitEvent(type: String, data: [String: Any]) {
    guard let sink = eventSink else { return }
    DispatchQueue.main.async { sink(["type": type, "data": data]) }
  }

  private func queueOrSendEvent(name: String, properties: [String: Any]?, email: String) {
    if currentDeviceToken == nil { // queue
      var dropped: (name: String, properties: [String: Any]?, email: String)? = nil
      if pendingEvents.count >= maxPendingEvents {
        dropped = pendingEvents.removeFirst()
      }
      pendingEvents.append((name: name, properties: properties, email: email))
      persistPendingEvents()
      if let d = dropped { emitEvent(type: "event_dropped", data: ["event": d.name, "reason": "queue_full"]) }
      emitEvent(type: "event_queued", data: ["event": name])
    } else {
      sendEventToServer(eventName: name, properties: properties, email: email)
    }
  }

  private func maskEmail(_ email: String?) -> String {
    guard let email = email, !email.isEmpty else { return "" }
    let parts = email.split(separator: "@")
    guard let first = parts.first else { return "" }
    let local = String(first)
    let maskedLocal: String
    switch local.count {
      case 0: maskedLocal = ""
      case 1: maskedLocal = "*"
      case 2: maskedLocal = String(local.prefix(1)) + "*"
      default: maskedLocal = String(local.prefix(2)) + "***"
    }
    if parts.count > 1 { return maskedLocal + "@" + parts[1] } else { return maskedLocal }
  }

  func flushPendingEvents() {
    guard currentDeviceToken != nil, !pendingEvents.isEmpty else { return }
    let toSend = pendingEvents; pendingEvents.removeAll(); persistPendingEvents()
    toSend.forEach { tuple in
      sendEventToServer(eventName: tuple.name, properties: tuple.properties, email: tuple.email)
    }
  }

  private func performRequestWithBackoff(label: String, requestBuilder: @escaping () -> URLRequest, completion: @escaping (_ success: Bool, _ terminal: Bool) -> Void) {
    func attempt(_ n: Int) {
      let req = requestBuilder() // copy to avoid capture semantics issues
      let currentAttempt = n
      let task = URLSession.shared.dataTask(with: req) { data, response, error in
        if let error = error {
          if currentAttempt >= self.backoffMaxAttempts { completion(false, true); return }
          scheduleRetry(n: currentAttempt)
          return
        }
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        if (200..<300).contains(status) {
          completion(true, false)
        } else {
          // retry on 429 or 5xx
          if (status == 429 || status >= 500) && currentAttempt < self.backoffMaxAttempts {
            scheduleRetry(n: currentAttempt)
          } else {
            completion(false, true)
          }
        }
      }
      task.resume()
    }
    func scheduleRetry(n: Int) {
      let base = self.backoffBaseDelay * pow(self.backoffFactor, Double(n - 1))
      let jitter = Double.random(in: 0...self.backoffJitter)
      let delay = min(base + jitter, 10.0)
      DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
        attempt(n + 1)
      }
    }
    attempt(1)
  }

  // MARK: - Persistence (UserDefaults)
  private var pendingKey: String { return "gomailer.pending.events" }

  private func persistPendingEvents() {
    do {
      let arr: [[String: Any]] = pendingEvents.map { e in
        [
          "name": e.name,
          "email": e.email,
          "properties": e.properties ?? [:]
        ]
      }
      let data = try JSONSerialization.data(withJSONObject: arr, options: [])
      UserDefaults.standard.set(data, forKey: pendingKey)
    } catch {
      debugPrint("⚠️ Failed to persist pending events: \(error)")
    }
  }

  private func restorePendingEventsIfNeeded() {
    guard pendingEvents.isEmpty, let data = UserDefaults.standard.data(forKey: pendingKey) else { return }
    do {
      let raw = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] ?? []
      let restored = raw.map { dict -> (name: String, properties: [String: Any]?, email: String) in
        let name = dict["name"] as? String ?? "unknown"
        let email = dict["email"] as? String ?? ""
        let props = dict["properties"] as? [String: Any]
        return (name: name, properties: props, email: email)
      }
      if !restored.isEmpty {
        pendingEvents.append(contentsOf: restored)
        debugPrint("🔁 Restored \(restored.count) pending events from disk")
      }
    } catch {
      debugPrint("⚠️ Failed to restore pending events: \(error)")
    }
  }
}

// Ensure restoration on class load
extension GoMailerPlugin {
  static func initializePersistence() { /* reserved */ }
}
