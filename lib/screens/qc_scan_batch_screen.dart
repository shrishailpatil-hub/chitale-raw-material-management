import 'package:flutter/material.dart';
import '../models/batch.dart';
import '../models/user.dart'; // ✅ Import
import '../services/batch_service.dart';
import '../services/qc_service.dart';
import '../services/database_helper.dart';
import 'qc_review_screen.dart';
import 'scanner_screen.dart';

class QCScanBatchScreen extends StatefulWidget {
  final User currentUser; // ✅ Accept User
  const QCScanBatchScreen({super.key, required this.currentUser});

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
        title: const Text('Scan Batch for QC', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text('Scan Raw Material Batch QR', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 40),
            Container(
              height: 200, width: double.infinity,
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.qr_code_scanner, size: 100, color: Colors.white),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('OPEN CAMERA SCANNER'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7CCC), minimumSize: const Size(double.infinity, 55)),
              onPressed: _openCameraScanner,
            ),
            const SizedBox(height: 20),
            if (scannedBatch != null) _scanResultCard(scannedBatch!),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: scannedBatch != null ? const Color(0xFF1C4175) : Colors.grey,
                ),
                onPressed: scannedBatch != null ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // ✅ PASS USER TO REVIEW SCREEN
                      builder: (_) => QCReviewScreen(batch: scannedBatch!, currentUser: widget.currentUser),
                    ),
                  );
                } : null,
                child: const Text('CONTINUE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCameraScanner() async {
    final result = await Navigator.push<String>(context, MaterialPageRoute(builder: (context) => const ScannerScreen()));
    if (result != null && result.isNotEmpty) _processScan(result);
  }

  void _processScan(String batchNo) async {
    final batchMap = await DatabaseHelper.instance.getBatch(batchNo);
    if (batchMap != null) {
      final foundBatch = Batch.fromMap(batchMap);
      QCService().addBatchForQC(foundBatch);
      setState(() => scannedBatch = foundBatch);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Batch not found!"), backgroundColor: Colors.red));
    }
  }

  Widget _scanResultCard(Batch batch) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.check_circle, color: Colors.green),
        title: Text(batch.material),
        subtitle: Text("Batch: ${batch.batchNo}"),
      ),
    );
  }
}