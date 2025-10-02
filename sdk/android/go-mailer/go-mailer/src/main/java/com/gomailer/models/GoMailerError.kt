package com.gomailer.models

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
