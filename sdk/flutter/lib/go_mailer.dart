import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Main Go Mailer SDK class for Flutter
///
/// This SDK provides cross-platform push notification functionality
/// and customer engagement messaging for Flutter applications.
class GoMailer {
  static const MethodChannel _channel = MethodChannel('go_mailer');
  static const EventChannel _eventChannel = EventChannel('go_mailer_events');

  static GoMailer? _instance;
  static bool _isInitialized = false;
  static GoMailerLogLevel _logLevel = GoMailerLogLevel.info;

  GoMailer._();

  /// Get the current version of the SDK
  static const String version = '1.0.0';

  /// Get whether the SDK is initialized
  static bool get isInitialized => _isInitialized;

  /// Initialize the Go Mailer SDK
  ///
  /// [apiKey] Your Go Mailer API key (required)
  /// [config] Optional configuration parameters
  ///
  /// Throws [GoMailerException] if initialization fails
  static Future<void> initialize({
    required String apiKey,
    GoMailerConfig? config,
  }) async {
    if (_isInitialized) {
      _log('SDK already initialized', GoMailerLogLevel.debug);
      return;
    }

    if (apiKey.isEmpty) {
      throw GoMailerException('API key cannot be empty');
    }

    try {
      final finalConfig = config ?? GoMailerConfig();
      finalConfig.apiKey = apiKey;
      _logLevel = finalConfig.logLevel;

      _instance = GoMailer._();

      // Initialize platform-specific code
      await _channel.invokeMethod('initialize', {
        'apiKey': apiKey,
        'config': finalConfig.toMap(),
      });

      _isInitialized = true;
      _log('SDK initialized successfully with version $version',
          GoMailerLogLevel.info);
    } catch (e) {
      _isInitialized = false;
      _instance = null;
      _log('Failed to initialize SDK: $e', GoMailerLogLevel.error);
      throw GoMailerException('Failed to initialize Go Mailer SDK: $e');
    }
  }

  /// Get the shared instance of Go Mailer
  static GoMailer? get instance => _instance;

  /// Register for push notifications
  ///
  /// [email] User's email address that will be sent to the backend along with the device token
  /// This ensures the backend can associate the device token with the correct user
  static Future<void> registerForPushNotifications(
      {required String email}) async {
    _checkInitialization();
    debugPrint(
        'Go Mailer: Registering for push notifications for user: $email');
    await _channel
        .invokeMethod('registerForPushNotifications', {'email': email});
  }

  /// Set the current user
  ///
  /// [user] User information
  static Future<void> setUser(GoMailerUser user) async {
    _checkInitialization();
    await _channel.invokeMethod('setUser', user.toMap());
  }

  /// Track an analytics event
  ///
  /// [eventName] Name of the event
  /// [properties] Event properties
  ///
  /// Throws [GoMailerException] if SDK is not initialized or event name is empty
  static Future<void> trackEvent({
    required String eventName,
    Map<String, dynamic>? properties,
  }) async {
    _checkInitialization();

    if (eventName.isEmpty) {
      throw GoMailerException('Event name cannot be empty');
    }

    try {
      await _channel.invokeMethod('trackEvent', {
        'eventName': eventName,
        'properties': properties ?? {},
      });
      _log('Event tracked: $eventName', GoMailerLogLevel.debug);
    } catch (e) {
      _log('Failed to track event $eventName: $e', GoMailerLogLevel.error);
      throw GoMailerException('Failed to track event: $e');
    }
  }

  /// Track notification click event
  ///
  /// This method should be called when the app is opened from a notification
  /// [notificationId] The notification ID (from server or auto-generated)
  /// [title] The notification title
  /// [body] The notification body
  /// [email] The user's email address
  static Future<void> trackNotificationClick({
    required String notificationId,
    required String title,
    required String body,
    String? email,
  }) async {
    _checkInitialization();

    try {
      await _channel.invokeMethod('trackNotificationClick', {
        'notificationId': notificationId,
        'title': title,
        'body': body,
        'email': email,
      });
      _log('Notification click tracked: $notificationId',
          GoMailerLogLevel.debug);
    } catch (e) {
      _log('Failed to track notification click: $e', GoMailerLogLevel.error);
      throw GoMailerException('Failed to track notification click: $e');
    }
  }

