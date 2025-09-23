package com.example.push_test_android_example

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import com.example.push_test_android_example.databinding.ActivityMainBinding
import com.google.firebase.messaging.FirebaseMessaging
import kotlinx.coroutines.*
import kotlinx.coroutines.delay
import org.json.JSONObject
import java.io.OutputStreamWriter
import java.net.HttpURLConnection
import java.net.URL
import java.text.SimpleDateFormat
import java.util.*

class MainActivity : AppCompatActivity() {
    
    companion object {
        private const val TAG = "MainActivity"
        private const val API_KEY = "TmF0aGFuLTg5NzI3NDY2NDgzMy42MzI2LTE=" // Go-Mailer API key
        private const val BASE_URL = "https://419c321798d9.ngrok-free.app/v1"
    }
    
    private lateinit var binding: ActivityMainBinding
    private var deviceToken: String? = null
    private var currentEmail: String? = null
    private val scope = CoroutineScope(Dispatchers.Main + SupervisorJob())
    
    // Status tracking
    private var userSent = false
    private var notificationsRequested = false
    private var eventsTracked = false
    
    private val requestPermissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { isGranted: Boolean ->
        if (isGranted) {
            Log.d(TAG, "Notification permission granted")
            registerForPushNotifications()
        } else {
            Log.d(TAG, "Notification permission denied")
            Toast.makeText(this, "Notification permission denied", Toast.LENGTH_SHORT).show()
        }
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)
        
        // Initialize Go-Mailer SDK
        initializeGoMailer()
        
        setupClickListeners()
        
