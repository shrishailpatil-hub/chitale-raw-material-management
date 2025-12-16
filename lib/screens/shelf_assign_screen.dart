import 'package:flutter/material.dart';

class ShelfAssignScreen extends StatefulWidget {
  const ShelfAssignScreen({super.key});

  @override
  State<ShelfAssignScreen> createState() => _ShelfAssignScreenState();
}

class _ShelfAssignScreenState extends State<ShelfAssignScreen> {
  // ---- State ----
  bool batchScanned = false;

  String? materialName;
  String? batchNo;
  String? qcStatus;
  String? shelfId;

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
            ElevatedButton.icon(
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text(
                'Scan Batch QR',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7CCC),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _scanBatchQr,
            ),

            const SizedBox(height: 20),

            /// STEP 2: Batch Details (only after scan)
            if (batchScanned)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        materialName!,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Batch No: $batchNo',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Chip(
                        label: Text(
                          qcStatus!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        backgroundColor: const Color(0xFF39B54A),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 30),

            /// STEP 3: Scan Shelf QR (only after batch scan)
            if (batchScanned)
              ElevatedButton.icon(
                icon: const Icon(Icons.qr_code),
                label: const Text(
                  'Scan Shelf QR',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7CCC),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _scanShelfQr,
              ),

            const SizedBox(height: 20),

            /// Show scanned shelf
            if (shelfId != null)
              Text(
                'Assigned Shelf: $shelfId',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

            const Spacer(),

            /// STEP 4: Confirm
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: shelfId == null
                      ? Colors.grey
                      : const Color(0xFF2E7CCC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: shelfId == null ? null : _confirmAssignment,
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

  // ---------------- LOGIC ----------------

  void _scanBatchQr() {
    // MOCK QR result (later from scanner)
    setState(() {
      batchScanned = true;
      materialName = 'Sugar (Fine Grade)';
      batchNo = '#2025-10-28-01';
      qcStatus = 'QC Passed';
    });
  }

  void _scanShelfQr() {
    // MOCK shelf scan
    setState(() {
      shelfId = 'RACK-02 / SHELF-04';
    });
  }

  void _confirmAssignment() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Shelf assignment successful (mock)'),
      ),
    );
    Navigator.pop(context);
  }
}
