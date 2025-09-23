# Troubleshooting Guide

This guide helps you resolve common issues when integrating the Go Mailer SDK.

## Common Issues

### SDK Initialization Problems

#### Issue: SDK fails to initialize
**Symptoms:**
- Error: "Failed to initialize Go Mailer SDK"
- App crashes on startup
- No SDK logs in console

**Solutions:**
1. **Verify API Key**
   - Check that your API key is correct
   - Ensure the key is active in your Go-Mailer dashboard
   - Verify the key has the correct permissions

2. **Check Network Connectivity**
   - Ensure device has internet access
   - Check if your network blocks API calls
   - Verify firewall settings

3. **Verify Dependencies**
   - Ensure all required packages are installed
   - Check for version conflicts
   - Verify platform-specific setup is complete

#### Issue: SDK initializes but shows warnings
**Symptoms:**
- SDK initializes successfully
- Warning messages in console
- Some features may not work properly

**Solutions:**
1. **Check Configuration**
   - Verify all required configuration options
   - Ensure environment variables are set correctly
   - Check for deprecated configuration options

2. **Review Logs**
   - Enable debug logging
   - Check for specific warning messages
   - Verify API endpoint accessibility

### Push Notification Issues

#### Issue: Push notifications not received
**Symptoms:**
- SDK initializes successfully
- No push notifications appear
- Device registration appears successful

**Solutions:**
1. **Check Platform Setup**
   - **iOS**: Verify push notification capability and provisioning profile
   - **Android**: Ensure Firebase project is configured correctly
   - **Flutter/React Native**: Verify platform-specific setup

2. **Verify Permissions**
   - Check that push notification permissions are granted
   - Ensure app has notification access
   - Verify system notification settings

3. **Check Device Registration**
   - Verify device token is generated
   - Ensure token is sent to Go-Mailer backend
   - Check for registration errors in logs

#### Issue: Notifications received but not displayed
**Symptoms:**
- Push notifications arrive
- No visual notification appears
- App may be in foreground or background

**Solutions:**
1. **Foreground Handling**
   - Implement proper foreground notification handling
   - Check notification display logic
   - Verify notification channel configuration

2. **Background Handling**
   - Ensure background message handlers are registered
   - Check for background execution restrictions
   - Verify notification service configuration

### User Registration Issues

#### Issue: User registration fails
**Symptoms:**
- Error: "Failed to register user"
- User not associated with device
- Analytics not tracking correctly

**Solutions:**
1. **Check User Data**
   - Verify email format is valid
   - Ensure required user fields are provided
   - Check for special characters in user data

2. **Verify API Calls**
   - Check network requests in logs
   - Verify API endpoint accessibility
   - Check for authentication errors

3. **Review Backend Status**
   - Verify Go-Mailer service is operational
   - Check API rate limits
   - Verify account status

### Build and Integration Issues

#### Issue: Build errors during integration
**Symptoms:**
- Compilation fails
- Linker errors
- Missing dependencies

**Solutions:**
1. **Clean Build**
   - Clear build cache
   - Remove derived data
   - Clean and rebuild project

2. **Check Dependencies**
   - Verify all required packages are installed
   - Check for version conflicts
   - Update to compatible versions

3. **Platform-Specific Issues**
   - **iOS**: Check CocoaPods installation and Podfile
   - **Android**: Verify Gradle configuration and dependencies
   - **Flutter**: Check pubspec.yaml and Flutter version
   - **React Native**: Verify Metro configuration and dependencies

## Debug Mode

Enable debug logging to get more detailed information:

### iOS (Swift)
```swift
let config = GoMailerConfig()
config.logLevel = .debug
GoMailer.initialize(apiKey: "your-api-key", config: config)
```

### Android (Kotlin)
```kotlin
val config = GoMailerConfig(
    logLevel = GoMailerLogLevel.DEBUG
)
GoMailer.initialize(context, "your-api-key", config)
```

### Flutter (Dart)
```dart
final config = GoMailerConfig()
  ..logLevel = GoMailerLogLevel.debug;

await GoMailer.initialize(
  apiKey: 'your-api-key',
  config: config,
);
```

### React Native (JavaScript)
```javascript
const config = {
  apiKey: 'your-api-key',
  logLevel: 'debug',
};

await GoMailer.initialize(config);
```

## Getting Help

If you're still experiencing issues:

1. **Check Documentation**
   - Review [Getting Started Guide](./getting-started.md)
   - Check [Platform Setup Guides](./platform-setup/)
   - Review [API Reference](./api-reference.md)

2. **Enable Debug Logging**
   - Set log level to debug
   - Collect logs during the issue
   - Note any error messages or warnings

3. **Contact Support**
   - Email: support@gomailer.com
   - Include platform, SDK version, and error logs
   - Provide steps to reproduce the issue

4. **Community Resources**
   - Check [GitHub Issues](https://github.com/your-org/go-mailer-mobile-push/issues)
   - Review [GitHub Discussions](https://github.com/your-org/go-mailer-mobile-push/discussions)
   - Search existing solutions

## Prevention Tips

1. **Test Early and Often**
   - Test integration on multiple devices
   - Verify functionality in different app states
   - Test with various network conditions

2. **Keep Dependencies Updated**
   - Regularly update SDK versions
   - Check for breaking changes
   - Monitor dependency compatibility

3. **Follow Best Practices**
   - Implement proper error handling
   - Use recommended integration patterns
   - Follow platform-specific guidelines

4. **Monitor and Log**
   - Implement comprehensive logging
   - Monitor SDK performance
   - Track user engagement metrics 