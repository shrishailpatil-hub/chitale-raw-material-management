import 'package:flutter/material.dart';

class IssueMaterialScreen extends StatefulWidget {
  const IssueMaterialScreen({super.key});

  @override
  State<IssueMaterialScreen> createState() => _IssueMaterialScreenState();
}

class _IssueMaterialScreenState extends State<IssueMaterialScreen> {
  // -------- MOCK DATA (Phase 1) --------
  final String requestId = '#REQ-Kitchen-882';
  final String department = 'Central Kitchen';
  final String material = 'Sugar (Fine Grade)';
  final double requiredQty = 15.0;

  final String fefoShelf = 'SHELF B-04';
  final String fefoBatch = '#2025-10-28-01';
  final String expiryDate = '28/04/2025';
  final double availableQty = 25.0;

  // -------- STATE --------
  String? scannedShelf;
  final TextEditingController issueQtyController =
  TextEditingController(text: '15.0');

  bool get isFefoMatch => scannedShelf == fefoShelf;

  @override
  void dispose() {
    issueQtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C4175),
        title: const Text(
          'Issue Material',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _darkSection(
              title: 'Order Fulfillment Details',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _kv('Request ID', requestId),
                  _kv('Department', department),
                  _kv('Material', material),
                  _kv('Required Qty', '$requiredQty Kg'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _darkSection(
              title: 'FEFO Recommendation',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _kv('Target Shelf', fefoShelf),
                  _kv('Batch', fefoBatch),
                  _kv('Expiry Date', expiryDate),
                  _kv('Available Qty', '$availableQty Kg'),
                  const SizedBox(height: 10),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Expiring Soon',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// Scan Shelf QR
            ElevatedButton.icon(
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text(
                'Scan Shelf QR',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7CCC),
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _scanShelf,
            ),

            if (scannedShelf != null) ...[
              const SizedBox(height: 10),
              Text(
                'Scanned Shelf: $scannedShelf',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isFefoMatch ? Colors.green : Colors.red,
                ),
              ),
            ],

            const SizedBox(height: 20),

            _darkSection(
              title: 'Confirm Issue Quantity',
              child: TextField(
                controller: issueQtyController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                decoration: const InputDecoration(
                  labelText: 'Issuing Now (Kg)',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white38),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  _canConfirm() ? const Color(0xFF2E7CCC) : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _canConfirm() ? _confirmIssue : null,
                child: const Text(
                  'CONFIRM ISSUE',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- UI HELPERS ----------------

  Widget _darkSection({required String title, required Widget child}) {
    return Card(
      color: const Color(0xFF1F1F1F),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _kv(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        '$key: $value',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }

  // ---------------- LOGIC ----------------

  void _scanShelf() {
    // MOCK scan – replace with real QR later
    setState(() {
      scannedShelf = 'SHELF B-04';
    });
  }

  bool _canConfirm() {
    final qty = double.tryParse(issueQtyController.text) ?? 0;
    return scannedShelf != null &&
        isFefoMatch &&
        qty > 0 &&
        qty <= requiredQty &&
        qty <= availableQty;
  }

  void _confirmIssue() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Material issued successfully (mock)'),
      ),
    );
    Navigator.pop(context);
  }
}
