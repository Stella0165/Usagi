import 'package:flutter/material.dart';
import 'pages/landing_screen.dart';

void main() {
  runApp(const LumiApp());
}

class LumiApp extends StatelessWidget {
  const LumiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lumi',
      home: const LandingScreen(),
    );
  }
}