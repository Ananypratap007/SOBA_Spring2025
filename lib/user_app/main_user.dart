import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:soba_app/config/firebase_config.dart';
import 'package:soba_app/config/firebase_options.dart';
import 'domain/routes_and_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Wait for the initial auth state to be determined
  await Future.delayed(const Duration(milliseconds: 500));

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
