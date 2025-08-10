import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required Null Function(String name, String email) onLoginSuccess});

  @override
  State createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isPasswordVisible = false;
  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(
          'https://my.spline.design/claritystream-EFQ9z7Gq3kkafPoJ18iuBJ2Q/'));
  }

  void _toggleMode() {
    setState(() => _isLogin = !_isLogin);
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final name = _isLogin
          ? _emailController.text.split('@')[0]
          : _nameController.text.trim();
      final email = _emailController.text.trim();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            userName: name,
            userEmail: email,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const accentPurple = Color(0xFFAC3AD0);
    const buttonColor = Color(0xFF971DCB);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: WebViewWidget(controller: _webViewController),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 34),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Image.asset('assets/logoo.png', height: 38),
                      const SizedBox(height: 26),
                      Text(
                        _isLogin ? 'Login' : 'Create Account',
                        style: const TextStyle(
                            fontSize: 32,
                            color: accentPurple,
                            fontWeight: FontWeight.w300),
                      ),
                      const SizedBox(height: 22),
                      if (!_isLogin)
                        _AuthField(
                          controller: _nameController,
                          hintText: 'Full Name',
                          validator: (val) => val == null || val.isEmpty
                              ? 'Please enter your full name'
                              : null,
                        ),
                      const SizedBox(height: 13),
                      _AuthField(
                        controller: _emailController,
                        hintText: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!val.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 13),
                      _AuthField(
                        controller: _passwordController,
                        hintText: 'Password',
                        obscureText: !_isPasswordVisible,
                        suffixIcon: IconButton(
                          onPressed: () => setState(() =>
                              _isPasswordVisible = !_isPasswordVisible),
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (val.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor.withOpacity(0.81),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            _isLogin ? 'Login' : 'Create Account',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 18),
                          ),
                        ),
                      ),
                      if (_isLogin)
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(
                                color: Colors.white70,
                                decoration: TextDecoration.underline),
                          ),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isLogin
                                ? "Don't have an account? "
                                : "Already have an account? ",
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.7)),
                          ),
                          TextButton(
                            onPressed: _toggleMode,
                            child: Text(
                              _isLogin ? "Sign Up" : "Sign In",
                              style: const TextStyle(
                                  decoration: TextDecoration.underline),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  const _AuthField({
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.black.withOpacity(0.1),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
