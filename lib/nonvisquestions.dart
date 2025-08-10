import 'package:flutter/material.dart';
import 'dart:ui';
import 'spline_bg.dart';
import 'package:url_launcher/url_launcher.dart';

class NonVisQuestionsScreen extends StatefulWidget {
  const NonVisQuestionsScreen({super.key});

  @override
  State<NonVisQuestionsScreen> createState() => _NonVisQuestionsScreenState();
}

class _NonVisQuestionsScreenState extends State<NonVisQuestionsScreen> {
  String _condition = "";
  bool _showQuestions = false;
  String? _selectedQ1;
  String? _selectedQ2;
  String? _selectedQ3;
  bool _showResult = false;
  String _diagnosis = "";
  String _confidence = "";

  /// Launch default SMS app
  Future<void> _launchSMS() async {
    // Give a default number or leave blank, but some devices require a number
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: '', // could be '1234567890' if you want a default number
      // queryParameters: {'body': 'Hello from Offline Mode!'} // optional body
    );

    if (await canLaunchUrl(smsUri)) {
      // Ensure it opens in external application mode
      await launchUrl(smsUri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open SMS app')),
        );
      }
    }
  }

  void _generateQuestions() {
    if (_condition.toLowerCase().contains("headache")) {
      setState(() {
        _showQuestions = true;
        _showResult = false;
      });
    } else {
      setState(() {
        _showQuestions = false;
        _showResult = true;
        _diagnosis = "Condition not supported yet";
        _confidence = "-";
      });
    }
  }

  void _calculateResult() {
    setState(() {
      _showResult = true;
      _diagnosis = "Possible Migraine";
      _confidence = "70%";
    });
  }

  Widget _buildBox({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5), // semi-transparent background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300.withOpacity(0.5)),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _launchSMS,
            child: const Text(
              'Try Offline Mode',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          const CenteredSplineBg(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  /// Box 1: Condition Entry
                  _buildBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Enter Condition:",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          decoration: const InputDecoration(
                            hintText: "e.g. Headache",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (val) => _condition = val,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _generateQuestions,
                          child: const Text("Generate Questions"),
                        ),
                      ],
                    ),
                  ),

                  /// Box 2: Generated Questions (only if needed)
                  if (_showQuestions)
                    _buildBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Questions:",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text("1. How long have you had the headache?"),
                          ...["Less than 1 day", "1-3 days", "More than 3 days"].map(
                            (opt) => RadioListTile<String>(
                              title: Text(opt),
                              value: opt,
                              groupValue: _selectedQ1,
                              onChanged: (val) => setState(() => _selectedQ1 = val),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text("2. Location of headache?"),
                          ...["Front", "Side", "Back of head"].map(
                            (opt) => RadioListTile<String>(
                              title: Text(opt),
                              value: opt,
                              groupValue: _selectedQ2,
                              onChanged: (val) => setState(() => _selectedQ2 = val),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text("3. Severity level?"),
                          ...["Mild", "Moderate", "Severe"].map(
                            (opt) => RadioListTile<String>(
                              title: Text(opt),
                              value: opt,
                              groupValue: _selectedQ3,
                              onChanged: (val) => setState(() => _selectedQ3 = val),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _calculateResult,
                            child: const Text("Get Diagnosis"),
                          ),
                        ],
                      ),
                    ),

                  /// Box 3: Diagnosis Result
                  if (_showResult)
                    _buildBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Diagnosis Result",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text("Condition: $_diagnosis"),
                          Text("Confidence Level: $_confidence"),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