        // Check if app was opened from notification click
        handleNotificationClick()
    }
    
    private fun initializeGoMailer() {
        try {
            Log.d(TAG, "🚀 Initializing Go-Mailer functionality")
            Log.d(TAG, "✅ API Key set: ${API_KEY.take(10)}...")
            Log.d(TAG, "🌐 Base URL set: $BASE_URL")
            
            // Configure the Firebase service
            GoMailerFirebaseMessagingService.setConfig(API_KEY, BASE_URL, null)
            
            Toast.makeText(this, "Go-Mailer initialized", Toast.LENGTH_SHORT).show()
        } catch (e: Exception) {
            Log.e(TAG, "Failed to initialize Go-Mailer", e)
            Toast.makeText(this, "Initialization failed: ${e.message}", Toast.LENGTH_SHORT).show()
        }
    }
    
    private fun setupClickListeners() {
        binding.btnTestCompleteFlow.setOnClickListener {
            testCompleteFlow()
        }
        
        binding.btnSendUserData.setOnClickListener {
            sendUserData()
        }
        
        binding.btnRequestPermission.setOnClickListener {
            requestNotificationPermission()
        }
        
        binding.btnTrackEvents.setOnClickListener {
            trackSampleEvents()
        }
        
        updateUI()
    }
    
    private fun requestNotificationPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            when {
                ContextCompat.checkSelfPermission(
                    this,
                    Manifest.permission.POST_NOTIFICATIONS
                ) == PackageManager.PERMISSION_GRANTED -> {
                    Log.d(TAG, "Notification permission already granted")
                    registerForPushNotifications()
                }
                shouldShowRequestPermissionRationale(Manifest.permission.POST_NOTIFICATIONS) -> {
                    // Show rationale if needed
                    Toast.makeText(this, "Notification permission is required for push notifications", Toast.LENGTH_LONG).show()
                    requestPermissionLauncher.launch(Manifest.permission.POST_NOTIFICATIONS)
                }
                else -> {
                    requestPermissionLauncher.launch(Manifest.permission.POST_NOTIFICATIONS)
                }
            }
        } else {
            // For older Android versions, permission is granted by default
            Log.d(TAG, "Android version < 13, notification permission granted by default")
            registerForPushNotifications()
        }
    }
    
    private fun registerForPushNotifications() {
        try {
            Log.d(TAG, "📱 Registering for push notifications...")
            
            FirebaseMessaging.getInstance().token.addOnCompleteListener { task ->
                if (task.isSuccessful) {
                    deviceToken = task.result
                    Log.d(TAG, "✅ FCM token obtained: ${deviceToken?.take(20)}...")
                    
                    // Send token to backend
                    scope.launch {
                        sendDeviceTokenToServer(deviceToken!!, currentEmail ?: "")
                    }
                    
                    notificationsRequested = true
                    updateUI()
                    showSnack("✅ Push notifications registered")
                } else {
                    Log.e(TAG, "❌ Failed to get FCM token", task.exception)
                    Toast.makeText(this, "Failed to get FCM token", Toast.LENGTH_SHORT).show()
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to register for push notifications", e)
            Toast.makeText(this, "Registration failed: ${e.message}", Toast.LENGTH_SHORT).show()
        }
    }
    
    private fun sendUserData() {
        val email = binding.etEmail.text.toString().trim()
        
        if (email.isEmpty()) {
            showSnack("Please enter an email address")
            return
        }
        
        try {
            currentEmail = email
            
            // Update Firebase service config
            GoMailerFirebaseMessagingService.setConfig(API_KEY, BASE_URL, currentEmail)
            
            Log.d(TAG, "👤 Setting user data: $email")
            
            // If we have a device token, send it with the user data
            deviceToken?.let { token ->
                scope.launch {
                    sendDeviceTokenToServer(token, email)
                }
            }
            
            userSent = true
            updateUI()
            showSnack("✅ User data sent to backend: $email")
            
        } catch (e: Exception) {
            Log.e(TAG, "Failed to set user data", e)
            showSnack("❌ Failed to set user data: ${e.message}")
        }
    }
    
    private fun getDeviceToken() {
        try {
            if (deviceToken != null) {
                Log.d(TAG, "🔑 Device token: $deviceToken")
                Toast.makeText(this, "Token: ${deviceToken!!.take(8)}...", Toast.LENGTH_LONG).show()
            } else {
                Log.d(TAG, "Device token not available yet")
                Toast.makeText(this, "Device token not available yet", Toast.LENGTH_SHORT).show()
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to get device token", e)
            Toast.makeText(this, "Failed to get device token: ${e.message}", Toast.LENGTH_SHORT).show()
        }
    }
    
    private fun testCompleteFlow() {
        val email = binding.etEmail.text.toString().trim()
        if (email.isEmpty()) {
            showSnack("Please enter an email address first")
            return
        }

        scope.launch {
            try {
                // Step 1: Set user data
                sendUserData()
                showSnack("✅ Step 1: User data sent to backend")
                delay(1000)

                // Step 2: Register for push notifications  
                requestNotificationPermission()
                showSnack("✅ Step 2: Push notifications registered")
                delay(1000)

                // Step 3: Get device token (if available)
                if (deviceToken != null) {
                    val displayLength = if (deviceToken!!.length > 20) 20 else deviceToken!!.length
                    showSnack("✅ Step 3: Device token received: ${deviceToken!!.substring(0, displayLength)}...")
                } else {
                    showSnack("⚠️ Device token not yet available - check console for status")
                }
                delay(1000)

                // Step 4: Setup complete
                showSnack("✅ Setup complete! Now send a test notification and click on it.")

            } catch (e: Exception) {
                showSnack("❌ Flow failed: ${e.message}")
            }
        }
    }

    private fun handleNotificationClick() {
        val wasClickedFromNotification = intent.getBooleanExtra("notification_clicked", false)
        
        if (wasClickedFromNotification) {
            val notificationId = intent.getStringExtra("notification_id") ?: "unknown"
            val notificationTitle = intent.getStringExtra("notification_title") ?: "Unknown"
            val notificationBody = intent.getStringExtra("notification_body") ?: ""
            
            Log.d(TAG, "👆 Notification clicked! ID: $notificationId")
            Log.d(TAG, "👆 Title: $notificationTitle")
            Log.d(TAG, "👆 Body: $notificationBody")
            
            // Track the notification click event
            val email = currentEmail ?: binding.etEmail.text.toString().trim()
            if (email.isNotEmpty()) {
                scope.launch(Dispatchers.IO) {
                    try {
                        sendEventToServer("notification_clicked", mapOf(
                            "notification_id" to notificationId,
                            "notification_title" to notificationTitle,
                            "notification_body" to notificationBody,
                            "clicked_timestamp" to SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.US).format(Date()),
                            "platform" to "android"
                        ), email)
                        
                        Log.d(TAG, "📊 ✅ Notification click tracked successfully!")
                        
                        withContext(Dispatchers.Main) {
                            showSnack("🎉 Notification click tracked! Check logs.")
                        }
                        
                    } catch (e: Exception) {
                        Log.e(TAG, "❌ Failed to track notification click: ${e.message}")
                        withContext(Dispatchers.Main) {
                            showSnack("❌ Failed to track notification click: ${e.message}")
                        }
                    }
                }
            }
        }
    }
    
    override fun onNewIntent(intent: Intent?) {
        super.onNewIntent(intent)
        setIntent(intent) // Update the intent
        handleNotificationClick() // Handle notification click from new intent
    }
    
    private fun trackSampleEvents() {
        // This method is now simplified - just for testing the tracking setup
        showSnack("✅ Tracking is ready! Send a notification and click on it to see the tracking in action.")
        eventsTracked = true
        updateUI()
    }

    private fun sendEventToServer(eventName: String, properties: Map<String, Any>, email: String) {
        try {
            val url = URL("$BASE_URL/events/push")
            val connection = url.openConnection() as HttpURLConnection
            connection.requestMethod = "POST"
            connection.setRequestProperty("Content-Type", "application/json")
            connection.setRequestProperty("Authorization", "Bearer $API_KEY")
            connection.doOutput = true

            val body = JSONObject().apply {
                put("email", email)
                put("eventName", eventName)
                put("properties", JSONObject(properties))
                put("platform", "android")
                put("bundleId", packageName)
                put("appVersion", "1.0.0")
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

    private fun updateUI() {
        // Update button states
        binding.btnRequestPermission.isEnabled = userSent
        binding.btnTrackEvents.isEnabled = userSent
        
        // Update status text
        binding.tvUserStatus.text = "User Data: ${if (userSent) "✅ Sent" else "❌ Not Sent"}"
        binding.tvNotificationStatus.text = "Notifications: ${if (notificationsRequested) "✅ Requested" else "❌ Not Requested"}"
        binding.tvEventStatus.text = "Click Tracking: ${if (eventsTracked) "✅ Ready" else "❌ Not Ready"}"
    }

    private fun showSnack(message: String) {
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show()
    }

    private suspend fun sendDeviceTokenToServer(token: String, email: String) {
        withContext(Dispatchers.IO) {
            try {
                val url = URL("$BASE_URL/contacts")
                val connection = url.openConnection() as HttpURLConnection
                connection.requestMethod = "POST"
                connection.setRequestProperty("Content-Type", "application/json")
                connection.setRequestProperty("Authorization", "Bearer $API_KEY")
                connection.doOutput = true

                val body = JSONObject().apply {
                    put("email", email)
                    put("gm_mobi_push", JSONObject().apply {
                        put("deviceToken", token)
                        put("platform", "android")
                        put("bundleId", packageName)
                        put("appVersion", "1.0.0")
                        put("timestamp", SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.US).format(Date()))
                    })
                }

                Log.d(TAG, "📤 Sending device token to: $url")
                Log.d(TAG, "📤 Request body: $body")

                val outputStream = connection.outputStream
                val writer = OutputStreamWriter(outputStream)
                writer.write(body.toString())
                writer.flush()
                writer.close()

                val responseCode = connection.responseCode
                Log.d(TAG, "📤 Device token sent to backend. Status: $responseCode")

                if (responseCode >= 400) {
                    val errorStream = connection.errorStream
                    val errorResponse = errorStream?.bufferedReader()?.use { it.readText() }
                    Log.e(TAG, "❌ Server error response: $errorResponse")
                }

                connection.disconnect()
            } catch (e: Exception) {
                Log.e(TAG, "❌ Failed to send device token: ${e.message}")
            }
        }
    }
    
    override fun onDestroy() {
        super.onDestroy()
        scope.cancel()
    }
} 