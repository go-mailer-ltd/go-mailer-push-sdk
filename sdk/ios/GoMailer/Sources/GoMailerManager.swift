import Foundation
import UserNotifications
import UIKit

/// Manager class that handles the core functionality of Go Mailer SDK
class GoMailerManager: NSObject {
    
    // MARK: - Properties
    
    private let config: GoMailerConfig
    private let networkManager: NetworkManager
    private let storageManager: StorageManager
    private let pushNotificationManager: PushNotificationManager
    private var currentUser: GoMailerUser?
    private var deviceToken: String?
    private var isAnalyticsEnabled: Bool
    
    // MARK: - Initialization
    
    init(config: GoMailerConfig) {
        self.config = config
        self.isAnalyticsEnabled = config.enableAnalytics
        
        self.networkManager = NetworkManager(config: config)
        self.storageManager = StorageManager()
        self.pushNotificationManager = PushNotificationManager()
        
        super.init()
        
        setupManagers()
        trackSDKInitialized()
    }
    
    // MARK: - Setup
    
    private func setupManagers() {
        pushNotificationManager.delegate = self
        networkManager.delegate = self
    }
    
    // MARK: - Public Methods
    
    func registerForPushNotifications() {
        pushNotificationManager.requestAuthorization { [weak self] granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                self?.trackEvent("push_notification_authorized")
                print("Go Mailer: Push notification authorization granted")
            } else {
                self?.trackEvent("push_notification_denied", properties: ["error": error?.localizedDescription ?? "Unknown"])
                print("Go Mailer: Push notification authorization denied: \(error?.localizedDescription ?? "Unknown")")
            }
        }
    }
    
    func setUser(_ user: GoMailerUser) {
        currentUser = user
        storageManager.saveUser(user)
        
        // Send user data to backend
        let payload = ["email": user.email ?? ""]
        
        networkManager.sendRequest(
            endpoint: "/contacts",
            method: "POST",
            body: payload
        ) { [weak self] result in
            switch result {
            case .success(_):
                self?.trackEvent("user_registered", properties: ["email": user.email ?? ""])
                print("Go Mailer: User data sent successfully: \(user.email ?? "No email")")
            case .failure(let error):
                self?.trackEvent("user_registration_failed", properties: ["error": error.localizedDescription])
                print("Go Mailer: Failed to send user data: \(error.localizedDescription)")
            }
        }
        
        // Register device token if available
        if let token = deviceToken {
            registerDeviceToken(token, for: user.email)
        }
    }
    
    func trackEvent(_ eventName: String, properties: [String: Any]? = nil) {
        guard isAnalyticsEnabled else { return }
        
        var eventData = [
            "event": eventName,
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "platform": "ios",
            "sdkVersion": "1.0.0"
        ] as [String: Any]
        
        if let userEmail = currentUser?.email {
            eventData["email"] = userEmail
        }
        
        if let properties = properties {
            eventData["properties"] = properties
        }
        
        networkManager.sendRequest(
            endpoint: "/events/push",
            method: "POST",
            body: eventData
        ) { result in
            switch result {
            case .success(_):
                print("Go Mailer: ✅ Event tracked: \(eventName)")
            case .failure(let error):
                print("Go Mailer: ❌ Failed to track event \(eventName): \(error.localizedDescription)")
            }
        }
    }
    
    func getDeviceToken() -> String? {
        return deviceToken
    }
    
    func setUserAttributes(_ attributes: [String: Any]) {
        guard let user = currentUser else {
            print("Go Mailer: No user set. Call setUser() first.")
            return
        }
        
        networkManager.sendRequest(
            endpoint: "/users/\(user.email)/attributes",
            method: "PUT",
            body: ["attributes": attributes]
        ) { [weak self] result in
            switch result {
            case .success(_):
                self?.trackEvent("user_attributes_updated")
            case .failure(let error):
                self?.trackEvent("user_attributes_update_failed", properties: ["error": error.localizedDescription])
            }
        }
    }
    
    func addUserTags(_ tags: [String]) {
        guard let user = currentUser else {
            print("Go Mailer: No user set. Call setUser() first.")
            return
        }
        
        networkManager.sendRequest(
            endpoint: "/users/\(user.email)/tags",
            method: "POST",
            body: ["tags": tags]
        ) { [weak self] result in
            switch result {
            case .success(_):
                self?.trackEvent("user_tags_added", properties: ["tags": tags])
            case .failure(let error):
                self?.trackEvent("user_tags_add_failed", properties: ["error": error.localizedDescription])
            }
        }
    }
    
    func removeUserTags(_ tags: [String]) {
        guard let user = currentUser else {
            print("Go Mailer: No user set. Call setUser() first.")
            return
        }
        
        networkManager.sendRequest(
            endpoint: "/users/\(user.email)/tags",
            method: "DELETE",
            body: ["tags": tags]
        ) { [weak self] result in
            switch result {
            case .success(_):
                self?.trackEvent("user_tags_removed", properties: ["tags": tags])
            case .failure(let error):
                self?.trackEvent("user_tags_remove_failed", properties: ["error": error.localizedDescription])
            }
        }
    }
    
    func setAnalyticsEnabled(_ enabled: Bool) {
        isAnalyticsEnabled = enabled
        storageManager.saveAnalyticsEnabled(enabled)
    }
    
    func setLogLevel(_ level: GoMailerLogLevel) {
        // Implementation would set the log level for the network manager
        print("Go Mailer: Log level set to \(level)")
    }
    
    // MARK: - Private Methods
    
    private func registerDeviceToken(_ token: String, for userEmail: String?) {
        let bundleId = Bundle.main.bundleIdentifier ?? "com.gomailer.unknown"
        
        var payload: [String: Any] = [
            "email": userEmail ?? "",
            "gm_mobi_push": [
                "deviceToken": token,
                "platform": "ios",
                "bundleId": bundleId,
                "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
            ]
        ]
        
        print("Go Mailer: Registering device token with payload: \(payload)")
        
        networkManager.sendRequest(
            endpoint: "/contacts",
            method: "POST",
            body: payload
        ) { [weak self] result in
            switch result {
            case .success(_):
                self?.trackEvent("device_token_registered")
                print("Go Mailer: Device token registered successfully")
            case .failure(let error):
                self?.trackEvent("device_token_registration_failed", properties: ["error": error.localizedDescription])
                print("Go Mailer: Failed to register device token: \(error.localizedDescription)")
            }
        }
    }
    
    private func trackSDKInitialized() {
        trackEvent("sdk_initialized", properties: [
            "version": "1.0.0",
            "platform": "ios"
        ])
    }
}

