import 'package:flutter/material.dart';
import '../models/batch.dart';
import '../models/qc_record.dart';
import '../models/user.dart'; // ✅ Import User
import '../services/qc_service.dart';

class QCReviewScreen extends StatefulWidget {
  final Batch batch;
  final User currentUser; // ✅ Accept User

  const QCReviewScreen({
    super.key,
    required this.batch,
    required this.currentUser,
  });

  @override
  State<QCReviewScreen> createState() => _QCReviewScreenState();
}

class _QCReviewScreenState extends State<QCReviewScreen> {
  final TextEditingController _remarksController = TextEditingController();
  QCStatus? _selectedStatus; // Track selection

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QC Review"),
        backgroundColor: const Color(0xFF1C4175),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Batch Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.batch.material, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const Divider(),
                    Text("Batch No: ${widget.batch.batchNo}"),
                    Text("Vendor: ${widget.batch.vendor}"),
                    Text("Exp Date: ${widget.batch.expDate}"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Decision
            const Text("QC Decision:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            RadioListTile<QCStatus>(
              title: const Text("Approve"),
              value: QCStatus.approved,
              groupValue: _selectedStatus,
              onChanged: (val) => setState(() => _selectedStatus = val),
            ),
            RadioListTile<QCStatus>(
              title: const Text("Reject"),
              value: QCStatus.rejected,
              groupValue: _selectedStatus,
              onChanged: (val) => setState(() => _selectedStatus = val),
            ),
            RadioListTile<QCStatus>(
              title: const Text("On Hold (Lab Test)"),
              value: QCStatus.onHold,
              groupValue: _selectedStatus,
              onChanged: (val) => setState(() => _selectedStatus = val),
            ),

            const SizedBox(height: 10),

            // Remarks
            TextField(
              controller: _remarksController,
              decoration: const InputDecoration(
                labelText: "QC Remarks",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 30),

            // Submit
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1C4175)),
                onPressed: _selectedStatus == null ? null : _submitDecision,
                child: const Text("SUBMIT REVIEW", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitDecision() async {
    if (_selectedStatus == null) return;

    await QCService().submitQC(
      batch: widget.batch,
      status: _selectedStatus!,
      remarks: _remarksController.text,
      reviewedBy: widget.currentUser.name, // ✅ Pass correct user name
    );

    if (mounted) {
      Navigator.pop(context); // Go back to Dashboard
      Navigator.pop(context); // Go back from Scan Screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("QC Review Submitted! ✅")),
      );
    }
  }
}