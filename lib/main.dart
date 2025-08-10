import 'package:flutter/material.dart';
import 'landing.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MeDetect',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'System',
      ),
      home: const LandingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
