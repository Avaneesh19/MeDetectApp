import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class SkinDiseaseClassifier {
  static const String API_URL = 'https://serverless.roboflow.com/skin-disease-detection-phsnp/2';
  static const String API_KEY = 'rf_RP9otLrOKwgp50zI9XiM06vrkLH2';

  Future<Map<String, dynamic>> classifyImage(File imageFile) async {
    try {
      final url = Uri.parse('$API_URL?api_key=$API_KEY');
      final request = http.MultipartRequest('POST', url);
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          filename: basename(imageFile.path),
        ),
      );
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseBody);
        return _processRoboflowResponse(jsonResponse);
      } else {
        print('API Error ${response.statusCode}: $responseBody');
        return {
          'success': false,
          'error': 'API request failed: ${response.statusCode}\n$responseBody',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  Map<String, dynamic> _processRoboflowResponse(Map<String, dynamic> response) {
    try {
      final predictions = response['predictions'] as List? ?? [];
      if (predictions.isEmpty) {
        return {
          'success': false,
          'error': 'No predictions returned',
        };
      }
      predictions.sort((a, b) => (b['confidence'] ?? 0.0).compareTo(a['confidence'] ?? 0.0));
      final results = predictions.map((pred) => {
        'label': pred['class'] ?? pred['label'] ?? 'Unknown',
        'confidence': (pred['confidence'] ?? 0.0).toDouble(),
        'severity': _getSeverityLevel((pred['confidence'] ?? 0.0).toDouble()),
        'recommendation': _getRecommendation(
          pred['class'] ?? pred['label'] ?? 'Unknown', 
          (pred['confidence'] ?? 0.0).toDouble()
        ),
      }).toList();
      return {
        'success': true,
        'predictions': results.take(3).toList(),
        'topPrediction': results.first,
        'processingTime': '${response['inference_time'] ?? 'N/A'}ms',
        'imageAnalyzed': true,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to process API response: $e',
      };
    }
  }

  String _getSeverityLevel(double confidence) {
    if (confidence > 0.8) return 'High Confidence';
    if (confidence > 0.6) return 'Moderate Confidence';
    if (confidence > 0.4) return 'Low Confidence';
    return 'Very Low Confidence';
  }

  String _getRecommendation(String condition, double confidence) {
    if (confidence > 0.7) {
      return 'Strong indication of $condition. Consult a dermatologist immediately.';
    } else if (confidence > 0.5) {
      return 'Possible $condition detected. Schedule a dermatological consultation.';
    } else {
      return 'Uncertain diagnosis. Monitoring advised or seek professional advice.';
    }
  }
}
