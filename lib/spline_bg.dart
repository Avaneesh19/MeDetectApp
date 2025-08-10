// spline_bg.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:ui';

class CenteredSplineBg extends StatelessWidget {
  const CenteredSplineBg({super.key, this.blurSigma = 18});
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: SizedBox(
            width: 450,
            height: 450,
            child: ClipOval(
              child: WebViewWidget(
                controller: WebViewController()
                  ..setJavaScriptMode(JavaScriptMode.unrestricted)
                  ..loadRequest(
                    Uri.parse(
                      'https://my.spline.design/particlenebula-Lhnk9Kvv9ioPiRHGvmCTlGEa/',
                    ),
                  ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: Container(color: Colors.transparent),
          ),
        ),
      ],
    );
  }
}
