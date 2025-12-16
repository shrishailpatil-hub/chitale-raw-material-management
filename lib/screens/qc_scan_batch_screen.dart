import 'package:flutter/material.dart';
import '../models/batch.dart';
import '../services/batch_service.dart';
import '../services/qc_service.dart';
import 'qc_review_screen.dart';
import 'scanner_screen.dart'; // ✅ Import the new scanner screen

class QCScanBatchScreen extends StatefulWidget {
  const QCScanBatchScreen({super.key});

  @override
  State<QCScanBatchScreen> createState() => _QCScanBatchScreenState();
}

class _QCScanBatchScreenState extends State<QCScanBatchScreen> {
  Batch? scannedBatch;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C4175),
        title: const Text(
          'Scan Batch for QC',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            const Text(
              'Scan Raw Material Batch QR',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Point the camera at the batch QR label to begin QC.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 40),

            // Black QR Box
            Container(
              height: 260,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Icon(
                  Icons.qr_code_scanner,
                  size: 100,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // SCAN BUTTON
            ElevatedButton.icon(
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text(
                'OPEN CAMERA SCANNER',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7CCC),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _openCameraScanner, // ✅ Use Camera function
            ),

            const SizedBox(height: 20),

            if (scannedBatch != null) _scanResultCard(scannedBatch!),

            const Spacer(),

            // CONTINUE BUTTON
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: scannedBatch != null
                      ? const Color(0xFF1C4175)
                      : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: scannedBatch != null
                    ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          QCReviewScreen(batch: scannedBatch!),
                    ),
                  );
                }
                    : null,
                child: const Text(
                  'CONTINUE',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- LOGIC: THE REAL SCANNER ----------------

  void _openCameraScanner() async {
    // 1. Navigate to the Camera Screen and wait for result
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const ScannerScreen()),
    );

    // 2. If we got a code back
    if (result != null && result.isNotEmpty) {
      debugPrint("📸 Scanned Code from Camera: $result");
      _processScan(result);
    }
  }

  void _processScan(String batchNo) {
    if (batchNo.isEmpty) return;

    // 1. LOOK UP IN WAREHOUSE (BatchService)
    final foundBatch = BatchService().findBatchByNo(batchNo);

    if (foundBatch != null) {
      // ✅ SUCCESS: We found real data!
      // Add it to the QC Pending list so we can track it
      QCService().addBatchForQC(foundBatch);

      setState(() {
        scannedBatch = foundBatch;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Batch $batchNo found in system! ✅")),
      );
    } else {
      // ❌ FAILURE: Batch doesn't exist
      setState(() {
        scannedBatch = null;
      });

      _showErrorDialog(batchNo);
    }
  }

  void _showErrorDialog(String batchNo) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Scan Failed ❌"),
        content: Text("Batch '$batchNo' does not exist in the Inbound System.\n\nPlease check with the Store Manager."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // ---------------- RESULT CARD ----------------
  Widget _scanResultCard(Batch batch) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 6,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 30),
              const SizedBox(width: 12),
              const Text(
                'Valid Batch Found',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Text("Material: ${batch.material}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
          Text("Batch No: ${batch.batchNo}", style: const TextStyle(fontSize: 15, color: Colors.black87)),
          Text("Vendor: ${batch.vendor}", style: const TextStyle(fontSize: 15, color: Colors.black87)),
        ],
      ),
    );
  }
}