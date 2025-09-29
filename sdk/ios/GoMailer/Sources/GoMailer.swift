import Foundation
import UserNotifications
import UIKit

/// Main Go Mailer SDK class for iOS
@objc public class GoMailer: NSObject {
    
    // MARK: - Properties
    
    private static var sharedInstance: GoMailer?
    private var manager: GoMailerManager?
    private var isInitialized = false
    
    // MARK: - Public API
    
    /// Initialize the Go Mailer SDK
    /// - Parameters:
    ///   - apiKey: Your Go Mailer API key
    ///   - config: Optional configuration parameters
    @objc public static func initialize(apiKey: String, config: GoMailerConfig? = nil) {
        let instance = GoMailer()
        instance.setup(apiKey: apiKey, config: config)
        sharedInstance = instance
    }
    
    /// Get the shared instance of Go Mailer
    @objc public static func shared() -> GoMailer? {
        return sharedInstance
    }
    
    /// Register for push notifications
    @objc public static func registerForPushNotifications() {
        guard let instance = sharedInstance, instance.isInitialized else {
            print("Go Mailer: SDK not initialized. Call initialize() first.")
            return
        }
        
        instance.manager?.registerForPushNotifications()
    }
    
    /// Set the current user
    /// - Parameter user: User information
    @objc public static func setUser(_ user: GoMailerUser) {
        guard let instance = sharedInstance, instance.isInitialized else {
            print("Go Mailer: SDK not initialized. Call initialize() first.")
            return
        }
        
        instance.manager?.setUser(user)
    }
    
    /// Track an analytics event
    /// - Parameters:
    ///   - eventName: Name of the event
    ///   - properties: Event properties
    @objc public static func trackEvent(_ eventName: String, properties: [String: Any]? = nil) {
        guard let instance = sharedInstance, instance.isInitialized else {
            print("Go Mailer: SDK not initialized. Call initialize() first.")
            return
        }
        
        instance.manager?.trackEvent(eventName, properties: properties)
    }
    
    /// Get the current device token
    @objc public static func getDeviceToken() -> String? {
        guard let instance = sharedInstance, instance.isInitialized else {
            return nil
        }
        
        return instance.manager?.getDeviceToken()
    }
    
    /// Set custom attributes for the current user
    /// - Parameter attributes: Dictionary of attributes
    @objc public static func setUserAttributes(_ attributes: [String: Any]) {
        guard let instance = sharedInstance, instance.isInitialized else {
            print("Go Mailer: SDK not initialized. Call initialize() first.")
            return
        }
        
        instance.manager?.setUserAttributes(attributes)
    }
    
    /// Add tags to the current user
    /// - Parameter tags: Array of tags to add
    @objc public static func addUserTags(_ tags: [String]) {
        guard let instance = sharedInstance, instance.isInitialized else {
            print("Go Mailer: SDK not initialized. Call initialize() first.")
            return
        }
        
        instance.manager?.addUserTags(tags)
    }
    
    /// Remove tags from the current user
    /// - Parameter tags: Array of tags to remove
    @objc public static func removeUserTags(_ tags: [String]) {
        guard let instance = sharedInstance, instance.isInitialized else {
            print("Go Mailer: SDK not initialized. Call initialize() first.")
            return
        }
        
        instance.manager?.removeUserTags(tags)
    }
    
    /// Enable or disable analytics
    /// - Parameter enabled: Whether analytics should be enabled
    @objc public static func setAnalyticsEnabled(_ enabled: Bool) {
        guard let instance = sharedInstance, instance.isInitialized else {
            print("Go Mailer: SDK not initialized. Call initialize() first.")
            return
        }
        
        instance.manager?.setAnalyticsEnabled(enabled)
    }
    
    /// Set the log level
    /// - Parameter level: Log level
    @objc public static func setLogLevel(_ level: GoMailerLogLevel) {
        guard let instance = sharedInstance, instance.isInitialized else {
            print("Go Mailer: SDK not initialized. Call initialize() first.")
            return
        }
        
        instance.manager?.setLogLevel(level)
    }
    
    // MARK: - Private Methods
    
    private func setup(apiKey: String, config: GoMailerConfig?) {
        guard !apiKey.isEmpty else {
            print("Go Mailer: ❌ API key cannot be empty")
            return
        }
        
        let finalConfig = config ?? GoMailerConfig()
        finalConfig.apiKey = apiKey
        
        // Update legacy URLs to production if needed
        if let baseURL = finalConfig.baseURL, (baseURL.contains("ngrok") || baseURL.contains("gm-g6.xyz")) {
            print("Go Mailer: 🔄 Upgrading legacy URL to production endpoint")
            finalConfig.baseURL = nil // Use environment default
            finalConfig.environment = .production
        }
        
        manager = GoMailerManager(config: finalConfig)
        isInitialized = true
        
        print("Go Mailer: ✅ SDK initialized successfully with version \(GoMailerConfig.sdkVersion)")
        print("Go Mailer: 🌐 Base URL: \(finalConfig.effectiveBaseURL)")
        print("Go Mailer: 🏷️ Environment: \(finalConfig.environment)")
    }
}

// MARK: - Configuration Classes

@objc public class GoMailerConfig: NSObject {
    @objc public var apiKey: String = ""
    @objc public var baseURL: String?
    @objc public var environment: GoMailerEnvironment = .production
    @objc public var enableAnalytics: Bool = true
    @objc public var logLevel: GoMailerLogLevel = .info
    
    /// SDK Version
    @objc public static let sdkVersion: String = "1.1.0"
    
    /// Get the effective base URL (from environment or explicit baseURL)
    @objc public var effectiveBaseURL: String {
        if let baseURL = baseURL, !baseURL.isEmpty {
            return baseURL
        }
        return environment.endpoint
    }
    
    public override init() {
        super.init()
    }
    
    /// Convenience initializer with environment
    @objc public convenience init(environment: GoMailerEnvironment) {
        self.init()
        self.environment = environment
    }
}

@objc public enum GoMailerLogLevel: Int {
    case debug = 0
    case info = 1
    case warning = 2
    case error = 3
}

@objc public enum GoMailerEnvironment: Int {
    case production = 0
    case staging = 1
    case development = 2
    
    /// Get the endpoint URL for this environment
    public var endpoint: String {
        switch self {
        case .production:
            return "https://api.go-mailer.com/v1"
        case .staging:
            return "https://api.gm-g7.xyz/v1"
        case .development:
            return "https://api.gm-g6.xyz/v1"
        }
    }
    
    /// Get environment from URL (for debugging purposes)
    public static func from(url: String) -> GoMailerEnvironment? {
        if url.contains("go-mailer.com") { return .production }
        if url.contains("gm-g7.xyz") { return .staging }
        if url.contains("gm-g6.xyz") { return .development }
        return nil // Custom URL
    }
}

@objc public class GoMailerUser: NSObject {
    @objc public var email: String?
    @objc public var attributes: [String: Any]?
    @objc public var tags: [String]?
    
    @objc public init(email: String? = nil, attributes: [String: Any]? = nil, tags: [String]? = nil) {
        self.email = email
        self.attributes = attributes
        self.tags = tags
        super.init()
    }
} 