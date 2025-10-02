import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'screens/config_screen.dart';
import 'theme.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Guard against duplicate initialization in background isolate
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }
  print('Handling a background message: ${message.messageId}');
}

Future<void> _ensureFirebaseInitialized() async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _ensureFirebaseInitialized();
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
