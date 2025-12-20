import 'package:flutter/material.dart';
import '../models/user.dart'; // ✅ Import User Model
import 'production_entry_screen.dart';
import 'loginpage.dart';

class WorkerDashboard extends StatelessWidget {
  final User user; // ✅ Store the Full User Object

  const WorkerDashboard({super.key, required this.user});

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
            // Display Friendly Name
            Text(
              "Hello, ${user.name}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              "ID: ${user.username}", // Show ID for verification
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const SizedBox(height: 50),

            SizedBox(
              width: double.infinity,
              height: 160,
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
                      // ✅ Pass the full User object to the next screen
                      builder: (_) => ProductionEntryScreen(currentUser: user),
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