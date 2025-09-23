package com.gomailer.gomailer

import android.util.Log
import com.facebook.react.bridge.*
import com.facebook.react.modules.core.DeviceEventManagerModule
import java.net.HttpURLConnection
import java.net.URL
import java.io.OutputStreamWriter
import java.text.SimpleDateFormat
import java.util.*
import org.json.JSONObject
import com.google.firebase.messaging.FirebaseMessaging

class GoMailerModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {
    private var apiKey: String? = null
    private var baseUrl: String = "https://api.go-mailer.com/v1"
    private var currentEmail: String? = null
    private var currentDeviceToken: String? = null

    override fun getName(): String {
        return "GoMailerModule"
    }

    @ReactMethod
    fun initialize(config: ReadableMap, promise: Promise) {
        try {
            apiKey = config.getString("apiKey")
            if (config.hasKey("baseUrl")) {
                baseUrl = config.getString("baseUrl") ?: baseUrl
            }
            
            Log.d("GoMailer", "🚀 Initializing Go Mailer module")
            Log.d("GoMailer", "✅ API Key set: ${apiKey?.take(10)}...")
            Log.d("GoMailer", "🌐 Base URL set: $baseUrl")
            
            promise.resolve(null)
        } catch (e: Exception) {
            Log.e("GoMailer", "❌ Failed to initialize: ${e.message}")
            promise.reject("INIT_ERROR", "Failed to initialize Go Mailer", e)
        }
    }

    @ReactMethod
    fun setUser(user: ReadableMap, promise: Promise) {
        try {
            currentEmail = user.getString("email")
            Log.d("GoMailer", "👤 Setting user data")
            Log.d("GoMailer", "📧 User email set: $currentEmail")
            
            // Send user data to backend
            sendUserToServer(currentEmail ?: "")
            
            promise.resolve(null)
        } catch (e: Exception) {
            Log.e("GoMailer", "❌ Failed to set user: ${e.message}")
            promise.reject("SET_USER_ERROR", "Failed to set user", e)
        }
    }

    @ReactMethod
    fun registerForPushNotifications(params: ReadableMap, promise: Promise) {
        try {
            val email = params.getString("email") ?: currentEmail
            currentEmail = email
            
            Log.d("GoMailer", "📱 Registering for push notifications")
            Log.d("GoMailer", "📧 Email for registration: $email")
            
            // Get FCM token
            FirebaseMessaging.getInstance().token.addOnCompleteListener { task ->
                if (!task.isSuccessful) {
                    Log.w("GoMailer", "Fetching FCM registration token failed", task.exception)
                    return@addOnCompleteListener
                }

                // Get new FCM registration token
                val token = task.result
                currentDeviceToken = token
                
                Log.d("GoMailer", "✅ FCM token: ${token?.take(20)}...")
                
                // Send device token to backend
                sendDeviceTokenToServer(token ?: "", email ?: "")
            }
            
            promise.resolve(null)
        } catch (e: Exception) {
            Log.e("GoMailer", "❌ Failed to register for push notifications: ${e.message}")
            promise.reject("REGISTER_ERROR", "Failed to register for push notifications", e)
        }
    }

    @ReactMethod
    fun getDeviceToken(promise: Promise) {
        try {
            Log.d("GoMailer", "🔑 Getting device token")
            
            if (currentDeviceToken != null) {
                Log.d("GoMailer", "✅ Returning stored device token: ${currentDeviceToken?.take(20)}...")
                val result = Arguments.createMap().apply {
                    putString("token", currentDeviceToken)
                }
                promise.resolve(result)
            } else {
                Log.d("GoMailer", "⚠️ No device token available yet")
                promise.resolve(null)
            }
        } catch (e: Exception) {
            Log.e("GoMailer", "❌ Failed to get device token: ${e.message}")
            promise.reject("GET_TOKEN_ERROR", "Failed to get device token", e)
        }
    }

