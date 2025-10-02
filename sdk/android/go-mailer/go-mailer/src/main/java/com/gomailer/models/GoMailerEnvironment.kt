package com.gomailer.models

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
