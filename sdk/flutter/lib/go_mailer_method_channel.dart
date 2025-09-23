import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'go_mailer_platform_interface.dart';

/// An implementation of [GoMailerPlatform] that uses method channels.
class MethodChannelGoMailer extends GoMailerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('go_mailer');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<void> initialize({
    required String apiKey,
    required Map<String, dynamic> config,
  }) async {
    await methodChannel.invokeMethod('initialize', {
      'apiKey': apiKey,
      'config': config,
    });
  }

  @override
  Future<void> registerForPushNotifications({required String email}) async {
    await methodChannel.invokeMethod('registerForPushNotifications', {
      'email': email,
    });
  }

  @override
  Future<void> setUser(Map<String, dynamic> user) async {
    await methodChannel.invokeMethod('setUser', user);
  }

  @override
  Future<void> trackEvent({
    required String eventName,
    Map<String, dynamic>? properties,
  }) async {
    await methodChannel.invokeMethod('trackEvent', {
      'eventName': eventName,
      'properties': properties,
    });
  }

  @override
  Future<String?> getDeviceToken() async {
    final result = await methodChannel.invokeMethod<String>('getDeviceToken');
    return result;
  }

  @override
  Future<void> setUserAttributes(Map<String, dynamic> attributes) async {
    await methodChannel.invokeMethod('setUserAttributes', {
      'attributes': attributes,
    });
  }

  @override
  Future<void> addUserTags(List<String> tags) async {
    await methodChannel.invokeMethod('addUserTags', {
      'tags': tags,
    });
  }

  @override
  Future<void> removeUserTags(List<String> tags) async {
    await methodChannel.invokeMethod('removeUserTags', {
      'tags': tags,
    });
  }

  @override
  Future<void> setAnalyticsEnabled(bool enabled) async {
    await methodChannel.invokeMethod('setAnalyticsEnabled', {
      'enabled': enabled,
    });
  }

  @override
  Future<void> setLogLevel(int level) async {
    await methodChannel.invokeMethod('setLogLevel', {
      'level': level,
    });
  }
}
