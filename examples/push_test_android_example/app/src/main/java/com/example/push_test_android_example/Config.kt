package com.example.push_test_android_example

object ApiKeys {
    const val PRODUCTION = "R28tTWFpbGVyLTQ5NTExMjgwOTU1OC41NDI4LTQw"
    const val STAGING = "R2FtYm8tMTU2Mjc3Njc2Mjg2My43ODI1LTI="
    const val DEVELOPMENT = "R2FtYm8tODAwNDQwMDcwNzc0LjI1NjUtMjcw"
    
    fun getApiKey(environment: Environment): String {
        return when (environment) {
            Environment.PRODUCTION -> PRODUCTION
            Environment.STAGING -> STAGING
            Environment.DEVELOPMENT -> DEVELOPMENT
        }
    }
}

enum class Environment(val displayName: String, val endpoint: String, val description: String) {
    PRODUCTION("Production", "https://api.go-mailer.com/v1", "Live production environment"),
    STAGING("Staging", "https://api.gm-g7.xyz/v1", "Pre-production testing"),
    DEVELOPMENT("Development", "https://api.gm-g6.xyz/v1", "Development testing")
}

object EnvironmentConfig {
    // Default environment - change this to test different environments
    val CURRENT_ENVIRONMENT = Environment.PRODUCTION
    
    val apiKey: String
        get() = ApiKeys.getApiKey(CURRENT_ENVIRONMENT)
    
    val baseUrl: String
        get() = CURRENT_ENVIRONMENT.endpoint
}
