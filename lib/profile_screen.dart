import 'package:flutter/material.dart';
import 'dart:ui';
import 'spline_bg.dart'; // Import the spline background widget
import 'analytics_screen.dart'; // Import your full analytics screen implementation

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
          const CenteredSplineBg(), // Centered spline background with blur
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
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                ),
                const SizedBox(height: 36),
                ListTile(
                  leading: Icon(Icons.history, color: Colors.blue.shade300),
                  title: const Text('Records History',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RecordsHistoryScreen(),
                      ),
                    );
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  tileColor: Colors.white.withOpacity(0.04),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: Icon(Icons.analytics, color: Colors.blue.shade300),
                  title: const Text('Analytics',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AnalyticsScreen(),
                      ),
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
          const CenteredSplineBg(), // Use spline model background here as well
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
