package com.gomailer.go_mailer

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.util.Log
import kotlinx.coroutines.*
import kotlinx.coroutines.tasks.await
import org.json.JSONObject
import java.io.OutputStreamWriter
import java.net.HttpURLConnection
import java.net.URL
import java.text.SimpleDateFormat
import java.util.*

/** GoMailerPlugin */
class GoMailerPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private var apiKey: String? = null
  private var baseUrl: String = "https://api.go-mailer.com/v1"
  private var currentEmail: String? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "go_mailer")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "initialize" -> {
        Log.d("GoMailer", "🚀 Initializing Go Mailer plugin")
        val args = call.arguments as? Map<*, *>
        apiKey = args?.get("apiKey") as? String
        Log.d("GoMailer", "✅ API Key set: ${apiKey?.take(10)}...")
        
        // Extract baseUrl from config if provided
        val config = args?.get("config") as? Map<*, *>
        val configBaseUrl = config?.get("baseUrl") as? String
        if (configBaseUrl != null) {
          baseUrl = configBaseUrl
          Log.d("GoMailer", "🌐 Base URL set: $baseUrl")
        }
        
        // Configure Firebase Messaging Service
        GoMailerFirebaseMessagingService.setConfig(apiKey, baseUrl, currentEmail)
        
        result.success(null)
      }
      "registerForPushNotifications" -> {
        Log.d("GoMailer", "📱 Registering for push notifications")
        val args = call.arguments as? Map<*, *>
        currentEmail = args?.get("email") as? String
        Log.d("GoMailer", "📧 Email set for registration: $currentEmail")
        
        // Get FCM token and send to backend
        CoroutineScope(Dispatchers.IO).launch {
          try {
            val token = com.google.firebase.messaging.FirebaseMessaging.getInstance().token.await()
            Log.d("GoMailer", "✅ FCM token obtained: ${token.take(20)}...")
            
            // Send token to backend
            sendTokenToServer(currentEmail ?: "", token)
            
            withContext(Dispatchers.Main) {
              result.success(token)
            }
          } catch (e: Exception) {
            Log.e("GoMailer", "❌ Failed to register for push notifications: ${e.message}")
            withContext(Dispatchers.Main) {
              result.success(null)
            }
          }
        }
      }
      "setUser" -> {
        Log.d("GoMailer", "👤 Setting user data")
        val args = call.arguments as? Map<*, *>
        currentEmail = args?.get("email") as? String
        Log.d("GoMailer", "📧 User email set: $currentEmail")
        
        // Update Firebase Messaging Service with new email
        GoMailerFirebaseMessagingService.setConfig(apiKey, baseUrl, currentEmail)
        
        result.success(null)
      }
      "trackEvent" -> {
        Log.d("GoMailer", "📊 Tracking event")
        val args = call.arguments as? Map<*, *>
        val eventName = args?.get("eventName") as? String ?: "unknown"
        val properties = args?.get("properties") as? Map<*, *>
        Log.d("GoMailer", "📊 Event: $eventName, Properties: $properties")
        
        // Send event to backend
        sendEventToServer(eventName, properties, currentEmail ?: "")
        result.success(null)
      }
      "trackNotificationClick" -> {
        Log.d("GoMailer", "👆 Tracking notification click")
        val args = call.arguments as? Map<*, *>
        val notificationId = args?.get("notificationId") as? String ?: "unknown"
        val title = args?.get("title") as? String ?: "Unknown"
        val body = args?.get("body") as? String ?: ""
        val email = args?.get("email") as? String ?: currentEmail ?: ""
        
        val properties = mapOf(
          "notification_id" to notificationId,
          "notification_title" to title,
          "notification_body" to body,
          "clicked_timestamp" to SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.US).format(Date()),
          "platform" to "android"
        )
        
        Log.d("GoMailer", "👆 Notification click: $notificationId")
        sendEventToServer("notification_clicked", properties, email)
        result.success(null)
      }
      "getDeviceToken" -> {
        Log.d("GoMailer", "🔑 Getting device token")
        CoroutineScope(Dispatchers.IO).launch {
          try {
            val token = com.google.firebase.messaging.FirebaseMessaging.getInstance().token.await()
            Log.d("GoMailer", "✅ FCM token retrieved: ${token.take(20)}...")
            withContext(Dispatchers.Main) {
              result.success(token)
            }
          } catch (e: Exception) {
            Log.e("GoMailer", "❌ Failed to get FCM token: ${e.message}")
            withContext(Dispatchers.Main) {
              result.success(null)
            }
          }
        }
      }
      else -> result.notImplemented()
    }
  }

  private fun sendTokenToServer(email: String, deviceToken: String) {
    CoroutineScope(Dispatchers.IO).launch {
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
            put("deviceToken", deviceToken)
            put("platform", "android")
            put("bundleId", "com.example.push_test_flutter_example")
            put("appVersion", "1.0.0")
            put("timestamp", SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.US).format(Date()))
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
    }
  }

  private fun sendEventToServer(eventName: String, properties: Map<*, *>?, email: String) {
    CoroutineScope(Dispatchers.IO).launch {
      try {
        val url = URL("$baseUrl/events/push")
        val connection = url.openConnection() as HttpURLConnection
        connection.requestMethod = "POST"
        connection.setRequestProperty("Content-Type", "application/json")
        connection.setRequestProperty("Authorization", "Bearer $apiKey")
        connection.doOutput = true

        val body = JSONObject().apply {
          put("email", email)
          put("eventName", eventName)
          put("properties", properties ?: JSONObject())
          put("platform", "android")
          put("bundleId", "com.gomailer.pushTestFlutterExample")
          put("appVersion", "1.0.0")
          put("timestamp", SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.US).format(Date()))
        }

        val outputStream = connection.outputStream
        val writer = OutputStreamWriter(outputStream)
        writer.write(body.toString())
        writer.flush()
        writer.close()

        val responseCode = connection.responseCode
        Log.d("GoMailer", "✅ Event sent to server. Status: $responseCode")
        
        connection.disconnect()
      } catch (e: Exception) {
        Log.e("GoMailer", "❌ Failed to send event: ${e.message}")
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
