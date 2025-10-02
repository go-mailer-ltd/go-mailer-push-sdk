import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'No Web configuration provided. Please follow the setup instructions.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDZTlPO59v2M1lsh9MQ5GS_3xnrTS9Deq0',
    appId: '1:37848884203:android:99aa215ac2871e91316fae',
    messagingSenderId: '37848884203',
    projectId: 'gm-flutter-test',
    storageBucket: 'gm-flutter-test.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDZTlPO59v2M1lsh9MQ5GS_3xnrTS9Deq0',
    appId: '1:37848884203:ios:99aa215ac2871e91316fae',
    messagingSenderId: '37848884203',
    projectId: 'gm-flutter-test',
    storageBucket: 'gm-flutter-test.firebasestorage.app',
  );
}
