import 'package:flutter/material.dart';
import '../models/user.dart';
import 'production_entry_screen.dart';
import 'loginpage.dart';

class WorkerDashboard extends StatelessWidget {
  final User user;

  const WorkerDashboard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1C4175),
        title: const Text(
          "PRODUCTION FLOOR",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- PREMIUM FLOATING HEADER ---
            Stack(
              children: [
                Container(
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1C4175),
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
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.blue.shade800,
                          child: const Icon(Icons.engineering, color: Colors.white, size: 30),
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Production Operator",
                              style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              user.name,
                              style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "ID: ${user.username}",
                              style: TextStyle(color: Colors.blueGrey.shade300, fontSize: 12),
                            ),
                          ],
                        ),
                        const Spacer(),
                        _dateBadge(),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Primary Task",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 15),

                  // --- BIG PRODUCTION BUTTON ---
                  SizedBox(
                    width: double.infinity,
                    height: 180,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7CCC),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: 8,
                        shadowColor: const Color(0xFF2E7CCC).withOpacity(0.4),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductionEntryScreen(currentUser: user),
                          ),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.factory_rounded, size: 50, color: Colors.white),
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            "START NEW BATCH",
                            style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w900),
                          ),
                          const Text(
                            "Scan ingredients to begin production",
                            style: TextStyle(fontSize: 14, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- SHIFT SUMMARY (PLACEHOLDER FOR STATS) ---
                  const Text(
                    "Today's Progress",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 15),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _shiftStat("Active", "1", Colors.orange),
                        _shiftStat("Completed", "0", Colors.green),
                        _shiftStat("Target", "12", Colors.blueGrey),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shiftStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _dateBadge() {
    final now = DateTime.now();
    final months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(now.day.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text(months[now.month - 1], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }
}