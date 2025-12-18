import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import 'inbound_entry_screen.dart';
import 'shelf_assign_screen.dart';
import 'issue_material_screen.dart';
import 'loginpage.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // Stats State
  Map<String, int> stats = {
    'putAway': 0,
    'pendingQC': 0,
    'lowStock': 0,
    'total': 0,
  };
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  // Reload stats whenever we come back to this screen
  void _loadStats() async {
    final newStats = await DatabaseHelper.instance.getAdminStats();
    if (mounted) {
      setState(() {
        stats = newStats;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Refresh stats when pulling down or coming back
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C4175),
        title: const Text('Operator Dashboard', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats, // Manual refresh
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadStats(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------- WELCOME ----------------
              const Text(
                "Welcome,\nArun Jadhav",
                style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),

              // ---------------- LIVE STATS ----------------
              const Text("Warehouse Overview", style: TextStyle(fontSize: 18,color: Colors.black , fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              Row(
                children: [
                  _statCard("Pending Put-away", stats['putAway'].toString(), Colors.orange, Icons.shelves),
                  const SizedBox(width: 12),
                  _statCard("Low Stock Alerts", stats['lowStock'].toString(), Colors.red, Icons.warning_amber),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _statCard("Pending QC", stats['pendingQC'].toString(), Colors.blue, Icons.science),
                  const SizedBox(width: 12),
                  _statCard("Total Batches", stats['total'].toString(), Colors.green, Icons.inventory_2),
                ],
              ),

              const SizedBox(height: 30),

              // ---------------- ACTIONS ----------------
              const Text("Quick Actions", style: TextStyle(fontSize: 18, color: Colors.black,fontWeight: FontWeight.bold)),
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
                    icon: Icons.add_box,
                    label: "Inbound Entry",
                    onTap: () => _navigate(const InboundEntryScreen()),
                  ),
                  _actionCard(
                    icon: Icons.move_to_inbox,
                    label: "Shelf Assign",
                    onTap: () => _navigate(const ShelfAssignScreen()),
                  ),
                  _actionCard(
                    icon: Icons.outbox,
                    label: "Issue Material",
                    onTap: () {
                      // TODO: Create IssueMaterialScreen
                      // _navigate(const IssueMaterialScreen());
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Coming in Phase 2")));
                    },
                  ),
                  _actionCard(
                    icon: Icons.logout,
                    label: "Logout",
                    onTap: () async {
                      final shouldLogout = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Logout"),
                          content: const Text("Are you sure?"),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
                            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Logout", style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      );
                      if (shouldLogout == true) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                              (route) => false,
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- HELPERS ----------------

  void _navigate(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    _loadStats(); // Refresh stats when coming back
  }

  Widget _statCard(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 28),
                Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _actionCard({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x1F000000), blurRadius: 8, offset: Offset(2, 2))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 42, color: const Color(0xFF1C4175)),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}