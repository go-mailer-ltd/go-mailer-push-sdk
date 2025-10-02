package com.gomailer.go_mailer

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel.Result
import android.util.Log
import android.content.Context
import android.content.SharedPreferences
import kotlinx.coroutines.*
import kotlinx.coroutines.tasks.await
import org.json.JSONObject
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import java.util.concurrent.TimeUnit
import java.text.SimpleDateFormat
import java.util.*

/** GoMailerPlugin */
class GoMailerPlugin: FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var eventChannel: EventChannel
  private var apiKey: String? = null
  private var baseUrl: String = "https://api.go-mailer.com/v1"
  private var currentEmail: String? = null
  private var deviceToken: String? = null
  private var eventsSink: EventChannel.EventSink? = null
  // Queue for events attempted before token registration or during transient failures
  private val pendingEvents = Collections.synchronizedList(mutableListOf<Triple<String, Map<*, *>?, String>>())
  private val MAX_PENDING_EVENTS = 100

  private val jsonMedia = "application/json; charset=utf-8".toMediaType()
  private val client = OkHttpClient.Builder()
    .connectTimeout(10, TimeUnit.SECONDS)
    .readTimeout(15, TimeUnit.SECONDS)
    .writeTimeout(15, TimeUnit.SECONDS)
    .retryOnConnectionFailure(true)
    .build()

  private val scope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
  private var appContext: android.content.Context? = null
  private var prefs: SharedPreferences? = null
  private val PREFS_NAME = "gomailer_sdk_prefs"
  private val KEY_PENDING_EVENTS = "pending_events_json"

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "go_mailer")
    channel.setMethodCallHandler(this)
    eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "go_mailer_events")
    eventChannel.setStreamHandler(this)
  appContext = flutterPluginBinding.applicationContext
  prefs = appContext?.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
  // Load any persisted pending events
  restorePendingEvents()
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "initialize" -> {
        Log.d("GoMailer", "🚀 Initializing Go Mailer plugin")
        val args = call.arguments as? Map<*, *>
  apiKey = args?.get("apiKey") as? String
  val masked = apiKey?.let { if (it.length > 6) it.substring(0,6) + "***" else it } ?: "null"
  Log.d("GoMailer", "✅ API Key set (masked): $masked")
        
        // Extract baseUrl from config if provided
        val config = args?.get("config") as? Map<*, *>
        val configBaseUrl = config?.get("baseUrl") as? String
        if (configBaseUrl != null) {
          baseUrl = configBaseUrl
          Log.d("GoMailer", "🌐 Base URL set: $baseUrl")
        }
        
        // Configure Firebase Messaging Service
        GoMailerFirebaseMessagingService.setConfig(apiKey, baseUrl, currentEmail)
        emitEvent("initialized", mapOf(
          "baseUrl" to baseUrl,
          "email" to (currentEmail ?: ""))
        )
        result.success(null)
      }
      "registerForPushNotifications" -> {
        Log.d("GoMailer", "📱 Registering for push notifications")
        val args = call.arguments as? Map<*, *>
  currentEmail = args?.get("email") as? String
  Log.d("GoMailer", "📧 Email set for registration: ${maskEmail(currentEmail)}")
        
        // Get FCM token and send to backend
        scope.launch {
          try {
            val token = com.google.firebase.messaging.FirebaseMessaging.getInstance().token.await()
            Log.d("GoMailer", "✅ FCM token obtained: ${token.take(20)}...")
            
            // Send token to backend
            sendTokenToServer(currentEmail ?: "", token)
            deviceToken = token
            emitEvent("registered", mapOf("deviceToken" to token, "email" to (currentEmail ?: "")))
            
            withContext(Dispatchers.Main) {
              result.success(token)
            }
          } catch (e: Exception) {
            Log.e("GoMailer", "❌ Failed to register for push notifications: ${e.message}")
            emitEvent("register_failed", mapOf("error" to (e.message ?: "unknown")))
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
  Log.d("GoMailer", "📧 User email set: ${maskEmail(currentEmail)}")
        
        // Update Firebase Messaging Service with new email
        GoMailerFirebaseMessagingService.setConfig(apiKey, baseUrl, currentEmail)
        
        result.success(null)
      }
      "trackEvent" -> {
        Log.d("GoMailer", "📊 Tracking event")
        val args = call.arguments as? Map<*, *>
        val eventName = args?.get("eventName") as? String ?: "unknown"
        val properties = args?.get("properties") as? Map<*, *>
  Log.d("GoMailer", "📊 Event: $eventName, Properties: $properties, email=${maskEmail(currentEmail)}")
        queueOrSendEvent(eventName, properties, currentEmail ?: "")
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
        
        Log.d("GoMailer", "👆 Notification click: $notificationId (queueOrSend)")
        queueOrSendEvent("notification_clicked", properties, email)
        result.success(null)
      }
      "getDeviceToken" -> {
        Log.d("GoMailer", "🔑 Getting device token")
        scope.launch {
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
      "getSdkInfo" -> {
        val info = mapOf(
          "version" to "1.3.0",
          "baseUrl" to baseUrl,
          "email" to (currentEmail ?: ""),
          "deviceToken" to (deviceToken ?: "")
        )
        result.success(info)
      }
      "flushPendingEvents" -> {
        scope.launch { flushPendingEvents() }
        result.success(null)
      }
      else -> result.notImplemented()
    }
  }

  private fun sendTokenToServer(email: String, token: String) {
    scope.launch { performWithBackoff("token_registration") { attempt ->
      try {
  val bundleId = appContext?.packageName ?: "com.gomailer.go_mailer"
        val json = JSONObject().apply {
          put("email", email)
          put("maskedEmail", maskEmail(email))
          put("gm_mobi_push", JSONObject().apply {
            put("deviceToken", token)
            put("platform", "android")
            put("bundleId", bundleId)
            put("appVersion", "1.3.0")
            put("timestamp", isoUtc())
          })
        }
        val req = Request.Builder()
          .url("$baseUrl/contacts")
          .header("Content-Type", "application/json")
          .apply { apiKey?.let { header("Authorization", "Bearer $it") } }
          .post(json.toString().toRequestBody(jsonMedia))
          .build()
        client.newCall(req).execute().use { resp ->
          val code = resp.code
          val bodyStr = resp.body?.string()
          Log.d("GoMailer", "📤 Device token POST attempt=$attempt status=$code")
          return@performWithBackoff if (resp.isSuccessful) {
            true // Completed successfully, do not retry
          } else {
            val retryable = code == 429 || code >= 500
            if (!retryable) {
              emitEvent("token_failed", mapOf("status" to code, "body" to (bodyStr ?: "")))
            }
            retryable // true means should retry, false means stop
          }
        }
      } catch (e: Exception) {
        Log.e("GoMailer", "❌ Token POST error attempt=$attempt : ${e.message}")
        return@performWithBackoff true // network or transient error -> retry
      }
    } ?: run {
      emitEvent("token_failed", mapOf("error" to "exhausted_retries"))
    } }
  }

  private fun sendEventToServer(eventName: String, properties: Map<*, *>?, email: String) {
    scope.launch { performWithBackoff("event_$eventName") { attempt ->
      try {
  val bundleId = appContext?.packageName ?: "com.gomailer.go_mailer"
        val json = JSONObject().apply {
          put("email", email)
          put("maskedEmail", maskEmail(email))
          put("eventName", eventName)
          put("properties", properties ?: JSONObject())
          put("platform", "android")
          put("bundleId", bundleId)
          put("appVersion", "1.3.0")
          put("timestamp", isoUtc())
        }
        val req = Request.Builder()
          .url("$baseUrl/events/push")
          .header("Content-Type", "application/json")
          .header("Authorization", "Bearer $apiKey")
          .post(json.toString().toRequestBody(jsonMedia))
          .build()
        client.newCall(req).execute().use { resp ->
          val code = resp.code
          Log.d("GoMailer", "📡 Event POST '$eventName' attempt=$attempt status=$code")
          return@performWithBackoff if (resp.isSuccessful) {
            emitEvent("event_tracked", mapOf("event" to eventName))
            true
          } else {
            val retryable = code == 429 || code >= 500
            if (!retryable) {
              emitEvent("event_failed", mapOf("event" to eventName, "status" to code))
            }
            retryable
          }
        }
      } catch (e: Exception) {
        Log.e("GoMailer", "❌ Event POST error '$eventName' attempt=$attempt : ${e.message}")
        return@performWithBackoff true
      }
    } ?: run {
      emitEvent("event_failed", mapOf("event" to eventName, "error" to "exhausted_retries"))
    } }
  }

  private suspend fun performWithBackoff(
    label: String,
    maxRetries: Int = 5,
    initialDelayMs: Long = 500,
    factor: Double = 2.0,
    jitterMs: Long = 150,
    block: suspend (attempt: Int) -> Boolean // true means retry, false means completed (success or terminal)
  ): Boolean? {
    var delayMs = initialDelayMs
    for (attempt in 1..maxRetries) {
      val shouldRetry = block(attempt)
      if (!shouldRetry) return true
      if (attempt < maxRetries) {
        val jitter = (0..jitterMs).random()
        val total = delayMs + jitter
        Log.d("GoMailer", "⏳ Backoff label=$label attempt=$attempt waiting=${total}ms")
        delay(total)
        delayMs = (delayMs * factor).toLong().coerceAtMost(10_000)
      }
    }
    return null
  }

  private fun queueOrSendEvent(eventName: String, properties: Map<*, *>?, email: String) {
    if (deviceToken == null) {
      var dropped: Triple<String, Map<*, *>?, String>? = null
      synchronized(pendingEvents) {
        if (pendingEvents.size >= MAX_PENDING_EVENTS) {
          dropped = pendingEvents.removeAt(0)
        }
        pendingEvents.add(Triple(eventName, properties, email))
      }
      if (dropped != null) {
        Log.w("GoMailer", "🗑️ Dropping oldest queued event '${dropped!!.first}' due to capacity $MAX_PENDING_EVENTS")
        emitEvent("event_dropped", mapOf("event" to dropped!!.first, "reason" to "queue_full"))
      }
      Log.d("GoMailer", "🕓 Queued event '$eventName' (device token pending)")
      emitEvent("event_queued", mapOf("event" to eventName))
      persistPendingEvents()
    } else {
      sendEventToServer(eventName, properties, email)
    }
  }

  private suspend fun flushPendingEvents() {
    if (deviceToken == null || pendingEvents.isEmpty()) return
    val toFlush = synchronized(pendingEvents) { val copy = pendingEvents.toList(); pendingEvents.clear(); copy }
    Log.d("GoMailer", "🚚 Flushing ${toFlush.size} queued events")
    toFlush.forEach { (name, props, email) -> sendEventToServer(name, props, email) }
    persistPendingEvents() // clear persisted copy
  }

  private fun isoUtc(): String = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.US).apply {
    timeZone = TimeZone.getTimeZone("UTC")
  }.format(Date())

  private fun emitEvent(type: String, data: Map<String, Any?>) {
    eventsSink?.success(mapOf("type" to type, "data" to data))
  }

  private fun maskEmail(email: String?): String {
    if (email.isNullOrEmpty()) return ""
    val parts = email.split("@")
    val local = parts[0]
    val maskedLocal = when {
      local.length <= 1 -> "*"
      local.length == 2 -> local.first() + "*"
      else -> local.substring(0, 2) + "***"
    }
    return if (parts.size > 1) maskedLocal + "@" + parts[1] else maskedLocal
  }

  // EventChannel.StreamHandler
  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    eventsSink = events
    emitEvent("stream_ready", emptyMap())
  }

  override fun onCancel(arguments: Any?) {
    eventsSink = null
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    eventChannel.setStreamHandler(null)
    scope.cancel()
  }

  // Persistence helpers
  private fun persistPendingEvents() {
    try {
      val arr = org.json.JSONArray()
      synchronized(pendingEvents) {
        pendingEvents.forEach { (name, props, email) ->
          val obj = org.json.JSONObject()
          obj.put("name", name)
          obj.put("email", email)
          obj.put("properties", if (props != null) org.json.JSONObject(props) else org.json.JSONObject())
          arr.put(obj)
        }
      }
      prefs?.edit()?.putString(KEY_PENDING_EVENTS, arr.toString())?.apply()
    } catch (e: Exception) {
      Log.w("GoMailer", "⚠️ Failed to persist pending events: ${e.message}")
    }
  }

  private fun restorePendingEvents() {
    try {
      val raw = prefs?.getString(KEY_PENDING_EVENTS, null) ?: return
      val arr = org.json.JSONArray(raw)
      for (i in 0 until arr.length()) {
        val obj = arr.getJSONObject(i)
        val name = obj.getString("name")
        val email = obj.getString("email")
        val propsObj = obj.optJSONObject("properties")
        val map: Map<String, Any?>? = propsObj?.let { json ->
          val keys = json.keys()
          val temp = mutableMapOf<String, Any?>()
          while (keys.hasNext()) {
            val k = keys.next()
            temp[k] = json.get(k)
          }
            temp
        }
        pendingEvents.add(Triple(name, map, email))
      }
      if (pendingEvents.isNotEmpty()) {
        Log.d("GoMailer", "🔁 Restored ${pendingEvents.size} pending events from disk")
      }
    } catch (e: Exception) {
      Log.w("GoMailer", "⚠️ Failed to restore pending events: ${e.message}")
    }
  }
}
