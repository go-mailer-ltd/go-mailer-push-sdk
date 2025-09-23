# Go Mailer SDK Usage Examples

This document provides comprehensive examples of how to use the Go Mailer SDK across different platforms, with a focus on the proper flow for registering users and ensuring their email is sent to the backend along with the device token.

## Prerequisites

Before using the SDK, ensure you have:
1. A valid Go Mailer API key
2. Proper platform-specific setup (Firebase for Android, APNs for iOS, etc.)
3. User authentication system in place

## Basic Setup

### 1. Initialize the SDK

All platforms follow the same initialization pattern:

```typescript
// React Native
await GoMailer.initialize({
  apiKey: 'your-api-key-here',
  baseUrl: 'https://push.gomailer.com/v1',
  enableAnalytics: true,
  logLevel: GoMailerLogLevel.DEBUG
});

// Flutter
await GoMailer.initialize(
  apiKey: 'your-api-key-here',
  config: GoMailerConfig(
    baseUrl: 'https://push.gomailer.com/v1',
    enableAnalytics: true,
    logLevel: GoMailerLogLevel.debug,
  ),
);

// iOS (Swift)
GoMailer.initialize(
  apiKey: "your-api-key-here",
  config: GoMailerConfig().apply {
    baseUrl = "https://push.gomailer.com/v1"
    enableAnalytics = true
    logLevel = .debug
  }
)

// Android (Kotlin)
GoMailer.initialize(
  context,
  "your-api-key-here",
  GoMailerConfig().apply {
    baseUrl = "https://push.gomailer.com/v1"
    enableAnalytics = true
    logLevel = GoMailerLogLevel.DEBUG
  }
)
```

## User Registration Flow

### 2. Set User Information

**Always set the user before registering for push notifications:**

```typescript
// React Native
await GoMailer.setUser({
  email: 'user@example.com',
  firstName: 'John',
  lastName: 'Doe',
  phone: '+1234567890',
  customAttributes: {
    plan: 'premium',
    signupDate: '2024-01-01'
  },
  tags: ['new-user', 'verified']
});

// Flutter
await GoMailer.setUser(GoMailerUser(
  email: 'user@example.com',
  firstName: 'John',
  lastName: 'Doe',
  phone: '+1234567890',
  customAttributes: {
    'plan': 'premium',
    'signupDate': '2024-01-01'
  },
  tags: ['new-user', 'verified']
));

// iOS (Swift)
let user = GoMailerUser(id: "user123")
user.email = "user@example.com"
user.firstName = "John"
user.lastName = "Doe"
user.phone = "+1234567890"
user.customAttributes = ["plan": "premium", "signupDate": "2024-01-01"]
user.tags = ["new-user", "verified"]

GoMailer.setUser(user)

// Android (Kotlin)
val user = GoMailerUser(
  email = "user@example.com",
  firstName = "John",
  lastName = "Doe",
  phone = "+1234567890",
  customAttributes = mapOf(
    "plan" to "premium",
    "signupDate" to "2024-01-01"
  ),
  tags = listOf("new-user", "verified")
)

GoMailer.setUser(user)
```

### 3. Register for Push Notifications

**After setting the user, register for push notifications:**

```typescript
// React Native
await GoMailer.registerForPushNotifications('user@example.com');

// Flutter
await GoMailer.registerForPushNotifications(email: 'user@example.com');

// iOS (Swift)
GoMailer.registerForPushNotifications()

// Android (Kotlin)
GoMailer.registerForPushNotifications()
```

## Complete Registration Example

Here's a complete example showing the proper flow:

```typescript
// React Native - Complete Example
class PushNotificationService {
  async initializePushNotifications(userEmail: string, userData: any) {
    try {
      // 1. Initialize SDK
      await GoMailer.initialize({
        apiKey: 'your-api-key',
        baseUrl: 'https://push.gomailer.com/v1',
        enableAnalytics: true
      });

      // 2. Set user information
      await GoMailer.setUser({
        email: userEmail,
        firstName: userData.firstName,
        lastName: userData.lastName,
        customAttributes: userData.attributes
      });

      // 3. Register for push notifications
      await GoMailer.registerForPushNotifications(userEmail);

      console.log('Push notification registration completed successfully');
    } catch (error) {
      console.error('Failed to initialize push notifications:', error);
      throw error;
    }
  }

  async handleUserLogin(userEmail: string, userData: any) {
    try {
      // Update user information
      await GoMailer.setUser({
        email: userEmail,
        firstName: userData.firstName,
        lastName: userData.lastName,
        customAttributes: userData.attributes
      });

      // If we already have a device token, re-register it
      const deviceToken = await GoMailer.getDeviceToken();
      if (deviceToken) {
        console.log('Re-registering existing device token for user:', userEmail);
      }
    } catch (error) {
      console.error('Failed to handle user login:', error);
    }
  }
}
```

