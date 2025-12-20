import 'package:flutter/material.dart';
import 'production_entry_screen.dart';
import 'loginpage.dart';

class WorkerDashboard extends StatelessWidget {
  final String workerName;
  const WorkerDashboard({super.key, required this.workerName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Production Floor"),
        backgroundColor: const Color(0xFF1C4175),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // WELCOME TEXT
            Text(
              "Hello, $workerName",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Select an action to begin",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 50),

            // BIG ACTION BUTTON
            SizedBox(
              width: double.infinity,
              height: 160, // Massive button for easy clicking
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7CCC),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 5,
                ),
                icon: const Icon(Icons.factory, size: 60),
                label: const Text(
                  "NEW PRODUCTION BATCH",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // Pass worker name so we can log it!
                      builder: (_) => ProductionEntryScreen(workerName: workerName),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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