    @ReactMethod
    fun trackEvent(params: ReadableMap, promise: Promise) {
        try {
            val eventName = params.getString("eventName") ?: "unknown"
            val properties = params.getMap("properties")
            
            Log.d("GoMailer", "📊 Tracking event: $eventName")
            Log.d("GoMailer", "📊 Properties: $properties")
            
            // Send event to backend
            sendEventToServer(eventName, properties)
            
            promise.resolve(null)
        } catch (e: Exception) {
            Log.e("GoMailer", "❌ Failed to track event: ${e.message}")
            promise.reject("TRACK_EVENT_ERROR", "Failed to track event", e)
        }
    }

    @ReactMethod
    fun trackNotificationClick(params: ReadableMap, promise: Promise) {
        try {
            val notificationId = params.getString("notificationId") ?: "unknown"
            val title = params.getString("title") ?: "Unknown"
            val body = params.getString("body") ?: ""
            val email = params.getString("email") ?: currentEmail ?: ""
            
            Log.d("GoMailer", "👆 Tracking notification click: $notificationId")
            
            val properties = Arguments.createMap().apply {
                putString("notification_id", notificationId)
                putString("notification_title", title)
                putString("notification_body", body)
                putString("clicked_timestamp", SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.US).format(Date()))
                putString("platform", "android")
            }
            
            sendEventToServer("notification_clicked", properties)
            promise.resolve(null)
        } catch (e: Exception) {
            Log.e("GoMailer", "❌ Failed to track notification click: ${e.message}")
            promise.reject("TRACK_NOTIFICATION_CLICK_ERROR", "Failed to track notification click", e)
        }
    }

    @ReactMethod
    fun setUserAttributes(attributes: ReadableMap, promise: Promise) {
        try {
            Log.d("GoMailer", "🏷️ Setting user attributes")
            promise.resolve(null)
        } catch (e: Exception) {
            Log.e("GoMailer", "❌ Failed to set user attributes: ${e.message}")
            promise.reject("SET_ATTRIBUTES_ERROR", "Failed to set user attributes", e)
        }
    }

    @ReactMethod
    fun addUserTags(tags: ReadableArray, promise: Promise) {
        try {
            Log.d("GoMailer", "➕ Adding user tags")
            promise.resolve(null)
        } catch (e: Exception) {
            Log.e("GoMailer", "❌ Failed to add user tags: ${e.message}")
            promise.reject("ADD_TAGS_ERROR", "Failed to add user tags", e)
        }
    }

    @ReactMethod
    fun removeUserTags(tags: ReadableArray, promise: Promise) {
        try {
            Log.d("GoMailer", "➖ Removing user tags")
            promise.resolve(null)
        } catch (e: Exception) {
            Log.e("GoMailer", "❌ Failed to remove user tags: ${e.message}")
            promise.reject("REMOVE_TAGS_ERROR", "Failed to remove user tags", e)
        }
    }

    @ReactMethod
    fun setAnalyticsEnabled(enabled: Boolean, promise: Promise) {
        try {
            Log.d("GoMailer", "📈 Setting analytics enabled: $enabled")
            promise.resolve(null)
        } catch (e: Exception) {
            Log.e("GoMailer", "❌ Failed to set analytics enabled: ${e.message}")
            promise.reject("SET_ANALYTICS_ERROR", "Failed to set analytics enabled", e)
        }
    }

    @ReactMethod
    fun setLogLevel(level: String, promise: Promise) {
        try {
            Log.d("GoMailer", "📝 Setting log level: $level")
            promise.resolve(null)
        } catch (e: Exception) {
            Log.e("GoMailer", "❌ Failed to set log level: ${e.message}")
            promise.reject("SET_LOG_LEVEL_ERROR", "Failed to set log level", e)
        }
    }

    private fun sendUserToServer(email: String) {
        Thread {
            try {
                val url = URL("$baseUrl/contacts")
                val connection = url.openConnection() as HttpURLConnection
                connection.requestMethod = "POST"
                connection.setRequestProperty("Content-Type", "application/json")
                apiKey?.let { connection.setRequestProperty("Authorization", "Bearer $it") }
                connection.doOutput = true

                val body = JSONObject().apply {
                    put("email", email)
                    put("gm_mobi_push", JSONObject().apply {
                        put("platform", "android")
                        put("bundleId", "com.push_test_react_native_example")
                        put("appVersion", "1.0.0")
                        put("timestamp", java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", java.util.Locale.US).format(java.util.Date()))
                    })
                }

                Log.d("GoMailer", "📤 Sending user data to: $url")
                Log.d("GoMailer", "📤 Request body: $body")

                val outputStream = connection.outputStream
                val writer = OutputStreamWriter(outputStream)
                writer.write(body.toString())
                writer.flush()
                writer.close()

                val responseCode = connection.responseCode
                Log.d("GoMailer", "📤 User data sent to backend. Status: $responseCode")

                if (responseCode >= 400) {
                    val errorStream = connection.errorStream
                    val errorResponse = errorStream?.bufferedReader()?.use { it.readText() }
                    Log.e("GoMailer", "❌ Server error response: $errorResponse")
                }

                connection.disconnect()
            } catch (e: Exception) {
                Log.e("GoMailer", "❌ Failed to send user data: ${e.message}")
            }
        }.start()
    }

    private fun sendDeviceTokenToServer(token: String, email: String) {
        Thread {
            try {
                val url = URL("$baseUrl/contacts")
                val connection = url.openConnection() as HttpURLConnection
                connection.requestMethod = "POST"
                connection.setRequestProperty("Content-Type", "application/json")
                apiKey?.let { connection.setRequestProperty("Authorization", "Bearer $it") }
                connection.doOutput = true

                val body = JSONObject().apply {
                    put("email", email)
                    put("gm_mobi_push", JSONObject().apply {
                        put("deviceToken", token)
                        put("platform", "android")
                        put("bundleId", "com.push_test_react_native_example")
                        put("appVersion", "1.0.0")
                        put("timestamp", java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", java.util.Locale.US).format(java.util.Date()))
                    })
                }

                Log.d("GoMailer", "📤 Sending device token to: $url")
                Log.d("GoMailer", "📤 Request body: $body")

                val outputStream = connection.outputStream
                val writer = OutputStreamWriter(outputStream)
                writer.write(body.toString())
                writer.flush()
                writer.close()

                val responseCode = connection.responseCode
                Log.d("GoMailer", "📤 Device token sent to backend. Status: $responseCode")

                if (responseCode >= 400) {
                    val errorStream = connection.errorStream
                    val errorResponse = errorStream?.bufferedReader()?.use { it.readText() }
                    Log.e("GoMailer", "❌ Server error response: $errorResponse")
                }

                connection.disconnect()
            } catch (e: Exception) {
                Log.e("GoMailer", "❌ Failed to send device token: ${e.message}")
            }
        }.start()
    }

    private fun sendEvent(eventName: String, data: WritableMap) {
        reactApplicationContext
            .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
            .emit(eventName, data)
    }

    private fun sendEventToServer(eventName: String, properties: ReadableMap?) {
        Thread {
            try {
                val url = URL("$baseUrl/events/push")
                val connection = url.openConnection() as HttpURLConnection
                connection.requestMethod = "POST"
                connection.setRequestProperty("Content-Type", "application/json")
                connection.setRequestProperty("Authorization", "Bearer $apiKey")
                connection.doOutput = true

                val body = JSONObject().apply {
                    put("email", currentEmail ?: "")
                    put("eventName", eventName)
                    put("properties", properties?.toString() ?: "{}")
                    put("platform", "android")
                    put("appVersion", "1.0.0")
                    put("timestamp", java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(java.util.Date()))
                }

                val outputStream = connection.outputStream
                val writer = OutputStreamWriter(outputStream)
                writer.write(body.toString())
                writer.flush()
                writer.close()

                val responseCode = connection.responseCode
                Log.d("GoMailer", "📤 Event sent to backend. Status: $responseCode")

                connection.disconnect()
            } catch (e: Exception) {
                Log.e("GoMailer", "❌ Failed to send event: ${e.message}")
            }
        }.start()
    }
}
