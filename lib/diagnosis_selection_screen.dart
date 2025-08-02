import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'skin_disease_classifier.dart';

class DiagnosisSelectionScreen extends StatefulWidget {
  const DiagnosisSelectionScreen({super.key});

  @override
  State<DiagnosisSelectionScreen> createState() => _DiagnosisSelectionScreenState();
}

class _DiagnosisSelectionScreenState extends State<DiagnosisSelectionScreen> {
  final classifier = SkinDiseaseClassifier();

  bool isLoading = false;
  String? errorText;
  Map<String, dynamic>? result;
  File? _capturedImage;

  Future<void> _startVisibleDiagnosis() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Camera permission is required")),
      );
      return;
    }
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 95);
    if (pickedFile == null) return;
    setState(() {
      isLoading = true;
      errorText = null;
      result = null;
      _capturedImage = File(pickedFile.path);
    });
    final apiResult = await classifier.classifyImage(_capturedImage!);
    setState(() {
      isLoading = false;
      if (apiResult['success'] == true) {
        result = apiResult;
      } else {
        errorText = apiResult['error'] ?? 'Unknown error';
      }
    });
  }

  Future<void> _startNonVisibleDiagnosis() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Non-visible diagnosis not implemented in this demo.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.3, -0.8),
                radius: 1.2,
                colors: [
                  Color(0xFF182757),
                  Color(0xFF231942),
                  Colors.black,
                ],
              ),
            ),
          ),
          Positioned.fill(child: CustomPaint(painter: PurpleLinesPainter())),
          SafeArea(
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    margin: const EdgeInsets.all(22),
                    padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 26),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.42),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: Colors.blueAccent.withOpacity(0.17),
                        width: 1.1,
                      ),
                    ),
                    child: _buildContent(context),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isLoading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          SizedBox(height: 48),
          CircularProgressIndicator(color: Colors.blueAccent),
          SizedBox(height: 18),
          Text(
            "Analyzing skin condition...",
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
        ],
      );
    }

    if (result != null) {
      final top = result!['topPrediction'];
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Diagnosis Result",
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24, color: Colors.white),
          ),
          if (_capturedImage != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              child: Image.file(_capturedImage!, width: 120, height: 120),
            ),
          const SizedBox(height: 8),
          Text(
            "${top['label'] ?? 'Unknown'}",
            style: const TextStyle(
              color: Colors.lightGreenAccent,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Confidence: ${((top['confidence'] ?? 0.0) * 100).toStringAsFixed(1)}%",
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            "${top['recommendation'] ?? ''}",
            style: const TextStyle(color: Colors.orangeAccent, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () => setState(() {
              result = null;
              _capturedImage = null;
            }),
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text(
              "Try Again",
              style: TextStyle(color: Colors.white),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white54),
            ),
          ),
        ],
      );
    }

    if (errorText != null) {
      return Column(
        children: [
          const SizedBox(height: 30),
          Text(
            errorText!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 16),
          ),
          OutlinedButton.icon(
            onPressed: () => setState(() {
              errorText = null;
              _capturedImage = null;
            }),
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text("Try Again", style: TextStyle(color: Colors.white)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white54),
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Start Diagnosis",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 28,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _GlassDiagnosisOption(
              label: "Visible",
              icon: Icons.visibility,
              onTap: _startVisibleDiagnosis,
              gradient: const LinearGradient(
                colors: [Color(0xff1471fc), Color(0xff32e9f9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            _GlassDiagnosisOption(
              label: "Non-Visible",
              icon: Icons.visibility_off,
              onTap: _startNonVisibleDiagnosis,
              gradient: const LinearGradient(
                colors: [Color(0xffbe3af6), Color(0xff7a2ff7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          "Choose whether your symptoms are visible or non-visible.",
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _GlassDiagnosisOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final LinearGradient gradient;
  const _GlassDiagnosisOption({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 140,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(23),
          border: Border.all(color: Colors.white.withOpacity(0.18)),
          boxShadow: [
            BoxShadow(
              color: Colors.purpleAccent.withOpacity(0.13),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(14),
              child: Icon(icon, color: Colors.white, size: 37),
            ),
            const SizedBox(height: 22),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 17,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PurpleLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.purpleAccent, Colors.deepPurpleAccent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    final path1 = Path()
      ..moveTo(-30, size.height * 0.15)
      ..quadraticBezierTo(size.width * 0.2, 0, size.width * 1.1, size.height * 0.19);
    final path2 = Path()
      ..moveTo(0, size.height * 0.91)
      ..quadraticBezierTo(size.width * 0.62, size.height, size.width, size.height * 0.81);
    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
    paint.strokeWidth = 2;
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    final path3 = Path()
      ..moveTo(size.width * 0.13, size.height * 0.46)
      ..quadraticBezierTo(size.width * 0.53, size.height * 0.31, size.width * 0.92, size.height * 0.6);
    canvas.drawPath(path3, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
