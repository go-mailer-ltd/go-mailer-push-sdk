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
            
            // Update legacy URLs to production if needed
            finalConfig.baseUrl?.let { baseUrl ->
                if (baseUrl.contains("ngrok") || baseUrl.contains("gm-g6.xyz")) {
                    Log.d(TAG, "🔄 Upgrading legacy URL to production endpoint")
                    finalConfig.baseUrl = null // Use environment default
                    finalConfig.environment = GoMailerEnvironment.PRODUCTION
                }
            }
            
            instance = GoMailer()
            manager = GoMailerManager(context, finalConfig)
            isInitialized = true
            
            Log.i(TAG, "✅ Go Mailer SDK initialized successfully with version $VERSION")
            Log.i(TAG, "🌐 Base URL: ${finalConfig.getEffectiveBaseUrl()}")
            Log.i(TAG, "🏷️ Environment: ${finalConfig.environment}")
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
    var baseUrl: String? = null,
    var environment: GoMailerEnvironment = GoMailerEnvironment.PRODUCTION,
    var enableAnalytics: Boolean = true,
    var logLevel: GoMailerLogLevel = GoMailerLogLevel.INFO
) {
    /**
     * Get the effective base URL (from environment or explicit baseUrl)
     */
    fun getEffectiveBaseUrl(): String {
        return baseUrl?.takeIf { it.isNotEmpty() } ?: environment.endpoint
    }
}

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
 * Available Go Mailer environments
 */
enum class GoMailerEnvironment(val endpoint: String) {
    PRODUCTION("https://api.go-mailer.com/v1"),
    STAGING("https://api.gm-g7.xyz/v1"),
    DEVELOPMENT("https://api.gm-g6.xyz/v1");

    companion object {
        /**
         * Get environment from URL (for debugging purposes)
         */
        fun fromUrl(url: String): GoMailerEnvironment? {
            return when {
                url.contains("go-mailer.com") -> PRODUCTION
                url.contains("gm-g7.xyz") -> STAGING
                url.contains("gm-g6.xyz") -> DEVELOPMENT
                else -> null // Custom URL
            }
        }
    }
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