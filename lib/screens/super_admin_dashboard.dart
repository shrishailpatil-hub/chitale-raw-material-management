import 'package:flutter/material.dart';
import 'traceability_screen.dart';
import 'loginpage.dart';
import 'audit_log_screen.dart';
import 'analytics_screen.dart';
import '../models/user.dart'; // Ensure this model exists

class SuperAdminDashboard extends StatelessWidget {
  final User currentUser; // Accepts the logged-in user object

  const SuperAdminDashboard({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        title: const Text(
          'EXECUTIVE PANEL',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- PREMIUM EXECUTIVE HEADER ---
            Stack(
              children: [
                Container(
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Dynamic Profile Initials Circle
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: const Color(0xFF1C4175),
                          child: Text(
                            currentUser.name.isNotEmpty
                                ? currentUser.name.substring(0, 1).toUpperCase()
                                : "A",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Welcome back,",
                              style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500
                              ),
                            ),
                            Text(
                              currentUser.name,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Icon(Icons.verified, color: Colors.blue, size: 28),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Operational Insights",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 15),

                  // --- BUSINESS INTELLIGENCE CARD ---
                  _buildAnalyticsCard(context),

                  const SizedBox(height: 30),
                  const Text(
                    "Compliance & Audit",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 15),

                  // --- AUDIT TOOLS ---
                  _adminCard(
                    context,
                    title: "Traceability Review",
                    subtitle: "Full genealogy of finished goods",
                    icon: Icons.account_tree_rounded,
                    color: Colors.deepPurple,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TraceabilityScreen())),
                  ),
                  const SizedBox(height: 15),
                  _adminCard(
                    context,
                    title: "Override Audit",
                    subtitle: "Monitor management bypasses",
                    icon: Icons.gavel_rounded,
                    color: Colors.orange.shade800,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuditLogScreen())),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- STYLIZED ANALYTICS CARD ---
  Widget _buildAnalyticsCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen())),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1C4175).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: ListTile(
            leading: Icon(Icons.analytics_rounded, color: Colors.white, size: 40),
            title: Text(
              "Business Intelligence",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Live Inventory & Production Trends",
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            trailing: Icon(Icons.chevron_right, color: Colors.white),
          ),
        ),
      ),
    );
  }

  // --- STANDARD TOOL CARD ---
  Widget _adminCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 10,
                offset: Offset(0, 4)
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      title,
                      style: const TextStyle(
                          fontSize: 17,
                          color: Color(0xFF263238),
                          fontWeight: FontWeight.bold
                      )
                  ),
                  Text(
                      subtitle,
                      style: const TextStyle(color: Colors.grey, fontSize: 12)
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false
    );
  }
}