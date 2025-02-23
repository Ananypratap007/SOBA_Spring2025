import 'package:flutter/material.dart';
import 'package:soba_app/navigation.dart';
import 'package:soba_app/button.dart';

void main() {
  runApp(MainApp());
}

const double dfInsets = 20; // Default insets for padding & margin
const double dfRadius = 20; // Default border radius
const Color yellow = Color(0xFFFFDD85), coral = Color(0xFFFF6F61); // Theme colors
const LinearGradient gradientOrange = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [
    yellow,
    coral,
  ],
); // Theme gradient

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: coral,
        // body: ButtonPage(),
        body: MapPage(),
      ),
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: coral, primary: coral, secondary: yellow, dynamicSchemeVariant: DynamicSchemeVariant.fidelity),
        ),
    );
  }
}
