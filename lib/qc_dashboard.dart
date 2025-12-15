import 'package:flutter/material.dart';
import 'pending_qc_screen.dart';
import 'qc_scan_batch_screen.dart';


class QCDashboard extends StatelessWidget {
  const QCDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C4175),
        title: const Text(
          'QC Dashboard',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ---------------- WELCOME ----------------
            const Text(
              "Welcome,\nAditi Kadam",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 20),

            // ---------------- QUICK STATS ----------------
            const Text(
              "Quick Stats",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                _statCard("7", "Approved QC", const Color(0xFF39B54A)),
                const SizedBox(width: 12),
                _statCard("5", "On Hold QC", const Color(0xFFFFC107)),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                _statCard("1", "Rejected QC", const Color(0xFFFF5023)),
                const SizedBox(width: 12),
                _statCard("3", "Pending QC", const Color(0xFFF55F51)),
              ],
            ),

            const SizedBox(height: 30),

            // ---------------- ACTION MENU ----------------
            const Text(
              "Action Menu",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [

                _actionCard(
                  icon: Icons.qr_code_scanner,
                  label: "Scan Batch",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_)=>const QCScanBatchScreen()),
                    );
                  },
                ),

                _actionCard(
                  icon: Icons.pending_actions,
                  label: "Pending QC",
                  onTap: () {
                    Navigator.push(

                        context,
                        MaterialPageRoute(builder: (_) => const PendingQCScreen()),
                    );
                  },
                ),

                _actionCard(
                  icon: Icons.history,
                  label: "QC History",
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("QC History - Coming Soon")),
                    );
                  },
                ),

                _actionCard(
                  icon: Icons.logout,
                  label: "Logout",
                  onTap: () async {
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text("Logout"),
                        content: const Text("Are you sure you want to logout?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext, false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext, true),
                            child: const Text(
                              "Logout",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (shouldLogout == true) {
                      Navigator.pop(context);
                    }
                  },
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- STAT CARD ----------------
  static Widget _statCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- ACTION CARD ----------------
  static Widget _actionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 6,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: const Color(0xFF1C4175)),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
