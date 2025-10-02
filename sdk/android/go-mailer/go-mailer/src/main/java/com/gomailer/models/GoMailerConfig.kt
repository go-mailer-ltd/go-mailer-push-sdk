package com.gomailer.models

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
