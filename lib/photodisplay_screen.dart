import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;
import './skin_disease_classifier.dart';

class PhotoDisplayScreen extends StatefulWidget {
  final String diagnosisType;
  const PhotoDisplayScreen({super.key, required this.diagnosisType});

  @override
  State<PhotoDisplayScreen> createState() => _PhotoDisplayScreenState();
}

class _PhotoDisplayScreenState extends State<PhotoDisplayScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _imageController;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Animation<double> _imageScale;
  late final Animation<double> _imageOpacity;

  final _picker = ImagePicker();
  final _classifier = SkinDiseaseClassifier();

  File? _selectedImage;
  bool _loading = false;
  bool _analyzing = false;
  Map<String, dynamic>? _analysisResult;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _imageController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, -3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart));
    _imageScale = Tween<double>(begin: 0.8, end: 1.0)
        .animate(CurvedAnimation(parent: _imageController, curve: Curves.elasticOut));
    _imageOpacity = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _imageController, curve: Curves.easeInOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _imageController.dispose();
    super.dispose();
  }

  /// Compress image before upload: max 1000px width, JPEG 80%
  Future<File> compressImage(File file) async {
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) return file; // fallback: original file
    final resized = img.copyResize(image, width: 1000);
    final jpg = img.encodeJpg(resized, quality: 80);
    final outPath = file.path.replaceFirst('.', '_compressed.');
    return await File(outPath).writeAsBytes(jpg);
  }

  Future<void> _pickImage() async {
    setState(() => _loading = true);

    final cameraStatus = await Permission.camera.request();
    if (cameraStatus.isGranted) {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _analysisResult = null;
        });
        _imageController.forward();
        await _analyzeImage();
      }
    } else if (cameraStatus.isDenied) {
      _showPermissionDialog('Camera permission is required to take photos.');
    } else if (cameraStatus.isPermanentlyDenied) {
      _showPermissionDialog(
        'Camera permission is permanently denied. Please enable it in app settings.',
        showSettings: true,
      );
    }
    setState(() => _loading = false);
  }

  Future<void> _pickImageFromGallery() async {
    setState(() => _loading = true);

    if (Platform.isAndroid) {
      final storageStatus = await Permission.storage.request();
      if (storageStatus.isDenied) {
        _showPermissionDialog('Storage permission is required to access photos.');
        setState(() => _loading = false);
        return;
      } else if (storageStatus.isPermanentlyDenied) {
        _showPermissionDialog(
          'Storage permission is permanently denied. Please enable it in app settings.',
          showSettings: true,
        );
        setState(() => _loading = false);
        return;
      }
    }

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _analysisResult = null;
      });
      _imageController.forward();
      await _analyzeImage();
    }
    setState(() => _loading = false);
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    setState(() => _analyzing = true);

    try {
      final compressed = await compressImage(_selectedImage!);
      final result = await _classifier.classifyImage(compressed);
      setState(() {
        _analysisResult = result;
      });
    } catch (e) {
      setState(() {
        _analysisResult = {
          'success': false,
          'error': 'Analysis failed: $e',
        };
      });
    }

    setState(() => _analyzing = false);
  }

  void _showPermissionDialog(String message, {bool showSettings = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Permission Required',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
          content: Text(message,
              style: TextStyle(color: Colors.grey[300], fontSize: 16, height: 1.4)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(foregroundColor: Colors.grey[400]),
              child: const Text('Cancel'),
            ),
            if (showSettings)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.blue.shade400, Colors.purple.shade400]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    openAppSettings();
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  child: const Text('Settings'),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildAnalysisResults() {
    if (_analysisResult == null) return const SizedBox.shrink();

    if (!_analysisResult!['success']) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.shade900.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade400.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400, size: 32),
            const SizedBox(height: 12),
            Text(
              'Analysis Failed',
              style: TextStyle(color: Colors.red.shade400, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              _analysisResult!['error'] ?? 'Unknown error occurred',
              style: TextStyle(color: Colors.grey[300], fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final predictions = _analysisResult!['predictions'] as List<dynamic>;
    final topPrediction = _analysisResult!['topPrediction'] as Map<String, dynamic>;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header, main/alternative result UI...
          // ... (same as in previous answer; for brevity, not repeating markup blocks. Implement as per your existing display logic.)
        ],
      ),
    );
  }

  // ... _buildImagePreview() and _buildActionButton() remain the same as previously provided ...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.3, -0.8),
            radius: 1.2,
            colors: [
              Colors.blue.shade900.withOpacity(0.1),
              Colors.purple.shade900.withOpacity(0.05),
              Colors.black,
            ],
          ),
        ),
        child: const SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header and content
              // ... (all as previously provided)
            ],
          ),
        ),
      ),
    );
  }
}
