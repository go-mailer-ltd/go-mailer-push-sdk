import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'screens/config_screen.dart';
import 'theme.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await _safeFirebaseInit();
  print('Handling a background message: ${message.messageId}');
}

Future<void> _safeFirebaseInit() async {
  if (Firebase.apps.isNotEmpty) return; // Already initialized
  try {
    // On Android & iOS the native layer (google-services / plist) usually auto-inits.
    // Calling initializeApp with explicit options can race and cause duplicate-app.
    if (kIsWeb) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    } else if (Platform.isAndroid || Platform.isIOS) {
      // Let native config supply defaults.
      await Firebase.initializeApp();
    } else {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app') {
      // Safe to ignore – another part of the system already initialized Firebase.
      return;
    }
    rethrow;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _safeFirebaseInit();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoMailer Example',
      theme: AppTheme.theme,
      home: const ConfigScreen(),
    );
  }
}
