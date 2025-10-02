import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_mailer_push_sdk/go_mailer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('go_mailer');
  final List<MethodCall> log = <MethodCall>[];

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      log.add(methodCall);
      switch (methodCall.method) {
        case 'initialize':
          return null;
        case 'getDeviceToken':
          return 'test-device-token';
        default:
          return null;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    log.clear();
  });

  test('initialize and get device token', () async {
    await GoMailer.initialize(
      apiKey: 'test-api-key',
      config: GoMailerConfig(
        apiKey: 'test-api-key',
        environment: GoMailerEnvironment.development,
      ),
    );
    expect(await GoMailer.isInitialized, true);

    final token = await GoMailer.getDeviceToken();
    expect(token, 'test-device-token');

    expect(log, [
      isMethodCall('initialize', arguments: {
        'apiKey': 'test-api-key',
        'config': {
          'apiKey': 'test-api-key',
          'baseUrl': 'https://api.gm-g6.xyz/v1',
          'enableAnalytics': true,
          'logLevel': 1,
        },
      }),
      isMethodCall('getDeviceToken', arguments: null),
    ]);
  });
}
