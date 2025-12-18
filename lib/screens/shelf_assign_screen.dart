import 'package:flutter/material.dart';
import '../models/batch.dart';
import '../services/batch_service.dart';
import 'scanner_screen.dart'; // ✅ Uses the real camera

class ShelfAssignScreen extends StatefulWidget {
  const ShelfAssignScreen({super.key});

  @override
  State<ShelfAssignScreen> createState() => _ShelfAssignScreenState();
}

class _ShelfAssignScreenState extends State<ShelfAssignScreen> {
  // ---- State ----
  Batch? selectedBatch;
  String? scannedShelfId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C4175),
        title: const Text(
          'Shelf Assign',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// STEP 1: Scan Batch QR
            _stepCard(
              title: "Step 1: Identify Batch",
              isDone: selectedBatch != null,
              child: selectedBatch == null
                  ? ElevatedButton.icon(
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('SCAN BATCH QR'),
                style: _btnStyle(Colors.blue),
                onPressed: () => _scanQr(isBatch: true),
              )
                  : _batchDetailsCard(selectedBatch!),
            ),

            const SizedBox(height: 20),

            /// STEP 2: Scan Shelf QR
            if (selectedBatch != null)
              _stepCard(
                title: "Step 2: Assign Location",
                isDone: scannedShelfId != null,
                child: scannedShelfId == null
                    ? ElevatedButton.icon(
                  icon: const Icon(Icons.shelves),
                  label: const Text('SCAN SHELF QR'),
                  style: _btnStyle(Colors.orange),
                  onPressed: () => _scanQr(isBatch: false),
                )
                    : Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.orange),
                      const SizedBox(width: 12),
                      Text(
                        "Location: $scannedShelfId",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

            const Spacer(),

            /// STEP 3: Confirm
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: (selectedBatch != null && scannedShelfId != null)
                      ? const Color(0xFF2E7CCC)
                      : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: (selectedBatch != null && scannedShelfId != null)
                    ? _confirmAssignment
                    : null,
                child: const Text(
                  'CONFIRM ASSIGNMENT',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
            Row(
              children: [
                Icon(isDone ? Icons.check_circle : Icons.circle_outlined,
                    color: isDone ? Colors.green : Colors.grey),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
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
          label: Text(batch.status.name.toUpperCase()),
          backgroundColor: batch.status == BatchStatus.approved
              ? Colors.green.shade100
              : Colors.orange.shade100,
        )
      ],
    );
  }

  ButtonStyle _btnStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      minimumSize: const Size(double.infinity, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  // ---------------- LOGIC ----------------

  void _scanQr({required bool isBatch}) async {
    // 1. Open Camera
    final code = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const ScannerScreen()),
    );

    if (code == null) return;

    if (isBatch) {
      // 2. Find Batch in System
      final batch = BatchService().findBatchByNo(code);
      if (batch != null) {
        setState(() => selectedBatch = batch);
      } else {
        _showError("Batch '$code' not found in Inbound Entry!");
      }
    } else {
      // 3. Set Shelf (Any QR code works for a shelf ID)
      setState(() => scannedShelfId = code);
    }
  }

  void _confirmAssignment() {
    // 4. Save the location to the batch object
    if (selectedBatch != null && scannedShelfId != null) {
      selectedBatch!.shelfLocation = scannedShelfId;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Material Stored Successfully!')),
      );
      Navigator.pop(context);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }
}