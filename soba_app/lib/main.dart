import 'package:flutter/material.dart';
import 'package:soba_app/login.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.orange,
        body: LoginPage(),
      ),
    );
  }
}
