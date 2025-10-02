package com.gomailer

import android.content.Context
import android.util.Log
import com.google.firebase.messaging.FirebaseMessaging
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject
import java.io.IOException
import com.gomailer.models.*

class GoMailerManager(
    private val context: Context,
    private val config: GoMailerConfig,
    private val httpClient: OkHttpClient = OkHttpClient()
) {
    companion object {
        private const val TAG = "GoMailerManager"
    }

    private val scope = CoroutineScope(Dispatchers.IO)
    private var deviceToken: String? = null
    private var currentUser: GoMailerUser? = null

    fun registerForPushNotifications() {
        Log.d(TAG, "Registering for push notifications...")
        
        FirebaseMessaging.getInstance().token.addOnCompleteListener { task ->
            if (task.isSuccessful) {
                deviceToken = task.result
                Log.d(TAG, "FCM token received: $deviceToken")
                
                scope.launch {
                    sendDeviceTokenToBackend(deviceToken!!)
                }
            } else {
                Log.e(TAG, "Failed to get FCM token", task.exception)
            }
        }
    }

    fun setUser(user: GoMailerUser) {
        Log.d(TAG, "Setting user: ${user.email}")
        currentUser = user
        
        scope.launch {
            sendUserToBackend(user)
        }
    }

    fun getDeviceToken(): String? = deviceToken

    fun trackEvent(eventName: String, properties: Map<String, Any>? = null) {
        Log.d(TAG, "Tracking event: $eventName with properties: $properties")
        
        scope.launch {
            try {
                val eventData = JSONObject().apply {
                    put("eventName", eventName)
                    put("properties", JSONObject(properties ?: emptyMap<String, Any>()))
                    put("platform", "android")
                    put("timestamp", java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", java.util.Locale.US).format(java.util.Date()))
                }

                val requestBody = eventData.toString().toRequestBody("application/json; charset=utf-8".toMediaType())
                val request = Request.Builder()
                    .url("${config.getEffectiveBaseUrl()}/events")
                    .post(requestBody)
                    .addHeader("Authorization", "Bearer ${config.apiKey}")
                    .build()

                val call = httpClient.newCall(request)
                call.execute().use { response ->
                    if (!response.isSuccessful) {
                        val code = response.code
                        val body = response.body?.string() ?: ""
                        Log.e(TAG, "Failed to track event: $code $body")
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error tracking event: ${e.message}", e)
            }
        }
    }

    fun setUserAttributes(attributes: Map<String, Any>) {
        Log.d(TAG, "Setting user attributes: $attributes")
    }

    fun addUserTags(tags: List<String>) {
        Log.d(TAG, "Adding user tags: $tags")
    }

    fun removeUserTags(tags: List<String>) {
        Log.d(TAG, "Removing user tags: $tags")
    }

    fun setAnalyticsEnabled(enabled: Boolean) {
        Log.d(TAG, "Setting analytics enabled: $enabled")
    }

    fun setLogLevel(level: GoMailerLogLevel) {
        Log.d(TAG, "Setting log level: $level")
    }

    private suspend fun sendDeviceTokenToBackend(token: String) {
        try {
            val payload = JSONObject().apply {
                put("email", currentUser?.email ?: "")
                put("gm_mobi_push", JSONObject().apply {
                    put("deviceToken", token)
                    put("platform", "android")
                    put("bundleId", context.packageName)
                    put("appVersion", getAppVersion())
                })
            }

            val requestBody = payload.toString().toRequestBody("application/json".toMediaType())
            val request = Request.Builder()
                .url("${config.baseUrl}/contacts")
                .addHeader("Authorization", "Bearer ${config.apiKey}")
                .addHeader("Content-Type", "application/json")
                .post(requestBody)
                .build()

            val response = httpClient.newCall(request).execute()
            
            if (response.isSuccessful) {
                Log.d(TAG, "Device token sent to backend successfully")
                // If we have a user, also update user info
                currentUser?.let { user ->
                    sendUserToBackend(user)
                }
            } else {
                Log.e(TAG, "Failed to send device token to backend: ${response.code}")
            }
            
            response.close()
            
        } catch (e: Exception) {
            Log.e(TAG, "Error sending device token", e)
        }
    }

    private fun getAppVersion(): String {
        return try {
            val packageInfo = context.packageManager.getPackageInfo(context.packageName, 0)
            packageInfo.versionName
        } catch (e: Exception) {
            "Unknown"
        }
    }

    private suspend fun sendUserToBackend(user: GoMailerUser) {
        try {
            val payload = JSONObject().apply {
                put("email", user.email ?: "")
            }

            val requestBody = payload.toString().toRequestBody("application/json".toMediaType())
            val request = Request.Builder()
                .url("${config.baseUrl}/contacts")
                .addHeader("Authorization", "Bearer ${config.apiKey}")
                .addHeader("Content-Type", "application/json")
                .post(requestBody)
                .build()

            val response = httpClient.newCall(request).execute()
            
            if (response.isSuccessful) {
                Log.d(TAG, "User data sent to backend successfully")
            } else {
                Log.e(TAG, "Failed to send user data to backend: ${response.code}")
            }
            
            response.close()
            
        } catch (e: Exception) {
            Log.e(TAG, "Error sending user data", e)
        }
    }
    
    fun trackNotificationClick(notificationId: String, title: String, body: String, email: String?) {
        CoroutineScope(Dispatchers.IO).launch {
            try {
                val properties = mapOf(
                    "notification_id" to notificationId,
                    "notification_title" to title,
                    "notification_body" to body,
                    "clicked_timestamp" to java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", java.util.Locale.US).format(java.util.Date()),
                    "platform" to "android"
                )
                
                val eventData = JSONObject().apply {
                    put("email", email ?: "")
                    put("eventName", "notification_clicked")
                    put("properties", JSONObject(properties))
                    put("platform", "android")
                    put("timestamp", java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", java.util.Locale.US).format(java.util.Date()))
                }

                val requestBody = eventData.toString().toRequestBody("application/json; charset=utf-8".toMediaType())

                val request = okhttp3.Request.Builder()
                    .url("${config.baseUrl}/events/push")
                    .addHeader("Authorization", "Bearer ${config.apiKey}")
                    .addHeader("Content-Type", "application/json")
                    .post(requestBody)
                    .build()

                val response = httpClient.newCall(request).execute()
                
                if (response.isSuccessful) {
                    Log.d(TAG, "📊 ✅ Notification click tracked successfully: $notificationId")
                } else {
                    Log.e(TAG, "❌ Failed to track notification click: ${response.code}")
                }
                
                response.close()
                
            } catch (e: Exception) {
                Log.e(TAG, "❌ Error tracking notification click", e)
            }
        }
    }
} 