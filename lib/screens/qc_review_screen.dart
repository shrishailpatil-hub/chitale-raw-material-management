import 'package:flutter/material.dart';
import '../models/batch.dart';
import '../models/qc_record.dart';
import '../models/user.dart';
import '../services/qc_service.dart';

class QCReviewScreen extends StatefulWidget {
  final Batch batch;
  final User currentUser;

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
  QCStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("QC Decision Review", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1C4175),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📦 BATCH INFORMATION CARD
            _infoSection(),

            const SizedBox(height: 25),
            const Text("Select Decision:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 15),

            // 🟢 APPROVE OPTION
            _statusSelectionCard(
              status: QCStatus.approved,
              label: "APPROVE BATCH",
              description: "Material is safe for production.",
              activeColor: Colors.green.shade700,
              icon: Icons.check_circle,
            ),

            const SizedBox(height: 12),

            // 🟡 ON HOLD OPTION
            _statusSelectionCard(
              status: QCStatus.onHold,
              label: "SEND TO LAB (ON HOLD)",
              description: "Requires further testing.",
              activeColor: Colors.orange.shade700,
              icon: Icons.biotech,
            ),

            const SizedBox(height: 12),

            // 🔴 REJECT OPTION
            _statusSelectionCard(
              status: QCStatus.rejected,
              label: "REJECT BATCH",
              description: "Material does not meet standards.",
              activeColor: Colors.red.shade700,
              icon: Icons.cancel,
            ),

            const SizedBox(height: 25),

            // 📝 REMARKS SECTION
            const Text("QC Remarks:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 10),
            TextField(
              controller: _remarksController,
              maxLines: 3,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: "Enter analysis details here...",
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 35),

            // 🚀 SUBMIT BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedStatus == null ? Colors.grey : const Color(0xFF1C4175),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _selectedStatus == null ? null : _submitDecision,
                child: const Text("SUBMIT FINAL REVIEW", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🛠️ HELPER: BATCH INFO CARD
  Widget _infoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.shade100, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.batch.material, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1C4175))),
          const Divider(height: 20),
          _batchDetailRow("Batch Number", widget.batch.batchNo),
          _batchDetailRow("Supplier", widget.batch.vendor),
          _batchDetailRow("Expiry Date", widget.batch.expDate),
        ],
      ),
    );
  }

  Widget _batchDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // 🛠️ HELPER: COLORFUL SELECTION CARDS
  Widget _statusSelectionCard({
    required QCStatus status,
    required String label,
    required String description,
    required Color activeColor,
    required IconData icon,
  }) {
    bool isSelected = _selectedStatus == status;

    return InkWell(
      onTap: () => setState(() => _selectedStatus = status),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? activeColor : Colors.grey.shade300, width: 2),
          boxShadow: isSelected ? [BoxShadow(color: activeColor.withOpacity(0.3), blurRadius: 8)] : [],
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.white : activeColor, size: 30),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isSelected ? Colors.white : Colors.black)),
                  Text(description, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white70 : Colors.grey.shade600)),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle_outline, color: Colors.white),
          ],
        ),
      ),
    );
  }

  void _submitDecision() async {
    if (_selectedStatus == null) return;

    if ((_selectedStatus == QCStatus.rejected || _selectedStatus == QCStatus.onHold) &&
        _remarksController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("⚠️ A reason/remark is compulsory for ${_selectedStatus!.name.toUpperCase()}",style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.red.shade900,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return; // Stop the submission
    }

    await QCService().submitQC(
      batch: widget.batch,
      status: _selectedStatus!,
      remarks: _remarksController.text,
      reviewedBy: widget.currentUser.name,
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Success: ${widget.batch.batchNo} has been ${_selectedStatus!.name}!"),
          backgroundColor: Colors.white,
        ),
      );
    }
  }
}