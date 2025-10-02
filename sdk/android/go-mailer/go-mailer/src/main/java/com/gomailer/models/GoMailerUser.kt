package com.gomailer.models

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
