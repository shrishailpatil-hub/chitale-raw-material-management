import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/user.dart';
import 'inbound_entry_screen.dart';
import 'shelf_assign_screen.dart';
import 'issue_material_screen.dart';
import 'loginpage.dart';

class AdminDashboard extends StatefulWidget {
  final User? currentUser;
  const AdminDashboard({super.key, this.currentUser});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1C4175),
        title: const Text('Inventory Control', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadStats)
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadStats(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                            backgroundColor: const Color(0xFF1C4175),
                            child: Text(
                              widget.currentUser?.name.substring(0, 1).toUpperCase() ?? "M",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Inbound Manager", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                              Text(
                                widget.currentUser?.name ?? "Manager",
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                            ],
                          ),
                          const Spacer(),
                          const Icon(Icons.warehouse, color: Color(0xFF1C4175), size: 28),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- LIVE STATS ---
                    const Text("Warehouse Overview", style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
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

                    // --- ACTIONS ---
                    const Text("Quick Actions", style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
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
                          onTap: () => _navigate(InboundEntryScreen(currentUser: widget.currentUser!)),
                        ),
                        _actionCard(
                          icon: Icons.move_to_inbox,
                          label: "Shelf Assign",
                          onTap: () => _navigate(const ShelfAssignScreen()),
                        ),
                        _actionCard(
                          icon: Icons.outbox,
                          label: "Issue Material",
                          onTap: () => _navigate(const IssueMaterialScreen()),
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
      ),
    );
  }

  void _navigate(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    _loadStats();
  }

  void _handleLogout(BuildContext context) async {
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
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (route) => false);
    }
  }

  Widget _statCard(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
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
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black54)),
          ],
        ),
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
          boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 10, offset: Offset(0, 4))],
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
}