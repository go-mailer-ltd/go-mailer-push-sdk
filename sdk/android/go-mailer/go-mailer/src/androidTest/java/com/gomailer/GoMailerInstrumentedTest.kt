package com.gomailer

import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import com.gomailer.models.GoMailerConfig
import com.gomailer.models.GoMailerEnvironment
import com.gomailer.models.GoMailerUser
import org.junit.Assert.*
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class GoMailerInstrumentedTest {
    private val context = InstrumentationRegistry.getInstrumentation().targetContext
    private val apiKey = "test-api-key"

    @Before
    fun setup() {
        // Reset SDK state before each test
        GoMailer::class.java.getDeclaredField("instance").apply {
            isAccessible = true
            set(null, null)
        }
        GoMailer::class.java.getDeclaredField("isInitialized").apply {
            isAccessible = true
            setBoolean(null, false)
        }
    }

    @Test
    fun useAppContext() {
        assertEquals("com.gomailer.test", context.packageName)
    }

    @Test
    fun testInitialization() {
        GoMailer.initialize(context, apiKey)
        assertNotNull(GoMailer.getInstance())
    }

    @Test
    fun testCustomConfig() {
        val config = GoMailerConfig(
            apiKey = apiKey,
            environment = GoMailerEnvironment.DEVELOPMENT
        )
        GoMailer.initialize(context, apiKey, config)
        
        val instance = GoMailer.getInstance()
        assertNotNull(instance)
    }

    @Test
    fun testUserOperations() {
        GoMailer.initialize(context, apiKey)
        
        val user = GoMailerUser(
            email = "test@example.com",
            firstName = "Test",
            lastName = "User"
        )
        GoMailer.setUser(user)
        
        // Test attributes
        GoMailer.setUserAttributes(mapOf(
            "age" to 25,
            "premium" to true
        ))
        
        // Test tags
        GoMailer.addUserTags(listOf("beta-tester"))
        GoMailer.removeUserTags(listOf("old-tag"))
    }

    @Test
    fun testEventTracking() {
        GoMailer.initialize(context, apiKey)
        
        GoMailer.trackEvent("test_event", mapOf(
            "category" to "test",
            "value" to 100
        ))
    }
}
