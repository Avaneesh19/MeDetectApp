import 'dart:ui';
import 'package:flutter/material.dart';

// ... (any other imports)

class ProfileScreen extends StatelessWidget {
  final String userName;
  final String userEmail;
  const ProfileScreen({super.key, required this.userName, required this.userEmail});

  String get displayInitials {
    final parts = userName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return (parts[0].isNotEmpty ? parts[0][0] : "") +
          (parts[1].isNotEmpty ? parts[1][0] : "");
    }
    if (parts.isNotEmpty && parts[0].length >= 2) {
      return parts[0][0] + parts[0][1];
    }
    return userName.isNotEmpty ? userName[0] : "?";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Neon BG
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF231942), Color(0xFF2e294e), Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned.fill(child: CustomPaint(painter: PurpleLinesPainter())),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Profile",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.blue.shade800.withOpacity(0.82),
                        child: Text(
                          displayInitials.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 36,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: Text(
                    userName,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                      shadows: [
                        Shadow(
                          offset: const Offset(0, 2),
                          blurRadius: 10,
                          color: Colors.purpleAccent.withOpacity(0.18),
                        )
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    userEmail,
                    style: TextStyle(
                        color: Colors.grey[400], fontSize: 14),
                  ),
                ),
                const SizedBox(height: 36),
                ListTile(
                  leading: Icon(Icons.history, color: Colors.blue.shade300),
                  title: const Text('Records History',
                      style:
                          TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const RecordsHistoryScreen()),
                    );
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  tileColor: Colors.white.withOpacity(0.04),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RecordsHistoryScreen extends StatelessWidget {
  const RecordsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF231942), Color(0xFF2e294e), Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned.fill(child: CustomPaint(painter: PurpleLinesPainter())),
          SafeArea(
            child: Center(
              child: ListTile(
                leading: Icon(Icons.image_outlined, color: Colors.grey[400]),
                title: const Text('No records yet',
                    style: TextStyle(color: Colors.white70)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Purple Neon Lines Painter ----
class PurpleLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.purpleAccent, Colors.deepPurpleAccent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9);

    final path1 = Path()
      ..moveTo(-30, size.height * 0.12)
      ..quadraticBezierTo(size.width * 0.2, 0, size.width * 1.1, size.height * 0.22);

    final path2 = Path()
      ..moveTo(0, size.height * 0.95)
      ..quadraticBezierTo(size.width * 0.6, size.height, size.width, size.height * 0.85);

    final path3 = Path()
      ..moveTo(size.width * 0.12, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.6, size.height * 0.35, size.width * 0.96, size.height * 0.6);

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);

    paint.strokeWidth = 3;
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawPath(path3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
