import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_mailer_push_sdk/go_mailer.dart';

class TestScreen extends StatefulWidget {
  final String apiKey;
  final String environment;

  const TestScreen({
    super.key, 
    required this.apiKey,
    required this.environment,
  });

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  StreamSubscription<Map<String, dynamic>>? _eventSub;
  Map<String, dynamic>? _lastSdkEvent;
  String? _deviceToken; // captured for display & manual backend testing

  @override
  void dispose() {
    _eventSub?.cancel();
    _emailController.dispose();
    super.dispose();
  }

  Widget _buildConfigItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.secondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _sendTestNotification() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      debugPrint('🚀 Starting test notification flow with API key: ${widget.apiKey.substring(0, 10)}...');
      
      // Initialize the SDK if not already initialized
      if (!GoMailer.isInitialized) {
        debugPrint('📱 Initializing GoMailer SDK...');
        final config = GoMailerConfig(
          environment: widget.environment == 'development'
              ? GoMailerEnvironment.development
              : widget.environment == 'staging'
                  ? GoMailerEnvironment.staging
                  : GoMailerEnvironment.production,
          logLevel: GoMailerLogLevel.debug,
        );
        debugPrint('⚙️ Using config: ${config.toMap()}');
        await GoMailer.initialize(
          apiKey: widget.apiKey,
          config: config,
        );
        debugPrint('✅ SDK initialized successfully');
      } else {
        debugPrint('ℹ️ SDK already initialized');
      }

      final email = _emailController.text;
      debugPrint('👤 Setting user with email: $email');
      
      // Identify the user first
      await GoMailer.setUser(GoMailerUser(
        email: email,
      ));
      debugPrint('✅ User set successfully');

      debugPrint('🔔 Registering for push notifications for email: $email');
      // Register for push notifications (this internally handles permissions)
      try {
        // Timeout to avoid waiting forever if native registration never completes
        await GoMailer.registerForPushNotifications(
          email: email,
        ).timeout(const Duration(seconds: 30));
      } on TimeoutException catch (_) {
        debugPrint('⚠️ registerForPushNotifications timed out after 30s');
        throw Exception('Push registration timed out. Check device permissions, provisioning and AppDelegate wiring.');
      }

      // Get and log the device token for verification (may still be null)
      final deviceToken = await GoMailer.getDeviceToken();
      debugPrint('📱 Device Token: ${deviceToken ?? "Not available"}');
      if (mounted) {
        setState(() {
          _deviceToken = deviceToken; // may be null initially
        });
      }
      if (deviceToken == null) {
        debugPrint('⚠️ Device token not available after registration');
        // don't throw here — we surface a helpful success message but warn user
      }
      debugPrint('✅ Push notification registration flow completed (native token delivery may be asynchronous)');

      // Setup notification listener
      GoMailer.pushNotificationStream.listen((notification) {
        debugPrint('📬 Received notification: $notification');
        
        // Track the notification click (if user tapped it)
        if (notification['action'] == 'clicked') {
          GoMailer.trackNotificationClick(
            notificationId: notification['id'] ?? '',
            title: notification['title'] ?? '',
            body: notification['body'] ?? '',
            email: _emailController.text,
          );
        }
      });

      // Listen for SDK internal event channel (structured events)
      _eventSub ??= GoMailer.pushNotificationStream.listen((event) {
        setState(() {
          _lastSdkEvent = event;
        });
        debugPrint('🪵 SDK Event: $event');
      });

      debugPrint('✅ All operations completed successfully');
      setState(() {
        _successMessage = 'Successfully registered for notifications! Check your email for a test notification.';
      });
    } catch (e) {
      debugPrint('❌ Error during test: ${e.toString()}');
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 48),
                  // Logo
                  Hero(
                    tag: 'logo',
                    child: Icon(
                      Icons.notifications_active,
                      size: 72,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Test Notifications',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  // Configuration Card
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Current Configuration',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          _buildConfigItem(
                            context,
                            icon: Icons.key,
                            label: 'API Key',
                            value: widget.apiKey,
                          ),
                          const SizedBox(height: 8),
                          _buildConfigItem(
                            context,
                            icon: Icons.cloud,
                            label: 'Environment',
                            value: widget.environment,
                          ),
                          if (_deviceToken != null) ...[
                            const SizedBox(height: 8),
                            _buildConfigItem(
                              context,
                              icon: Icons.phone_iphone,
                              label: 'Device Token',
                              value: _deviceToken!,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Email Input Card
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recipient Details',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              hintText: 'Enter email to test',
                              prefixIcon: Icon(
                                Icons.email,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter an email address';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Hero(
                          tag: 'action_button',
                          child: ElevatedButton(
                            onPressed: _sendTestNotification,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.send),
                                const SizedBox(width: 8),
                                Text(
                                  'Send Test Notification',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.settings,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Change Environment',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                  // Status Messages
                  if (_lastSdkEvent != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Card(
                        elevation: 0,
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.info, color: Theme.of(context).colorScheme.primary),
                                  const SizedBox(width: 8),
                                  Text('Last SDK Event', style: Theme.of(context).textTheme.titleMedium),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _lastSdkEvent.toString(),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Card(
                        color: Theme.of(context).colorScheme.errorContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (_successMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 24, bottom: 24),
                      child: Card(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _successMessage!,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
