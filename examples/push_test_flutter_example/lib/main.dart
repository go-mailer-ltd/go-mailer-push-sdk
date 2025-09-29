import 'package:flutter/material.dart';
import 'package:go_mailer_push_sdk/go_mailer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📱 Background message received: ${message.notification?.title}');
  // The native GoMailerFirebaseMessagingService will handle display and tracking
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register Firebase background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  const apiKey = 'TmF0aGFuLTg5NzI3NDY2NDgzMy42MzI2LTE=';
  print(
    '🚀 Initializing GoMailer SDK with API key: ${apiKey.substring(0, 10)}...',
  );

  try {
    await GoMailer.initialize(
      apiKey: apiKey,
      config: GoMailerConfig(
        // baseUrl defaults to production endpoint: https://api.go-mailer.com/v1
        enableAnalytics: true,
        logLevel: GoMailerLogLevel.debug,
      ),
    );
    print('✅ GoMailer SDK initialized successfully');
  } catch (e) {
    print('❌ Failed to initialize GoMailer SDK: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: GoMailerDemoPage());
  }
}

class GoMailerDemoPage extends StatefulWidget {
  const GoMailerDemoPage({super.key});

  @override
  State<GoMailerDemoPage> createState() => _GoMailerDemoPageState();
}

class _GoMailerDemoPageState extends State<GoMailerDemoPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _notificationsRequested = false;
  bool _userSent = false;

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _sendUser() async {
    final email = _emailController.text.trim();
    if (email.isNotEmpty) {
      try {
        final user = GoMailerUser(email: email);
        await GoMailer.setUser(user);
        setState(() {
          _userSent = true;
        });
        _showSnack('✅ User data sent to backend: $email');
      } catch (e) {
        _showSnack('❌ Failed to send user data: $e');
      }
    } else {
      _showSnack('Please enter an email address');
    }
  }

  Future<void> _requestNotifications() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showSnack('Please enter an email address first');
      return;
    }

    if (!_userSent) {
      _showSnack('⚠️ Please set user data first (click "Send User Data")');
      return;
    }

    try {
      await GoMailer.registerForPushNotifications(email: email);
      setState(() {
        _notificationsRequested = true;
      });
      _showSnack('✅ Notification permission requested for: $email');
    } catch (e) {
      _showSnack('❌ Failed to request notifications: $e');
    }
  }

  Future<void> _testCompleteFlow() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showSnack('Please enter an email address first');
      return;
    }

    try {
      // Step 1: Set user data
      final user = GoMailerUser(email: email);
      await GoMailer.setUser(user);
      setState(() {
        _userSent = true;
      });
      _showSnack('✅ Step 1: User data sent to backend');

      // Step 2: Register for push notifications
      await GoMailer.registerForPushNotifications(email: email);
      setState(() {
        _notificationsRequested = true;
      });
      _showSnack('✅ Step 2: Push notifications registered');

      // Step 3: Get device token
      final deviceToken = await GoMailer.getDeviceToken();
      if (deviceToken != null) {
        final displayLength = deviceToken.length > 20 ? 20 : deviceToken.length;
        _showSnack(
          '✅ Step 3: Device token received: ${deviceToken.substring(0, displayLength)}...',
        );
      } else {
        _showSnack(
          '⚠️ Device token not yet available - check console for status',
        );
      }

      // Step 4: Track some events
      await _trackSampleEvents();
    } catch (e) {
      _showSnack('❌ Flow failed: $e');
    }
  }

  Future<void> _trackSampleEvents() async {
    try {
      // Track app opened event
      await GoMailer.trackEvent(
        eventName: 'app_opened',
        properties: {
          'source': 'flutter_example',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      print('📊 Tracked app_opened event');

      // Track button clicked event
      await GoMailer.trackEvent(
        eventName: 'button_clicked',
        properties: {
          'button_name': 'test_complete_flow',
          'user_email': _emailController.text.trim(),
        },
      );
      print('📊 Tracked button_clicked event');

      // Track user registration event
      await GoMailer.trackEvent(
        eventName: 'user_registered',
        properties: {
          'platform': 'flutter',
          'email_provided': _emailController.text.trim().isNotEmpty,
        },
      );
      print('📊 Tracked user_registered event');

      // Track notification interaction events (these will be triggered when notifications are clicked)
      await GoMailer.trackEvent(
        eventName: 'notification_interaction_ready',
        properties: {
          'platform': 'flutter',
          'notification_tracking_enabled': true,
        },
      );
      print('📊 Tracked notification_interaction_ready event');

      _showSnack('✅ Step 4: Sample events tracked');
    } catch (e) {
      print('❌ Failed to track events: $e');
      _showSnack('⚠️ Event tracking failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('GoMailer Flutter Example')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Enter your email:'),
            SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'user@example.com',
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _testCompleteFlow,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('🚀 Test Complete Flow (Recommended)'),
            ),
            SizedBox(height: 16),
            Text(
              'Or test step by step:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _sendUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text('1️⃣ Send User Data to Backend'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _userSent ? _requestNotifications : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _userSent ? Colors.orange : Colors.grey,
                foregroundColor: Colors.white,
              ),
              child: Text('2️⃣ Request Notification Permission'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _userSent ? _trackSampleEvents : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _userSent ? Colors.purple : Colors.grey,
                foregroundColor: Colors.white,
              ),
              child: Text('3️⃣ Track Sample Events'),
            ),
            SizedBox(height: 32),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('User Data: ${_userSent ? "✅ Sent" : "❌ Not Sent"}'),
                  Text(
                    'Notifications: ${_notificationsRequested ? "✅ Requested" : "❌ Not Requested"}',
                  ),
                  Text(
                    'Event Tracking: ${_userSent ? "✅ Available" : "❌ Not Available"}',
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                'GoMailer SDK Initialized!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
