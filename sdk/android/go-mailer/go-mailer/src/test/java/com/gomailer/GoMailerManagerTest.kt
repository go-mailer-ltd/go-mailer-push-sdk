package com.gomailer

import android.content.Context
import android.util.Log
import com.gomailer.models.GoMailerConfig
import com.gomailer.models.GoMailerEnvironment
import io.mockk.*
import io.mockk.coEvery
import io.mockk.coVerify
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.*
import okhttp3.Call
import okhttp3.OkHttpClient
import okhttp3.Response
import okhttp3.ResponseBody
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

@ExperimentalCoroutinesApi
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [Config.NEWEST_SDK])
class GoMailerManagerTest {
    private lateinit var context: Context
    private lateinit var config: GoMailerConfig
    private lateinit var httpClient: OkHttpClient
    private lateinit var manager: GoMailerManager

    private val testDispatcher = StandardTestDispatcher()

    @Before
    fun setup() {
        Dispatchers.setMain(testDispatcher)
        
        context = mockk(relaxed = true)
        config = GoMailerConfig(
            apiKey = "test-api-key",
            environment = GoMailerEnvironment.DEVELOPMENT
        )
        httpClient = mockk()
        mockkStatic(Log::class)
        every { Log.d(any(), any()) } returns 0
        every { Log.i(any(), any()) } returns 0
        every { Log.e(any(), any()) } returns 0
        every { Log.e(any(), any(), any()) } returns 0

        manager = GoMailerManager(context, config, httpClient)
    }

    @After
    fun tearDown() {
        Dispatchers.resetMain()
        unmockkAll()
    }

    @Test
    fun `test track event success`() = runTest {
        // Given
        val call = mockk<Call>()
        val response = mockk<Response>()

        every { httpClient.newCall(any()) } returns call
        coEvery { call.execute() } returns response
        every { response.isSuccessful } returns true
        every { response.close() } just runs

        // When
        manager.trackEvent("test_event", mapOf("key" to "value"))
        testDispatcher.scheduler.advanceUntilIdle()

        // Then
        verify { httpClient.newCall(any()) }
        coVerify { call.execute() }
        verify { response.close() }
        verify { Log.d(TAG, "Tracking event: test_event with properties: {key=value}") }
    }

    @Test
    fun `test track event failure`() = runTest {
        // Given
        val call = mockk<Call>()
        val response = mockk<Response>()
        val responseBody = mockk<ResponseBody>()
        
        every { httpClient.newCall(any()) } returns call
        coEvery { call.execute() } returns response
        every { response.isSuccessful } returns false
        every { response.code } returns 400
        every { response.body } returns responseBody
        every { responseBody.string() } returns "Bad Request"
        every { response.close() } just runs

        // When
        manager.trackEvent("test_event", mapOf("key" to "value"))
        testDispatcher.scheduler.advanceUntilIdle()

        // Then
        verify { httpClient.newCall(any()) }
        coVerify { call.execute() }
        verify { 
            response.isSuccessful
            response.code
            response.body
            responseBody.string()
            response.close()
        }
        verify { Log.e(TAG, eq("Error tracking event: Bad Request")) }

        // Verify HTTP call
        verify(exactly = 1) { 
            httpClient.newCall(any())
        }
        
        // Verify initial logging
        verify(exactly = 1) {
            Log.d(eq(TAG), eq("Tracking event: test_event with properties: {key=value}"))
        }
        
        // Verify error logging
        verify(exactly = 1) {
            Log.e(eq(TAG), eq("Failed to track event: 400 Bad Request"))
        }
    }

    @Test
    fun `test set user attributes`() {
        val attributes = mapOf(
            "age" to 25,
            "premium" to true
        )
        manager.setUserAttributes(attributes)
        verify { Log.d(TAG, "Setting user attributes: $attributes") }
    }

    @Test
    fun `test add user tags`() {
        val tags = listOf("premium", "beta-tester")
        manager.addUserTags(tags)
        verify { Log.d(TAG, "Adding user tags: $tags") }
    }

    companion object {
        private const val TAG = "GoMailerManager"
    }
}
