import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final VoidCallback? onNavigateToAuth;

  const ChatScreen({super.key, this.onNavigateToAuth});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  String _responseText = "I'm here to help you with MeDetect!";

  void _handleSend() {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    final lower = input.toLowerCase();
    if (lower.contains('take me to login') || lower.contains('login')) {
      widget.onNavigateToAuth?.call();
      setState(() {
        _responseText = "Sure! Redirecting you to the login screen...";
      });
    } else {
      setState(() {
        _responseText = "I'm here to help you with MeDetect!";
      });
    }
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatbot'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _responseText,
                  style: TextStyle(fontSize: (screenWidth * 0.045).clamp(14, 18)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Type your message...',
                      ),
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _handleSend,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
