package com.gomailer

import android.content.Context
import android.util.Log
import com.gomailer.models.GoMailerConfig
import com.gomailer.models.GoMailerEnvironment
import io.mockk.*
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import kotlin.test.assertFailsWith
import kotlin.test.assertNotNull

@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE)
class GoMailerTest {
    private lateinit var context: Context
    private val apiKey = "test-api-key"
    private val testConfig = GoMailerConfig(
        apiKey = apiKey,
        environment = GoMailerEnvironment.DEVELOPMENT
    )

    @Before
    fun setup() {
        context = mockk(relaxed = true)
        mockkStatic(Log::class)
        every { Log.d(any(), any()) } returns 0
        every { Log.i(any(), any()) } returns 0
        every { Log.e(any(), any()) } returns 0
        every { Log.e(any(), any(), any()) } returns 0

        // Reset static state before each test
        setStaticField(GoMailer::class.java, "isInitialized", false)
        setStaticField(GoMailer::class.java, "instance", null)
        setStaticField(GoMailer::class.java, "manager", null)
    }

    @Test
    fun `test initialization with valid API key`() {
        GoMailer.initialize(context, apiKey)
        assertNotNull(GoMailer.getInstance())
    }

    @Test
    fun `test initialization with empty API key`() {
        // Reset isInitialized flag before test
        setStaticField(GoMailer::class.java, "isInitialized", false)
        setStaticField(GoMailer::class.java, "instance", null)
        setStaticField(GoMailer::class.java, "manager", null)

        assertFailsWith<IllegalArgumentException> {
            GoMailer.initialize(context, "")
        }
    }

    // Helper method to set private static field
    private fun setStaticField(clazz: Class<*>, fieldName: String, value: Any?) {
        val field = clazz.getDeclaredField(fieldName)
        field.isAccessible = true
        java.lang.reflect.Modifier.toString(field.modifiers).contains("static")
        field.set(null, value)
    }

    @Test
    fun `test initialization with custom config`() {
        GoMailer.initialize(context, apiKey, testConfig)
        assertNotNull(GoMailer.getInstance())
    }

    companion object {
        private const val TAG = "GoMailer"
    }
}
