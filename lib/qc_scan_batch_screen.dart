import 'package:flutter/material.dart';

class QCScanBatchScreen extends StatefulWidget {
  const QCScanBatchScreen({super.key});

  @override
  State<QCScanBatchScreen> createState() => _QCScanBatchScreenState();
}

class _QCScanBatchScreenState extends State<QCScanBatchScreen> {
  String? scannedBatch;

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

            // ---------------- INSTRUCTION ----------------
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

            // ---------------- SCAN AREA ----------------
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

            // ---------------- SCAN BUTTON ----------------
            ElevatedButton.icon(
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text(
                'SCAN BATCH QR',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7CCC),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _mockScan,
            ),

            const SizedBox(height: 20),

            // ---------------- RESULT ----------------
            if (scannedBatch != null)
              _scanResultCard(scannedBatch!),

            const Spacer(),

            // ---------------- CONTINUE ----------------
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  scannedBatch != null ? const Color(0xFF1C4175) : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: scannedBatch != null
                    ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Proceeding to QC Review (mock)'),
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

  // ---------------- MOCK SCAN ----------------
  void _mockScan() {
    setState(() {
      scannedBatch = '#BATCH-2025-10-28';
    });
  }

  // ---------------- RESULT CARD ----------------
  Widget _scanResultCard(String batch) {
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
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 30,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Batch Scanned Successfully\n$batch',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
