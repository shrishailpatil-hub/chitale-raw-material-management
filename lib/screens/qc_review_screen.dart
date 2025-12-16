import 'package:flutter/material.dart';

import '../models/batch.dart';
import '../models/qc_record.dart';
import '../services/qc_service.dart';

class QCReviewScreen extends StatefulWidget {
  final Batch batch;

  const QCReviewScreen({
    super.key,
    required this.batch,
  });

  @override
  State<QCReviewScreen> createState() => _QCReviewScreenState();
}

class _QCReviewScreenState extends State<QCReviewScreen> {
  QCStatus? selectedStatus;
  final TextEditingController remarkController = TextEditingController();

  bool get isRemarkRequired =>
      selectedStatus == QCStatus.onHold ||
          selectedStatus == QCStatus.rejected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C4175),
        title: const Text(
          'Quality Control Review',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),

      // ---------- BODY ----------
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          children: [
            _batchDetailsCard(),
            const SizedBox(height: 20),
            _qcStatusSelector(),
            const SizedBox(height: 20),
            _remarkSection(),
          ],
        ),
      ),

      // ---------- FIXED SUBMIT BUTTON ----------
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7CCC),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _submitQC,
              child: const Text(
                'SUBMIT QC RECORD',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- BATCH DETAILS ----------------
  Widget _batchDetailsCard() {
    return _sectionCard(
      title: 'Batch Details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(label: 'Material', value: widget.batch.material),
          _InfoRow(label: 'Batch No', value: widget.batch.batchNo),
          _InfoRow(label: 'GRN', value: widget.batch.grn),
          _InfoRow(label: 'Vendor', value: widget.batch.vendor),
          _InfoRow(label: 'Reg Date', value: widget.batch.regDate),
          _InfoRow(label: 'Mfg Date', value: widget.batch.mfgDate),
          _InfoRow(label: 'Exp Date', value: widget.batch.expDate),
          _InfoRow(label: 'Sample Qty', value: widget.batch.sampleQty),
        ],
      ),
    );
  }

  // ---------------- QC STATUS ----------------
  Widget _qcStatusSelector() {
    return _sectionCard(
      title: 'Select QC Status',
      child: Row(
        children: [
          _statusButton(
            label: 'APPROVED',
            color: Colors.green,
            status: QCStatus.approved,
          ),
          _statusButton(
            label: 'ON HOLD',
            color: Colors.orange,
            status: QCStatus.onHold,
          ),
          _statusButton(
            label: 'REJECTED',
            color: Colors.red,
            status: QCStatus.rejected,
          ),
        ],
      ),
    );
  }

  Widget _statusButton({
    required String label,
    required Color color,
    required QCStatus status,
  }) {
    final bool isSelected = selectedStatus == status;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: GestureDetector(
          onTap: () => setState(() => selectedStatus = status),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 70,
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.15) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? color : Colors.grey.shade400,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : Colors.black,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- REMARKS ----------------
  Widget _remarkSection() {
    return _sectionCard(
      title: 'Remarks',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: remarkController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: isRemarkRequired
                  ? 'Enter reason (mandatory)'
                  : 'Optional remarks',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Validated by: Arun Jadhav (QC Staff)\nTimestamp: Auto captured on submission',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ---------------- SUBMIT ----------------
  void _submitQC() {
    if (selectedStatus == null) {
      _showError('Please select QC status');
      return;
    }

    if (isRemarkRequired && remarkController.text.trim().isEmpty) {
      _showError('Remarks are mandatory for Hold / Reject');
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Submission'),
        content: const Text('Are you sure you want to submit this QC record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              QCService().submitQC(
                batch: widget.batch,
                status: selectedStatus!,
                remarks: remarkController.text.trim(),
                reviewedBy: 'Arun Jadhav',
              );

              Navigator.pop(ctx);       // close dialog
              Navigator.pop(context);   // back to Pending QC
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  // ---------------- COMMON CARD ----------------
  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 8,
            offset: Offset(2, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// ---------------- INFO ROW ----------------
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