  /// Get the current device token
  static Future<String?> getDeviceToken() async {
    _checkInitialization();

    try {
      final result = await _channel.invokeMethod<String>('getDeviceToken');
      debugPrint('Go Mailer: Device token result: $result');
      return result;
    } catch (e) {
      debugPrint('Go Mailer: Failed to get device token: $e');
      return null;
    }
  }

  /// Listen to push notification events
  ///
  /// Returns a [Stream] of push notification events
  static Stream<Map<String, dynamic>> get pushNotificationStream {
    return _eventChannel.receiveBroadcastStream().map((event) {
      return Map<String, dynamic>.from(event);
    });
  }

  /// Check if SDK is initialized
  static void _checkInitialization() {
    if (!_isInitialized) {
      throw GoMailerException('SDK not initialized. Call initialize() first.');
    }
  }

  /// Internal logging method
  static void _log(String message, GoMailerLogLevel level) {
    if (level.index >= _logLevel.index) {
      final prefix = level == GoMailerLogLevel.error
          ? '❌'
          : level == GoMailerLogLevel.warn
              ? '⚠️'
              : level == GoMailerLogLevel.debug
                  ? '🔍'
                  : '📱';

      if (kDebugMode || level == GoMailerLogLevel.error) {
        debugPrint('Go Mailer $prefix: $message');
      }
    }
  }
}

/// Configuration for Go Mailer SDK
class GoMailerConfig {
  String apiKey;
  String baseUrl;
  bool enableAnalytics;
  GoMailerLogLevel logLevel;

  GoMailerConfig({
    this.apiKey = '',
    this.baseUrl = 'https://api.go-mailer.com/v1', // Production endpoint
    this.enableAnalytics = true,
    this.logLevel = GoMailerLogLevel.info,
  });

  Map<String, dynamic> toMap() {
    return {
      'apiKey': apiKey,
      'baseUrl': baseUrl,
      'enableAnalytics': enableAnalytics,
      'logLevel': logLevel.index,
    };
  }

  factory GoMailerConfig.fromMap(Map<String, dynamic> map) {
    return GoMailerConfig(
      apiKey: map['apiKey'] ?? '',
      baseUrl: map['baseUrl'] ?? 'https://419c321798d9.ngrok-free.app',
      enableAnalytics: map['enableAnalytics'] ?? true,
      logLevel: GoMailerLogLevel.values[map['logLevel'] ?? 1],
    );
  }
}

/// User information for Go Mailer
class GoMailerUser {
  final String email;
  final String? phone;
  final String? firstName;
  final String? lastName;
  final Map<String, dynamic>? customAttributes;
  final List<String>? tags;

  GoMailerUser({
    required this.email,
    this.phone,
    this.firstName,
    this.lastName,
    this.customAttributes,
    this.tags,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'phone': phone,
      'firstName': firstName,
      'lastName': lastName,
      'customAttributes': customAttributes,
      'tags': tags,
    };
  }

  factory GoMailerUser.fromMap(Map<String, dynamic> map) {
    return GoMailerUser(
      email: map['email'] ?? '',
      phone: map['phone'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      customAttributes: map['customAttributes'] != null
          ? Map<String, dynamic>.from(map['customAttributes'])
          : null,
      tags: map['tags'] != null ? List<String>.from(map['tags']) : null,
    );
  }
}

/// Log levels for Go Mailer SDK
enum GoMailerLogLevel {
  debug,
  info,
  warn,
  error,
}

/// Custom exception class for Go Mailer SDK errors
class GoMailerException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const GoMailerException(this.message, {this.code, this.originalError});

  @override
  String toString() {
    return 'GoMailerException: $message${code != null ? ' (Code: $code)' : ''}';
  }
}

/// Errors that can occur in Go Mailer SDK
enum GoMailerError {
  notInitialized(1001, 'Go Mailer SDK not initialized'),
  invalidApiKey(1002, 'Invalid API key'),
  networkError(1003, 'Network error occurred'),
  invalidUser(1004, 'Invalid user information'),
  pushNotificationNotAuthorized(1006, 'Push notifications not authorized'),
  deviceTokenNotAvailable(1007, 'Device token not available');

  final int code;
  final String message;

  const GoMailerError(this.code, this.message);
}
