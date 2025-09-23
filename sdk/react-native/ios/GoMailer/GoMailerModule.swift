import Foundation
import React
import UserNotifications

@objc(GoMailerModule)
class GoMailerModule: RCTEventEmitter {
    
    private var apiKey: String?
    private var baseUrl: String = "https://api.go-mailer.com/v1"
    private var deviceToken: String?
    private var userEmail: String?
    
    override init() {
        super.init()
        print("🔵 GoMailerModule: Initialized")
    }
    
    @objc
    override static func requiresMainQueueSetup() -> Bool {
        return false
    }
    
    @objc
    override func supportedEvents() -> [String]! {
        return ["GoMailerDidRegisterForRemoteNotifications", "GoMailerDidFailToRegisterForRemoteNotifications"]
    }
    
    @objc(initialize:resolver:rejecter:)
    func initialize(_ config: [String: Any], resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        print("🔵 GoMailerModule: initialize called with config:", config)
        
        guard let apiKey = config["apiKey"] as? String else {
            reject("INVALID_CONFIG", "API key is required", nil)
            return
        }
        
        self.apiKey = apiKey
        if let baseUrl = config["baseUrl"] as? String {
            self.baseUrl = baseUrl
        }
        
        print("🔵 GoMailerModule: SDK initialized with API key:", apiKey.prefix(10) + "...")
        resolve(["success": true])
    }
    
    @objc(setUser:resolver:rejecter:)
    func setUser(_ user: [String: Any], resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        print("🔵 GoMailerModule: setUser called with user:", user)
        
        guard let email = user["email"] as? String else {
            reject("INVALID_USER", "Email is required", nil)
            return
        }
        
        self.userEmail = email
        print("🔵 GoMailerModule: User set to:", email)
        resolve(["success": true])
    }
    
    @objc(registerForPushNotifications:resolver:rejecter:)
    func registerForPushNotifications(_ params: [String: Any], resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        print("🔵 GoMailerModule: registerForPushNotifications called")
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("🔵 GoMailerModule: Notification permission granted")
                    UIApplication.shared.registerForRemoteNotifications()
                    resolve(["success": true])
                } else {
                    print("🔴 GoMailerModule: Notification permission denied")
                    reject("PERMISSION_DENIED", "User denied notification permission", error)
                }
            }
        }
    }
    
    @objc(getDeviceToken:rejecter:)
    func getDeviceToken(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        print("🔵 GoMailerModule: getDeviceToken called")
        
        if let token = deviceToken {
            print("🔵 GoMailerModule: Returning cached device token")
            resolve(["token": token])
        } else {
            print("🔴 GoMailerModule: No device token available")
            reject("NO_TOKEN", "Device token not available", nil)
        }
    }
    
    @objc(trackEvent:resolver:rejecter:)
    func trackEvent(_ params: [String: Any], resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        print("🔵 GoMailerModule: trackEvent called with params:", params)
        
        guard let eventName = params["eventName"] as? String else {
            reject("INVALID_EVENT", "Event name is required", nil)
            return
        }
        
        let properties = params["properties"] as? [String: Any]
        
        // Send event to backend
        sendEventToServer(eventName: eventName, properties: properties)
        resolve(["success": true])
    }
    
    @objc(setUserAttributes:resolver:rejecter:)
    func setUserAttributes(_ attributes: [String: Any], resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        print("🔵 GoMailerModule: setUserAttributes called with attributes:", attributes)
        resolve(["success": true])
    }
    
    @objc(addUserTags:resolver:rejecter:)
    func addUserTags(_ tags: [String], resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        print("🔵 GoMailerModule: addUserTags called with tags:", tags)
        resolve(["success": true])
    }
    
    @objc(removeUserTags:resolver:rejecter:)
    func removeUserTags(_ tags: [String], resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        print("🔵 GoMailerModule: removeUserTags called with tags:", tags)
        resolve(["success": true])
    }
    
    @objc(setAnalyticsEnabled:resolver:rejecter:)
    func setAnalyticsEnabled(_ enabled: Bool, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        print("🔵 GoMailerModule: setAnalyticsEnabled called with enabled:", enabled)
        resolve(["success": true])
    }
    
    @objc(setLogLevel:resolver:rejecter:)
    func setLogLevel(_ level: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        print("🔵 GoMailerModule: setLogLevel called with level:", level)
        resolve(["success": true])
    }
    
    // MARK: - Device Token Handling
    @objc
    func didRegisterForRemoteNotifications(_ deviceToken: Data) {
        print("🔵 GoMailerModule: didRegisterForRemoteNotifications called")
        
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        self.deviceToken = tokenString
        print("🔵 GoMailerModule: Device token received:", tokenString)
        
        // Send device token to backend
        sendDeviceTokenToServer(tokenString)
        
        // Send event to React Native
        sendEvent(withName: "GoMailerDidRegisterForRemoteNotifications", body: ["deviceToken": tokenString])
    }
    
    @objc
    func didFailToRegisterForRemoteNotifications(_ error: Error) {
        print("🔴 GoMailerModule: didFailToRegisterForRemoteNotifications called with error:", error)
        
        // Send event to React Native
        sendEvent(withName: "GoMailerDidFailToRegisterForRemoteNotifications", body: ["error": error.localizedDescription])
    }
    
    private func sendDeviceTokenToServer(_ token: String) {
        guard let apiKey = apiKey, let email = userEmail else {
            print("🔴 GoMailerModule: Missing API key or user email")
            return
        }
        
        let url = URL(string: "\(baseUrl)/contacts")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let bundleId = Bundle.main.bundleIdentifier ?? "com.gomailer.pushTestReactNativeExample"
        let payload: [String: Any] = [
            "email": email,
            "gm_mobi_push": [
                "deviceToken": token,
                "platform": "ios",
                "bundleId": bundleId,
                "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
            ]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            print("🔴 GoMailerModule: Failed to serialize payload:", error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("🔴 GoMailerModule: Failed to send device token:", error)
            } else if let httpResponse = response as? HTTPURLResponse {
                print("🔵 GoMailerModule: Device token sent to server, status:", httpResponse.statusCode)
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("🔵 GoMailerModule: Response:", responseString)
                }
            }
        }.resume()
    }
    
    private func sendEventToServer(eventName: String, properties: [String: Any]?) {
        guard let apiKey = apiKey, let email = userEmail else {
            print("🔴 GoMailerModule: Missing API key or user email")
            return
        }
        
        let url = URL(string: "\(baseUrl)/events/push")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let bundleId = Bundle.main.bundleIdentifier ?? "com.gomailer.pushTestReactNativeExample"
        let payload: [String: Any] = [
            "email": email,
            "eventName": eventName,
            "properties": properties ?? [:],
            "platform": "ios",
            "bundleId": bundleId,
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            print("🔴 GoMailerModule: Failed to serialize event payload:", error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("🔴 GoMailerModule: Failed to send event:", error)
            } else if let httpResponse = response as? HTTPURLResponse {
                print("🔵 GoMailerModule: Event sent to server, status:", httpResponse.statusCode)
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("🔵 GoMailerModule: Event response:", responseString)
                }
            }
        }.resume()
    }
}
