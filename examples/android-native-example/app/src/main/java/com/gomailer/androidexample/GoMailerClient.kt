package com.gomailer.androidexample

import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.*
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.RequestBody.Companion.toRequestBody
import okhttp3.logging.HttpLoggingInterceptor
import org.json.JSONObject
import java.io.IOException
import java.text.SimpleDateFormat
import java.util.*

class GoMailerClient(
    val apiKey: String,
    val baseUrl: String
) {
    private val client: OkHttpClient
    private val dateFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.US).apply {
        timeZone = TimeZone.getTimeZone("UTC")
    }

    init {
        val logging = HttpLoggingInterceptor { message ->
            Log.d(TAG, "HTTP: $message")
        }.apply {
            level = HttpLoggingInterceptor.Level.BODY
        }

        client = OkHttpClient.Builder()
            .addInterceptor(logging)
            .build()
    }

    suspend fun setUser(email: String): Boolean = withContext(Dispatchers.IO) {
        try {
            Log.d(TAG, "📤 Setting user: $email")
            
            val json = JSONObject().apply {
                put("email", email)
            }

            val requestBody = json.toString().toRequestBody("application/json".toMediaType())
            val request = Request.Builder()
                .url("$baseUrl/contacts")
                .post(requestBody)
                .addHeader("Authorization", "Bearer $apiKey")
                .addHeader("Content-Type", "application/json")
                .build()

            val response = client.newCall(request).execute()
            val responseBody = response.body?.string()
            
            Log.d(TAG, "📤 Set user response: ${response.code} - $responseBody")
            
            response.isSuccessful
        } catch (e: Exception) {
            Log.e(TAG, "❌ Set user failed", e)
            false
        }
    }

    suspend fun registerDeviceToken(email: String, deviceToken: String): Boolean = withContext(Dispatchers.IO) {
        try {
            Log.d(TAG, "📤 Registering device token for: $email")
            Log.d(TAG, "📱 Token: ${deviceToken.take(20)}...")
            
            val pushData = JSONObject().apply {
                put("deviceToken", deviceToken)
                put("platform", "android")
                put("bundleId", "com.gomailer.androidexample")
                put("appVersion", "1.0.0")
                put("timestamp", dateFormat.format(Date()))
            }

            val json = JSONObject().apply {
                put("email", email)
                put("gm_mobi_push", pushData)
            }

            val requestBody = json.toString().toRequestBody("application/json".toMediaType())
            val request = Request.Builder()
                .url("$baseUrl/contacts")
                .post(requestBody)
                .addHeader("Authorization", "Bearer $apiKey")
                .addHeader("Content-Type", "application/json")
                .build()

            Log.d(TAG, "📤 Request body: ${json.toString()}")
            
            val response = client.newCall(request).execute()
            val responseBody = response.body?.string()
            
            Log.d(TAG, "📤 Register token response: ${response.code} - $responseBody")
            
            if (response.isSuccessful) {
                Log.d(TAG, "✅ Device token registered successfully")
            } else {
                Log.w(TAG, "❌ Device token registration failed: ${response.code}")
            }
            
            response.isSuccessful
        } catch (e: Exception) {
            Log.e(TAG, "❌ Register device token failed", e)
            false
        }
    }

    companion object {
        private const val TAG = "GoMailerClient"
    }
}