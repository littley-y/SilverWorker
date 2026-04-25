import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logger/logger.dart';

final _logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO(spec_02): Remove try/catch once Firebase Console is connected
  // and firebase_options.dart is generated via `flutterfire configure`.
  try {
    await Firebase.initializeApp();
  } catch (e) {
    _logger.w('Firebase.initializeApp() failed (placeholder mode): $e');
  }
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SilverWorkerNow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            'SilverWorkerNow',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
