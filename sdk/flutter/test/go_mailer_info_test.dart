import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_mailer_push_sdk/go_mailer.dart';

void main() {
  const channel = MethodChannel('go_mailer');
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GoMailer SDK info', () {
    final log = <MethodCall>[];

    late TestDefaultBinaryMessenger bindingMessenger;

    setUp(() {
      log.clear();
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      bindingMessenger = binding.defaultBinaryMessenger;
      bindingMessenger.setMockMethodCallHandler(channel, (call) async {
        log.add(call);
        switch (call.method) {
          case 'initialize':
            return null;
          case 'getSdkInfo':
            return {
              'version': GoMailer.version,
              'baseUrl': 'https://api.go-mailer.com/v1',
              'email': 'test@example.com',
              'deviceToken': 'abc'
            };
        }
        return null;
      });
    });

    tearDown(() {
      bindingMessenger.setMockMethodCallHandler(channel, null);
    });

    test('version constant matches getSdkInfo result', () async {
      await GoMailer.initialize(apiKey: 'dummy');
      final info = await GoMailer.getSdkInfo();
      expect(info['version'], GoMailer.version);
    });
  });
}
