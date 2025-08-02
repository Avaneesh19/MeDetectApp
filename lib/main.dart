import 'package:flutter/material.dart';
import 'splash_wrapper.dart';

void main() {
  runApp(MyApp());
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
      home: SplashWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}