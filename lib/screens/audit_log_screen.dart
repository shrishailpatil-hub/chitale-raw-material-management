import 'package:flutter/material.dart';
import '../services/database_helper.dart';

class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  List<Map<String, dynamic>> logs = [];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  void _loadLogs() async {
    final data = await DatabaseHelper.instance.getOverrideLogs();
    setState(() => logs = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Override Audit Log"),
        backgroundColor: Colors.black,
      ),
      body: logs.isEmpty
          ? const Center(child: Text("No Policy Violations Found ✅"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.orange,
                child: Icon(Icons.priority_high, color: Colors.white),
              ),
              title: Text("Batch: ${log['batchNo']}"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text("${log['reason']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                  Text("${log['timestamp'].split('T')[0]} • ${log['managerName']}", style: const TextStyle(fontSize: 12)),
                ],
              ),
              trailing: Text(
                  "${log['qtyRequested']} Kg",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red)
              ),
            ),
          );
        },
      ),
    );
  }
}