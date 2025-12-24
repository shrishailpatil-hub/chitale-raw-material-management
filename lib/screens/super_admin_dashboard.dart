import 'package:flutter/material.dart';
import 'traceability_screen.dart';
import 'loginpage.dart';
import 'audit_log_screen.dart';
import 'analytics_screen.dart'; // ✅ Import Analytics Screen

class SuperAdminDashboard extends StatelessWidget {
  const SuperAdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light Grey Background
      appBar: AppBar(
        backgroundColor: Colors.black, // Distinctive "Boss Mode" color
        title: const Text('Director Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome",
              style: TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold),
            ),
            const Text(
              "System Overview & Audit",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // ---------------- ANALYTICS BUTTON (PHASE 3 INTEGRATED) ----------------
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen()));
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF1C4175), Color(0xFF2E7CCC)]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Color(0x3F000000), blurRadius: 8, offset: Offset(0, 4))],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Business Intelligence", style: TextStyle(color: Colors.white70)),
                        Text("View Analytics", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Icon(Icons.bar_chart, color: Colors.white, size: 40),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
            const Text("Audit Tools", style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // ---------------- TRACEABILITY BUTTON ----------------
            _adminCard(
              context,
              title: "Traceability Review",
              subtitle: "Track Finished Goods -> Raw Material",
              icon: Icons.history_edu,
              color: Colors.purple,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TraceabilityScreen())),
            ),

            const SizedBox(height: 15),

            // ---------------- OVERRIDE LOGS BUTTON ----------------
            _adminCard(
              context,
              title: "Override Logs",
              subtitle: "View authorized logic bypasses",
              icon: Icons.security,
              color: Colors.orange,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AuditLogScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _adminCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Color(0x1F000000), blurRadius: 5, offset: Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (route) => false);
  }
}