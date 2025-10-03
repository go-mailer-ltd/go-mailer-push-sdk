package com.gomailer.androidexample

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.lifecycle.lifecycleScope
import com.gomailer.androidexample.databinding.ActivityTestBinding
import com.google.firebase.messaging.FirebaseMessaging
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.*

class TestActivity : AppCompatActivity() {

    private lateinit var binding: ActivityTestBinding
    private lateinit var goMailerClient: GoMailerClient
    private var deviceToken: String? = null
    private var apiKey: String = ""
    private var environment: String = ""

    private val requestPermissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { isGranted: Boolean ->
        if (isGranted) {
            Log.d(TAG, "✅ Notification permission granted")
            initializeFirebase()
        } else {
            Log.w(TAG, "❌ Notification permission denied")
            showErrorMessage("Notification permission denied")
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityTestBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Get passed data from MainActivity
        apiKey = intent.getStringExtra("apiKey") ?: ""
        environment = intent.getStringExtra("environment") ?: "development"

        setupGoMailerClient()
        setupUI()
        checkNotificationPermission()
    }

    private fun setupGoMailerClient() {
        val baseUrl = when (environment) {
            "production" -> "https://api.gomailer.com/v1"
            "staging" -> "https://api-staging.gomailer.com/v1"
            else -> "https://api.gm-g6.xyz/v1" // development
        }
        
        goMailerClient = GoMailerClient(
            apiKey = apiKey,
            baseUrl = baseUrl
        )
        
        // Update UI with configuration
        binding.apiKeyValue.text = apiKey
        binding.environmentValue.text = environment
        
        Log.d(TAG, "🚀 GoMailer client initialized with $environment environment")
    }

    private fun setupUI() {
        // Set default email
        binding.emailInput.setText("nathan+android@go-mailer.com")
        
        binding.sendTestButton.setOnClickListener {
            sendTestNotification()
        }

        binding.changeEnvironmentButton.setOnClickListener {
            finish() // Go back to configuration screen
        }

        binding.clearLogsButton.setOnClickListener {
            binding.logsText.text = ""
            hideMessages()
        }

        // Hide all message cards initially
        hideMessages()
    }

    private fun checkNotificationPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            when {
                ContextCompat.checkSelfPermission(
                    this,
                    Manifest.permission.POST_NOTIFICATIONS
                ) == PackageManager.PERMISSION_GRANTED -> {
                    Log.d(TAG, "✅ Notification permission already granted")
                    initializeFirebase()
                }
                else -> {
                    Log.d(TAG, "🔒 Requesting notification permission")
                    requestPermissionLauncher.launch(Manifest.permission.POST_NOTIFICATIONS)
                }
            }
        } else {
            initializeFirebase()
        }
    }

    private fun initializeFirebase() {
        FirebaseMessaging.getInstance().token.addOnCompleteListener { task ->
            if (!task.isSuccessful) {
                Log.w(TAG, "❌ Fetching FCM registration token failed", task.exception)
                addLog("❌ Failed to get Firebase token: ${task.exception?.message}")
                return@addOnCompleteListener
            }

            val token = task.result
            deviceToken = token
            
            Log.d(TAG, "✅ FCM token received")
            addLog("✅ Firebase token generated successfully")
            
            // Update UI to show device token
            binding.deviceTokenCard.visibility = View.VISIBLE
            binding.deviceTokenValue.text = token
        }
    }

    private fun sendTestNotification() {
        val email = binding.emailInput.text.toString().trim()
        if (email.isEmpty()) {
            binding.emailInputLayout.error = "Please enter an email address"
            return
        }
        
        if (!email.contains("@")) {
            binding.emailInputLayout.error = "Please enter a valid email address"
            return
        }
        
        binding.emailInputLayout.error = null
        
        // Show loading state
        binding.progressBar.visibility = View.VISIBLE
        binding.sendTestButton.isEnabled = false
        hideMessages()
        
        addLog("🚀 Starting test notification flow with API key: ${apiKey.take(10)}...")
        
        lifecycleScope.launch {
            try {
                addLog("👤 Setting user with email: $email")
                
                // Set user first
                val userSuccess = goMailerClient.setUser(email)
                if (!userSuccess) {
                    throw Exception("Failed to set user")
                }
                addLog("✅ User set successfully")
                
                // Check if we have device token
                if (deviceToken == null) {
                    throw Exception("No device token available yet. Check device permissions and Firebase setup.")
                }
                
                addLog("🔔 Registering for push notifications for email: $email")
                
                // Register for push notifications
                val registerSuccess = goMailerClient.registerDeviceToken(email, deviceToken!!)
                if (!registerSuccess) {
                    throw Exception("Push registration failed")
                }
                
                addLog("✅ Push notification registration completed successfully")
                showSuccessMessage("Successfully registered for notifications! Check your email for a test notification.")
                
            } catch (e: Exception) {
                addLog("❌ Error during test: ${e.message}")
                showErrorMessage("Error: ${e.message}")
            } finally {
                binding.progressBar.visibility = View.GONE
                binding.sendTestButton.isEnabled = true
            }
        }
    }

    private fun addLog(message: String) {
        val timestamp = SimpleDateFormat("HH:mm:ss", Locale.getDefault()).format(Date())
        val logMessage = "[$timestamp] $message\n"
        
        runOnUiThread {
            binding.logsText.append(logMessage)
            binding.scrollView.post {
                binding.scrollView.fullScroll(View.FOCUS_DOWN)
            }
        }
        
        Log.d(TAG, message)
    }

    private fun showSuccessMessage(message: String) {
        binding.successCard.visibility = View.VISIBLE
        binding.successMessage.text = message
        binding.errorCard.visibility = View.GONE
    }

    private fun showErrorMessage(message: String) {
        binding.errorCard.visibility = View.VISIBLE
        binding.errorMessage.text = message
        binding.successCard.visibility = View.GONE
    }

    private fun hideMessages() {
        binding.successCard.visibility = View.GONE
        binding.errorCard.visibility = View.GONE
    }

    companion object {
        private const val TAG = "GoMailerExample"
    }
}