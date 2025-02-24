import 'package:flutter/material.dart';
//import 'package:soba_app/login.dart';
import 'package:soba_app/checkin/checkin.dart'; //import checkin page

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
        body: CheckInScreen(),
      ),
    );
  }
}
