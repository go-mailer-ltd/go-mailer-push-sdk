import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'go_mailer_method_channel.dart';

abstract class GoMailerPlatform extends PlatformInterface {
  /// Constructs a GoMailerPlatform.
  GoMailerPlatform() : super(token: _token);

  static final Object _token = Object();

  static GoMailerPlatform _instance = MethodChannelGoMailer();

  /// The default instance of [GoMailerPlatform] to use.
  ///
  /// Defaults to [MethodChannelGoMailer].
  static GoMailerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [GoMailerPlatform] when
  /// they register themselves.
  static set instance(GoMailerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> initialize({
    required String apiKey,
    required Map<String, dynamic> config,
  }) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  Future<void> registerForPushNotifications({required String email}) {
    throw UnimplementedError('registerForPushNotifications() has not been implemented.');
  }

  Future<void> setUser(Map<String, dynamic> user) {
    throw UnimplementedError('setUser() has not been implemented.');
  }

  Future<void> trackEvent({
    required String eventName,
    Map<String, dynamic>? properties,
  }) {
    throw UnimplementedError('trackEvent() has not been implemented.');
  }

  Future<String?> getDeviceToken() {
    throw UnimplementedError('getDeviceToken() has not been implemented.');
  }

  Future<void> setUserAttributes(Map<String, dynamic> attributes) {
    throw UnimplementedError('setUserAttributes() has not been implemented.');
  }

  Future<void> addUserTags(List<String> tags) {
    throw UnimplementedError('addUserTags() has not been implemented.');
  }

  Future<void> removeUserTags(List<String> tags) {
    throw UnimplementedError('removeUserTags() has not been implemented.');
  }

  Future<void> setAnalyticsEnabled(bool enabled) {
    throw UnimplementedError('setAnalyticsEnabled() has not been implemented.');
  }

  Future<void> setLogLevel(int level) {
    throw UnimplementedError('setLogLevel() has not been implemented.');
  }
}
