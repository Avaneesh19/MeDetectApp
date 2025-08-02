import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'authscreen.dart';
import 'home_screen.dart';

class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});
  
  @override
  _SplashWrapperState createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  bool _showSplash = true;
  bool _showAuth = false;
  String? _userName;
  String? _userEmail;

  void _navigateToAuth() {
    if (mounted) {
      setState(() {
        _showSplash = false;
        _showAuth = true;
      });
    }
  }

  void _navigateToHome(String name, String email) {
    // Fallback to part before '@' in email if name is empty
    final fallbackName = (name.isEmpty && email.contains('@'))
        ? email.split('@')[0]
        : name;

    if (mounted) {
      setState(() {
        _showSplash = false;
        _showAuth = false;
        _userName = fallbackName.isNotEmpty ? fallbackName : "User";
        _userEmail = email;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return VideoSplashScreen(onVideoComplete: _navigateToAuth);
    } else if (_showAuth) {
      // AuthScreen should call onLoginSuccess(name, email)
      return AuthScreen(onLoginSuccess: _navigateToHome);
    } else {
      return HomeScreen(
        userName: _userName ?? 'User',
        userEmail: _userEmail ?? '',
      );
    }
  }
}