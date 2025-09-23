import Foundation

/// Storage manager for persisting Go Mailer data
class StorageManager: NSObject {
    
    private let userDefaults = UserDefaults.standard
    private let deviceTokenKey = "gomailer_device_token"
    private let userKey = "gomailer_user"
    private let analyticsEnabledKey = "gomailer_analytics_enabled"
    
    // MARK: - Device Token
    
    func saveDeviceToken(_ token: String) {
        userDefaults.set(token, forKey: deviceTokenKey)
    }
    
    func getDeviceToken() -> String? {
        return userDefaults.string(forKey: deviceTokenKey)
    }
    
    // MARK: - User
    
    func saveUser(_ user: GoMailerUser) {
        let userData: [String: Any] = [
            "email": user.email ?? "",
            "attributes": user.attributes ?? [:],
            "tags": user.tags ?? []
        ]
        userDefaults.set(userData, forKey: userKey)
    }
    
    func getUser() -> GoMailerUser? {
        guard let userData = userDefaults.dictionary(forKey: userKey) else {
            return nil
        }
        
        let user = GoMailerUser()
        user.email = userData["email"] as? String
        user.attributes = userData["attributes"] as? [String: Any]
        user.tags = userData["tags"] as? [String]
        
        return user
    }
    
    // MARK: - Analytics
    
    func saveAnalyticsEnabled(_ enabled: Bool) {
        userDefaults.set(enabled, forKey: analyticsEnabledKey)
    }
    
    func getAnalyticsEnabled() -> Bool {
        return userDefaults.bool(forKey: analyticsEnabledKey)
    }
    
    // MARK: - Clear Data
    
    func clearAllData() {
        userDefaults.removeObject(forKey: deviceTokenKey)
        userDefaults.removeObject(forKey: userKey)
        userDefaults.removeObject(forKey: analyticsEnabledKey)
    }
}
