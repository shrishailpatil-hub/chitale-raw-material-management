import 'package:flutter/material.dart';
import '../models/batch.dart';
import '../services/database_helper.dart'; // ✅ Use Database
import 'scanner_screen.dart';

class ShelfAssignScreen extends StatefulWidget {
  const ShelfAssignScreen({super.key});

  @override
  State<ShelfAssignScreen> createState() => _ShelfAssignScreenState();
}

class _ShelfAssignScreenState extends State<ShelfAssignScreen> {
  Batch? selectedBatch;
  String? scannedShelfId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C4175),
        title: const Text('Shelf Assign', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // STEP 1
            _stepCard(
              title: "Step 1: Identify Batch",
              isDone: selectedBatch != null,
              child: selectedBatch == null
                  ? ElevatedButton.icon(
                icon: const Icon(Icons.qr_code_scanner,color: Colors.white,),
                label: const Text('SCAN BATCH QR',style: TextStyle(color: Colors.white),),
                style: _btnStyle(const Color(0xFF1C4175)),
                onPressed: () => _scanQr(isBatch: true),
              )
                  : _batchDetailsCard(selectedBatch!),
            ),
            const SizedBox(height: 20),

            // STEP 2
            if (selectedBatch != null)
              _stepCard(
                title: "Step 2: Assign Location",
                isDone: scannedShelfId != null,
                child: scannedShelfId == null
                    ? ElevatedButton.icon(
                  icon: const Icon(Icons.shelves,color: Colors.white,),
                  label: const Text('SCAN SHELF QR',style: TextStyle(color: Colors.white),),
                  style: _btnStyle(Colors.orange),
                  onPressed: () => _scanQr(isBatch: false),
                )
                    : Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white),
                      const SizedBox(width: 12),
                      Text("Location: $scannedShelfId", style: const TextStyle(fontSize: 18, color: Colors.black,fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            const Spacer(),

            // CONFIRM
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: (selectedBatch != null && scannedShelfId != null) ? const Color(0xFF2E7CCC) : Colors.grey,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: (selectedBatch != null && scannedShelfId != null) ? _confirmAssignment : null,
                child: const Text('CONFIRM ASSIGNMENT', style: TextStyle(fontSize: 18, color: Colors.white,fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- LOGIC ----------------

  void _scanQr({required bool isBatch}) async {
    final code = await Navigator.push<String>(context, MaterialPageRoute(builder: (context) => const ScannerScreen()));
    if (code == null) return;

    if (isBatch) {
      // ✅ FIX: Look up in Database, not BatchService
      final batchMap = await DatabaseHelper.instance.getBatch(code);

      if (batchMap != null) {
        final batch = Batch.fromMap(batchMap);
        setState(() => selectedBatch = batch);
      } else {
        _showError("Batch '$code' not found in Database!");
      }
    } else {
      setState(() => scannedShelfId = code);
    }
  }

  void _confirmAssignment() async {
    if (selectedBatch != null && scannedShelfId != null) {
      // ✅ FIX: Update Database
      await DatabaseHelper.instance.updateBatchStatus(
          selectedBatch!.batchNo,
          selectedBatch!.status.name, // Keep existing status
          shelf: scannedShelfId // Update shelf
      );

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Material Stored Successfully!')));
      Navigator.pop(context);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  // ---------------- UI HELPERS ----------------
  Widget _stepCard({required String title, required bool isDone, required Widget child}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(isDone ? Icons.check_circle : Icons.circle_outlined, color: isDone ? Colors.green : Colors.grey), const SizedBox(width: 10), Text(title, style: const TextStyle(fontSize: 18, color: Colors.white,fontWeight: FontWeight.bold))]),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _batchDetailsCard(Batch batch) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(batch.material, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text("Batch: ${batch.batchNo}", style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 5),
        Chip(
          label: Text(batch.status.name.toUpperCase(),style: TextStyle(color: Colors.black),),
          backgroundColor: batch.status == BatchStatus.approved ? Colors.green : Colors.orange,
        )
      ],
    );
  }

  ButtonStyle _btnStyle(Color color) {
    return ElevatedButton.styleFrom(backgroundColor: color, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)));
  }
}