```dart
// Flutter - Complete Example
class PushNotificationService {
  Future<void> initializePushNotifications({
    required String userEmail,
    required Map<String, dynamic> userData,
  }) async {
    try {
      // 1. Initialize SDK
      await GoMailer.initialize(
        apiKey: 'your-api-key',
        config: GoMailerConfig(
          baseUrl: 'https://push.gomailer.com/v1',
          enableAnalytics: true,
        ),
      );

      // 2. Set user information
      await GoMailer.setUser(GoMailerUser(
        email: userEmail,
        firstName: userData['firstName'],
        lastName: userData['lastName'],
        customAttributes: userData['attributes'],
      ));

      // 3. Register for push notifications
      await GoMailer.registerForPushNotifications(email: userEmail);

      print('Push notification registration completed successfully');
    } catch (e) {
      print('Failed to initialize push notifications: $e');
      rethrow;
    }
  }

  Future<void> handleUserLogin({
    required String userEmail,
    required Map<String, dynamic> userData,
  }) async {
    try {
      // Update user information
      await GoMailer.setUser(GoMailerUser(
        email: userEmail,
        firstName: userData['firstName'],
        lastName: userData['lastName'],
        customAttributes: userData['attributes'],
      ));

      // Check if we have a device token
      final deviceToken = await GoMailer.getDeviceToken();
      if (deviceToken != null) {
        print('User logged in with existing device token: $deviceToken');
      }
    } catch (e) {
      print('Failed to handle user login: $e');
    }
  }
}
```

## What Happens Behind the Scenes

When you follow this flow, here's what the SDK automatically does:

1. **User Set**: The SDK stores the user information locally and sends it to the backend
2. **Push Registration**: The SDK requests push notification permissions from the OS
3. **Token Received**: When the OS provides a device token, the SDK automatically:
   - Sends the device token to your backend at `/push/register`
   - **Includes the user's email** in the payload
   - Associates the device token with the user account
4. **Backend Processing**: Your backend receives:
   ```json
   {
     "deviceToken": "fcm_token_here",
     "email": "user@example.com",
     "platform": "ios|android|flutter|react-native",
     "appVersion": "1.0.0"
   }
   ```

## Error Handling

Always implement proper error handling:

```typescript
try {
  await GoMailer.setUser({ email: 'user@example.com' });
  await GoMailer.registerForPushNotifications('user@example.com');
} catch (error) {
  if (error.code === GoMailerError.PUSH_NOTIFICATION_NOT_AUTHORIZED) {
    // Handle permission denied
    console.log('User denied push notification permissions');
  } else if (error.code === GoMailerError.NETWORK_ERROR) {
    // Handle network issues
    console.log('Network error, will retry later');
  } else {
    // Handle other errors
    console.error('Unexpected error:', error);
  }
}
```

## Best Practices

1. **Always set user before registration**: This ensures the email is available when the token is sent
2. **Handle token refresh**: Device tokens can change, so implement proper refresh handling
3. **Implement retry logic**: Network failures should trigger retry attempts
4. **Log registration events**: Track successful and failed registrations for debugging
5. **Handle user logout**: Clear user data and optionally unregister the device token

## Testing

To test the flow:

1. Use the staging environment: `https://push.gm-g7.xyz/v1`
2. Check your backend logs for the registration payload
3. Verify the email is included in the device token registration
4. Test with different user accounts to ensure proper association

## Troubleshooting

### Email not being sent to backend:
- Ensure `setUser()` is called before `registerForPushNotifications()`
- Check that the user object has a valid email
- Verify network connectivity and API key validity

### Device token not received:
- Check OS-level push notification permissions
- Verify platform-specific setup (Firebase, APNs)
- Check SDK initialization and configuration

### Backend registration fails:
- Verify API endpoint is correct
- Check API key permissions
- Review backend logs for specific error messages 