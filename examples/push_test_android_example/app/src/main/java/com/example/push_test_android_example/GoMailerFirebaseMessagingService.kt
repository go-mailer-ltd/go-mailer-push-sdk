package com.example.push_test_android_example

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
        private var baseUrl: String = "https://419c321798d9.ngrok-free.app/v1"
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
                data = remoteMessage.data,
                messageId = remoteMessage.messageId
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
                    data = remoteMessage.data,
                    messageId = remoteMessage.messageId
                )
            }
        }
        
        // Only log that notification was received - no tracking events
        Log.d(TAG, "📱 Notification received and will be displayed")
    }
    
    override fun onNewToken(token: String) {
        super.onNewToken(token)
        Log.d(TAG, "🔑 New FCM token: ${token.take(20)}...")
        // Token refresh logged only - no event tracking
    }
    
    private fun showNotification(title: String, body: String, data: Map<String, String>, messageId: String?) {
        val intent = Intent(this, MainActivity::class.java)
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
        data.forEach { (key, value) -> intent.putExtra(key, value) } // Pass data to activity
        
        // Add special flag to track notification click
        intent.putExtra("notification_clicked", true)
        // Use custom notification_id from server, fallback to Firebase messageId, then "unknown"
        intent.putExtra("notification_id", data["notification_id"] ?: messageId ?: "unknown")
        intent.putExtra("notification_title", title)
        intent.putExtra("notification_body", body)
        
        val pendingIntent = PendingIntent.getActivity(
            this, System.currentTimeMillis().toInt(), intent, // Use unique request code
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
        Log.d(TAG, "👆 Notification is ready for user click tracking")
    }
    
    private fun sendEventToServer(eventName: String, properties: Map<String, Any>, email: String) {
        CoroutineScope(Dispatchers.IO).launch {
            try {
                val url = URL("$baseUrl/events/push")
                val connection = url.openConnection() as HttpURLConnection
                connection.requestMethod = "POST"
                connection.setRequestProperty("Content-Type", "application/json")
                apiKey?.let { connection.setRequestProperty("Authorization", "Bearer $it") }
                connection.doOutput = true

                val body = JSONObject().apply {
                    put("email", email)
                    put("eventName", eventName)
                    put("properties", JSONObject(properties))
                    put("platform", "android")
                    put("bundleId", packageName) // Use actual package name
                    put("appVersion", "1.0.0") // Placeholder
                    put("timestamp", SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.US).format(Date()))
                }

                val outputStream = connection.outputStream
                val writer = OutputStreamWriter(outputStream)
                writer.write(body.toString())
                writer.flush()
                writer.close()

                val responseCode = connection.responseCode
                Log.d(TAG, "📤 Event sent to backend. Status: $responseCode")

                connection.disconnect()
            } catch (e: Exception) {
                Log.e(TAG, "❌ Failed to send event: ${e.message}")
            }
        }
    }
} 