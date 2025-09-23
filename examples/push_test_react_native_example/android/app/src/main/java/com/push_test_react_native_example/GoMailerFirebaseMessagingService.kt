package com.push_test_react_native_example

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class GoMailerFirebaseMessagingService : FirebaseMessagingService() {

    companion object {
        private const val TAG = "GoMailerFCM"
        private const val CHANNEL_ID = "go_mailer_notifications"
        private const val NOTIFICATION_ID = 1
    }

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
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
    }

    override fun onNewToken(token: String) {
        Log.d(TAG, "🔄 FCM token refreshed: $token")
        // Token will be handled by the SDK when registerForPushNotifications is called
    }

    private fun showNotification(title: String, body: String, data: Map<String, String>) {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        // Create notification channel for Android O and above
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Go Mailer Notifications",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Notifications from Go Mailer"
                enableLights(true)
                enableVibration(true)
            }
            notificationManager.createNotificationChannel(channel)
        }

        // Create intent for when notification is clicked
        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            // Add notification data as extras
            data.forEach { (key, value) ->
                putExtra(key, value)
            }
        }

        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Build and show notification
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle(title)
            .setContentText(body)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .setDefaults(NotificationCompat.DEFAULT_ALL)
            .build()

        notificationManager.notify(NOTIFICATION_ID, notification)
        
        Log.d(TAG, "✅ Notification displayed: $title")
    }
}
