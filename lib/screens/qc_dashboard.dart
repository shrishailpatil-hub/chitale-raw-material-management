import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/batch.dart';
import '../models/qc_record.dart';
import '../services/qc_service.dart';
import 'qc_scan_batch_screen.dart';
import 'qc_history_screen.dart';
import 'pending_qc_screen.dart';
import 'loginpage.dart';

class QCDashboard extends StatefulWidget {
  final User currentUser;
  const QCDashboard({super.key, required this.currentUser});

  @override
  State<QCDashboard> createState() => _QCDashboardState();
}

class _QCDashboardState extends State<QCDashboard> {
  @override
  void initState() {
    super.initState();
    // Refresh data on load
    QCService().refreshPendingList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1C4175),
        title: const Text('Quality Control', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
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
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.orange.shade700,
                          child: Text(
                            widget.currentUser.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("QC Inspector", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                            Text(
                              widget.currentUser.name,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Icon(Icons.verified_user, color: Colors.green, size: 28),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------------- 📊 STATS CARDS (THE NUMBERS) ----------------
                  const Text("Quick Stats", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  ValueListenableBuilder<List<QCRecord>>(
                    valueListenable: QCService().qcHistoryNotifier,
                    builder: (context, allHistory, child) {
                      // Logic: Only count the LATEST status for each batch for the tiles
                      Map<String, QCStatus> latestStatusMap = {};
                      for (var record in allHistory) {
                        latestStatusMap[record.batch.batchNo] = record.status;
                      }

                      final int approvedCount = latestStatusMap.values.where((s) => s == QCStatus.approved).length;
                      final int rejectedCount = latestStatusMap.values.where((s) => s == QCStatus.rejected).length;
                      final int onHoldCount = latestStatusMap.values.where((s) => s == QCStatus.onHold).length;

                      return ValueListenableBuilder<List<Batch>>(
                        valueListenable: QCService().pendingBatchesNotifier,
                        builder: (context, pending, child) {
                          final int pendingCount = pending.length;
                          return Column(
                            children: [
                              Row(
                                children: [
                                  _statCard(approvedCount.toString(), "Approved", const Color(0xFF39B54A)),
                                  const SizedBox(width: 12),
                                  _statCard(onHoldCount.toString(), "On Hold", const Color(0xFFFFC107)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _statCard(rejectedCount.toString(), "Rejected", const Color(0xFFFF5023)),
                                  const SizedBox(width: 12),
                                  _statCard(pendingCount.toString(), "Pending", const Color(0xFF2E7CCC)),
                                ],
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  // ---------------- 🛠️ ACTION MENU (4 BUTTONS) ----------------
                  const Text("Action Menu", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
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
                        label: "Scan New",
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QCScanBatchScreen(currentUser: widget.currentUser))),
                      ),
                      _actionCard(
                        icon: Icons.pending_actions,
                        label: "Pending QC",
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PendingQCScreen(currentUser: widget.currentUser))),
                      ),
                      _actionCard(
                        icon: Icons.history,
                        label: "QC History",
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QCHistoryScreen())),
                      ),
                      _actionCard(
                        icon: Icons.logout,
                        label: "Logout",
                        textColor: Colors.red,
                        onTap: () => _handleLogout(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- WIDGET HELPERS ----------------

  Widget _statCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(children: [
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  Widget _actionCard({required IconData icon, required String label, required VoidCallback onTap, Color textColor = Colors.black}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 42, color: const Color(0xFF1C4175)),
            const SizedBox(height: 12),
            Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
          ],
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false
    );
  }
}