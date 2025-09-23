import 'package:flutter_test/flutter_test.dart';
import 'package:go_mailer_push_sdk/go_mailer.dart';
import 'package:go_mailer_push_sdk/go_mailer_platform_interface.dart';
import 'package:go_mailer_push_sdk/go_mailer_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockGoMailerPlatform
    with MockPlatformInterfaceMixin
    implements GoMailerPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final GoMailerPlatform initialPlatform = GoMailerPlatform.instance;

  test('$MethodChannelGoMailer is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelGoMailer>());
  });

  test('getPlatformVersion', () async {
    GoMailer goMailerPlugin = GoMailer();
    MockGoMailerPlatform fakePlatform = MockGoMailerPlatform();
    GoMailerPlatform.instance = fakePlatform;

    expect(await goMailerPlugin.getPlatformVersion(), '42');
  });
}
