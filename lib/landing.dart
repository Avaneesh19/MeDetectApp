import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'authscreen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  late final WebViewController _splineWebViewController;

  final Color babyPink = const Color(0xFFFFB6C1);
  final Color purpleColor = Colors.purple.shade500;

  @override
  void initState() {
    super.initState();
    _splineWebViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..enableZoom(false)
      ..loadRequest(Uri.parse(
          'https://my.spline.design/aibrain-jwu6TAdZlFke3PogYM4yDqbd/'));
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final double screenHeight = mq.size.height;
    final double screenWidth = mq.size.width;

    double headerFontSize = screenWidth * 0.12;
    if (headerFontSize < 24) headerFontSize = 24;
    double splineHeight = (screenHeight * 0.4).clamp(200, 400);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(
                height: screenHeight,
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.06,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('We Detect.',
                          style: TextStyle(
                              color: babyPink,
                              fontSize: headerFontSize,
                              fontWeight: FontWeight.w300)),
                      SizedBox(height: headerFontSize * 0.25),
                      Text('We Fix.',
                          style: TextStyle(
                              color: babyPink,
                              fontSize: headerFontSize,
                              fontWeight: FontWeight.w300)),
                      SizedBox(height: headerFontSize * 0.25),
                      Text('We Cure.',
                          style: TextStyle(
                              color: babyPink,
                              fontSize: headerFontSize,
                              fontWeight: FontWeight.w300)),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Center(
                          child: SizedBox(
                            width: screenWidth,
                            height: splineHeight,
                            child: WebViewWidget(
                                controller: _splineWebViewController),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 60),
                child: Column(
                  children: [
                    Text(
                      "MeDetect is an AI-powered platform designed to screen, diagnose, and help treat skin diseases...",
                      style: TextStyle(
                        color: purpleColor,
                        fontSize: (screenWidth * 0.045).clamp(14, 20),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: purpleColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.15,
                          vertical: 18,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (_) => AuthScreen(onLoginSuccess: (String name, String email) {  },)),
                        );
                      },
                      child: Text(
                        "Get Started",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: (screenWidth * 0.05).clamp(16, 20),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
