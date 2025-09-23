package com.gomailer

import android.content.Context
import android.util.Log
import com.gomailer.models.GoMailerConfig
import com.gomailer.models.GoMailerUser
import com.gomailer.models.GoMailerLogLevel

/**
 * Main Go Mailer SDK class for Android
 */
class GoMailer private constructor() {
    
    companion object {
        private const val TAG = "GoMailer"
        const val VERSION = "1.0.0"
        private var instance: GoMailer? = null
        private var manager: GoMailerManager? = null
        private var isInitialized = false
        
        /**
         * Initialize the Go Mailer SDK
         * @param context Application context
         * @param apiKey Your Go Mailer API key
         * @param config Optional configuration parameters
         * @throws IllegalArgumentException if API key is empty
         */
        @JvmStatic
        fun initialize(context: Context, apiKey: String, config: GoMailerConfig? = null) {
            if (isInitialized) {
                Log.d(TAG, "SDK already initialized")
                return
            }
            
            if (apiKey.isEmpty()) {
                throw IllegalArgumentException("API key cannot be empty")
            }
            
            val finalConfig = config ?: GoMailerConfig()
            finalConfig.apiKey = apiKey
            
            // Use production endpoint by default, allow config override
            if (finalConfig.baseUrl.contains("ngrok") || finalConfig.baseUrl.contains("gm-g6.xyz")) {
                finalConfig.baseUrl = "https://api.go-mailer.com/v1"
            }
            
            instance = GoMailer()
            manager = GoMailerManager(context, finalConfig)
            isInitialized = true
            
            Log.i(TAG, "✅ Go Mailer SDK initialized successfully with version $VERSION")
            Log.i(TAG, "🌐 Base URL: ${finalConfig.baseUrl}")
        }
        
        /**
         * Get the shared instance of Go Mailer
         */
        @JvmStatic
        fun getInstance(): GoMailer? {
            return instance
        }
        
        /**
         * Register for push notifications
         * Note: Call setUser() before this method to ensure email is sent with the token
         */
        @JvmStatic
        fun registerForPushNotifications() {
            checkInitialization()
            manager?.registerForPushNotifications()
        }
        
        /**
         * Set the current user
         * @param user User information
         */
        @JvmStatic
        fun setUser(user: GoMailerUser) {
            checkInitialization()
            manager?.setUser(user)
        }
        
        /**
         * Track an analytics event
         * @param eventName Name of the event
         * @param properties Event properties
         */
        @JvmStatic
        fun trackEvent(eventName: String, properties: Map<String, Any>? = null) {
            checkInitialization()
            manager?.trackEvent(eventName, properties)
        }
        
        /**
         * Track notification click event
         * This method should be called when the app is opened from a notification
         * @param notificationId The notification ID (from server or auto-generated)
         * @param title The notification title
         * @param body The notification body
         * @param email The user's email address
         */
        @JvmStatic
        fun trackNotificationClick(notificationId: String, title: String, body: String, email: String? = null) {
            checkInitialization()
            manager?.trackNotificationClick(notificationId, title, body, email)
        }
        
        /**
         * Get the current device token
         */
        @JvmStatic
        fun getDeviceToken(): String? {
            checkInitialization()
            return manager?.getDeviceToken()
        }
        
        /**
         * Set custom attributes for the current user
         * @param attributes Dictionary of attributes
         */
        @JvmStatic
        fun setUserAttributes(attributes: Map<String, Any>) {
            checkInitialization()
            manager?.setUserAttributes(attributes)
        }
        
        /**
         * Add tags to the current user
         * @param tags Array of tags to add
         */
        @JvmStatic
        fun addUserTags(tags: List<String>) {
            checkInitialization()
            manager?.addUserTags(tags)
        }
        
        /**
         * Remove tags from the current user
         * @param tags Array of tags to remove
         */
        @JvmStatic
        fun removeUserTags(tags: List<String>) {
            checkInitialization()
            manager?.removeUserTags(tags)
        }
        
        /**
         * Enable or disable analytics
         * @param enabled Whether analytics should be enabled
         */
        @JvmStatic
        fun setAnalyticsEnabled(enabled: Boolean) {
            checkInitialization()
            manager?.setAnalyticsEnabled(enabled)
        }
        
        /**
         * Set the log level
         * @param level Log level to set
         */
        @JvmStatic
        fun setLogLevel(level: GoMailerLogLevel) {
            checkInitialization()
            manager?.setLogLevel(level)
        }
        
        /**
         * Check if SDK is initialized
         */
        private fun checkInitialization() {
            if (!isInitialized) {
                Log.e(TAG, "SDK not initialized. Call initialize() first.")
                throw IllegalStateException("Go Mailer SDK not initialized. Call initialize() first.")
            }
        }
    }
}

/**
 * Configuration for Go Mailer SDK
 */
data class GoMailerConfig(
    var apiKey: String = "",
    var baseUrl: String = "https://api.go-mailer.com/v1", // Production endpoint
    var enableAnalytics: Boolean = true,
    var logLevel: GoMailerLogLevel = GoMailerLogLevel.INFO
)

/**
 * User information for Go Mailer
 */
data class GoMailerUser(
    val email: String? = null,
    val phone: String? = null,
    val firstName: String? = null,
    val lastName: String? = null,
    val customAttributes: Map<String, Any>? = null,
    val tags: List<String>? = null
)

/**
 * Log levels for Go Mailer SDK
 */
enum class GoMailerLogLevel {
    DEBUG,
    INFO,
    WARN,
    ERROR
}

/**
 * Errors that can occur in Go Mailer SDK
 */
enum class GoMailerError(val code: Int, val message: String) {
    NOT_INITIALIZED(1001, "Go Mailer SDK not initialized"),
    INVALID_API_KEY(1002, "Invalid API key"),
    NETWORK_ERROR(1003, "Network error occurred"),
    INVALID_USER(1004, "Invalid user information"),
    PUSH_NOTIFICATION_NOT_AUTHORIZED(1006, "Push notifications not authorized"),
    DEVICE_TOKEN_NOT_AVAILABLE(1007, "Device token not available")
} 