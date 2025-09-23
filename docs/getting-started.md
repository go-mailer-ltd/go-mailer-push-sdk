# Getting Started with Go Mailer SDK

This guide will help you integrate the Go Mailer SDK into your mobile application to receive push notifications from the Go-Mailer platform.

## Prerequisites

- Go-Mailer account and API key
- Mobile app project (iOS, Android, Flutter, or React Native)
- Platform-specific development environment setup

## Quick Integration

### 1. Get Your API Key

1. Sign up for a Go-Mailer account at [gomailer.com](https://gomailer.com)
2. Navigate to the Developer section in your dashboard
3. Generate a new API key for your mobile app
4. Copy the API key (you'll need this for SDK initialization)

### 2. Choose Your Platform

Select your platform below for detailed integration instructions:

- [iOS Setup](./platform-setup/ios-setup.md)
- [Android Setup](./platform-setup/android-setup.md)
- [Flutter Setup](./platform-setup/flutter-setup.md)
- [React Native Setup](./platform-setup/react-native-setup.md)

### 3. Basic Integration Steps

All platforms follow a similar integration pattern:

1. **Install the SDK** (platform-specific)
2. **Initialize the SDK** with your API key
3. **Register for push notifications**
4. **Set the current user**
5. **Handle incoming notifications**

### 4. Testing Your Integration

1. Build and run your app
2. Check the console logs for successful initialization
3. Send a test notification from the Go-Mailer dashboard
4. Verify the notification appears on your device

## Common Issues

### SDK Initialization Fails
- Verify your API key is correct
- Check your internet connection
- Ensure the SDK is properly installed

### Push Notifications Not Received
- Verify push notification permissions are granted
- Check platform-specific push notification setup
- Ensure the device is properly registered with Go-Mailer

### User Registration Fails
- Verify the user email format
- Check network connectivity
- Review API response for error details

## Next Steps

- [API Reference](./api-reference.md) - Complete SDK documentation
- [Platform Setup Guides](./platform-setup/) - Detailed platform-specific instructions
- [Examples](../examples/) - Sample applications for each platform

## Support

If you encounter issues during integration:

1. Check the [Troubleshooting Guide](./troubleshooting.md) - Common issues and solutions
2. Review the [FAQ](./faq.md) - Frequently asked questions
3. Contact support at support@gomailer.com
4. Open an issue on our [GitHub repository](https://github.com/your-org/go-mailer-mobile-push) 