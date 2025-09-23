package com.gomailer.go_mailer

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.media.RingtoneManager
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import kotlinx.coroutines.*
import org.json.JSONObject
import java.io.OutputStreamWriter
import java.net.HttpURLConnection
import java.net.URL
import java.text.SimpleDateFormat
import java.util.*

class GoMailerFirebaseMessagingService : FirebaseMessagingService() {
    
    companion object {
        private const val TAG = "GoMailerFCM"
        private const val CHANNEL_ID = "go_mailer_notifications"
        private const val NOTIFICATION_ID = 1
        private var apiKey: String? = null
        private var baseUrl: String = "https://api.go-mailer.com/v1"
        private var currentEmail: String? = null
        
        fun setConfig(apiKey: String?, baseUrl: String?, email: String?) {
            this.apiKey = apiKey
            if (baseUrl != null) this.baseUrl = baseUrl
            this.currentEmail = email
        }
    }
    
    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)
        
        Log.d(TAG, "📨 FCM message received from: ${remoteMessage.from}")

        // Handle notification payload
        remoteMessage.notification?.let { notification ->
            Log.d(TAG, "📨 Notification Title: ${notification.title}")
            Log.d(TAG, "📨 Notification Body: ${notification.body}")

            showNotification(
                title = notification.title ?: "Go Mailer",
                body = notification.body ?: "New notification",
                data = remoteMessage.data
            )
        }

        // Handle data payload - ALWAYS show notification for data-only messages
        if (remoteMessage.data.isNotEmpty()) {
            Log.d(TAG, "📨 Message data payload: ${remoteMessage.data}")

            // Show notification even if no notification payload (for foreground)
            if (remoteMessage.notification == null) {
                showNotification(
                    title = remoteMessage.data["title"] ?: "Go Mailer",
                    body = remoteMessage.data["body"] ?: "New message received",
                    data = remoteMessage.data
                )
            }
        }
        
        // Track notification received event
        val properties = mapOf(
            "notification_id" to (remoteMessage.messageId ?: "unknown"),
            "notification_title" to (remoteMessage.notification?.title ?: "Unknown"),
            "notification_body" to (remoteMessage.notification?.body ?: ""),
            "data" to remoteMessage.data,
            "received_timestamp" to SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.US).format(Date())
        )
        
        sendEventToServer("notification_received", properties, currentEmail ?: "")
    }
    
    override fun onNewToken(token: String) {
        super.onNewToken(token)
        Log.d("GoMailer", "🔑 New FCM token: ${token.take(20)}...")
        
        // Track new token event
        val properties = mapOf(
            "token" to token,
            "token_timestamp" to SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.US).format(Date())
        )
        
        sendEventToServer("fcm_token_refreshed", properties, currentEmail ?: "")
    }
    
    private fun showNotification(title: String, body: String, data: Map<String, String>) {
        // Get the main activity class dynamically
        val packageName = applicationContext.packageName
        val mainActivityClass = try {
            Class.forName("$packageName.MainActivity")
        } catch (e: ClassNotFoundException) {
            Log.e(TAG, "MainActivity not found, using generic intent")
            null
        }

        val intent = if (mainActivityClass != null) {
            Intent(this, mainActivityClass)
        } else {
            packageManager.getLaunchIntentForPackage(packageName) ?: Intent()
        }
        
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
        data.forEach { (key, value) -> intent.putExtra(key, value) } // Pass data to activity
        
        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent,
            PendingIntent.FLAG_ONE_SHOT or PendingIntent.FLAG_IMMUTABLE
        )

        val defaultSoundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
        val notificationBuilder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_dialog_info) // Generic icon
            .setContentTitle(title)
            .setContentText(body)
            .setAutoCancel(true)
            .setSound(defaultSoundUri)
            .setContentIntent(pendingIntent)

        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        // Create the NotificationChannel, but only on API 26+ because
        // the NotificationChannel class is new and not in the support library
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Go Mailer Notifications",
                NotificationManager.IMPORTANCE_DEFAULT
            )
            notificationManager.createNotificationChannel(channel)
        }

        notificationManager.notify(NOTIFICATION_ID, notificationBuilder.build())
        Log.d(TAG, "✅ Notification displayed: $title")

        // Track notification displayed event
        val properties = mapOf(
            "notification_id" to (data["notification_id"] ?: "unknown"),
            "notification_title" to title,
            "notification_body" to body,
            "data" to data,
            "displayed_timestamp" to SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.US).format(Date())
        )
        // Note: notification_clicked will be tracked when user taps the notification
        // This is handled by the PendingIntent and the app's MainActivity
    }
    
    private fun sendEventToServer(eventName: String, properties: Map<String, Any>, email: String) {
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
                    put("properties", JSONObject(properties))
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
}