// MARK: - PushNotificationManagerDelegate

extension GoMailerManager: PushNotificationManagerDelegate {
    func didReceiveDeviceToken(_ token: String) {
        deviceToken = token
        storageManager.saveDeviceToken(token)
        
        // Always try to register the token, even if no user is set yet
        // The email will be added later when setUser is called
        registerDeviceToken(token, for: currentUser?.email)
        
        trackEvent("device_token_received")
        print("Go Mailer: Device token received: \(token)")
    }
    
    func didFailToRegisterForRemoteNotifications(_ error: Error) {
        trackEvent("device_token_registration_failed", properties: ["error": error.localizedDescription])
    }
    
    func didReceiveNotification(_ notification: UNNotification) {
        // Only log that notification was received - no tracking events
        print("Go Mailer: 📱 Notification received and will be displayed")
        print("Go Mailer: 👆 Notification is ready for user click tracking")
    }
    
    func didReceiveNotificationResponse(_ response: UNNotificationResponse) {
        // Extract notification data
        let notification = response.notification
        let userInfo = notification.request.content.userInfo
        
        // Get notification ID - prefer custom ID from server, fallback to system identifier
        let notificationId = userInfo["notification_id"] as? String ?? notification.request.identifier
        let title = notification.request.content.title
        let body = notification.request.content.body
        
        print("Go Mailer: 👆 Notification clicked! ID: \(notificationId)")
        print("Go Mailer: 👆 Title: \(title)")
        print("Go Mailer: 👆 Body: \(body)")
        
        // Track the notification click event (only when user taps the notification)
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            trackNotificationClick(
                notificationId: notificationId,
                title: title,
                body: body,
                userInfo: userInfo
            )
        }
    }
    
    private func trackNotificationClick(notificationId: String, title: String, body: String, userInfo: [AnyHashable: Any]) {
        let properties: [String: Any] = [
            "notification_id": notificationId,
            "notification_title": title,
            "notification_body": body,
            "clicked_timestamp": ISO8601DateFormatter().string(from: Date()),
            "platform": "ios"
        ]
        
        var eventData = [
            "email": currentUser?.email ?? "",
            "eventName": "notification_clicked",
            "properties": properties,
            "platform": "ios",
            "bundleId": Bundle.main.bundleIdentifier ?? "unknown",
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0",
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ] as [String: Any]
        
        networkManager.sendRequest(
            endpoint: "/events/push",
            method: "POST", 
            body: eventData
        ) { result in
            switch result {
            case .success(_):
                print("Go Mailer: 📊 ✅ Notification click tracked successfully!")
            case .failure(let error):
                print("Go Mailer: ❌ Failed to track notification click: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - NetworkManagerDelegate

extension GoMailerManager: NetworkManagerDelegate {
    func networkManager(_ manager: NetworkManager, didReceiveResponse response: [String: Any], for request: String) {
        // Handle specific network responses if needed
    }
    
    func networkManager(_ manager: NetworkManager, didFailWithError error: Error, for request: String) {
        trackEvent("network_error", properties: [
            "request": request,
            "error": error.localizedDescription
        ])
    }
} 