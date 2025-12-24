import 'package:flutter/material.dart';
import '../models/qc_record.dart';
import '../services/qc_service.dart';

class QCHistoryScreen extends StatelessWidget {
  const QCHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Fetch the history list from the Service
    // We reverse the list so the Newest records appear at the TOP
    final List<QCRecord> history = QCService().qcHistory.reversed.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C4175),
        title: const Text(
          'QC History Log',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: history.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: history.length,
        itemBuilder: (context, index) {
          final record = history[index];
          return _HistoryCard(record: record);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No History Records Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- HISTORY CARD ----------------

class _HistoryCard extends StatelessWidget {
  final QCRecord record;

  const _HistoryCard({required this.record});

  // Helper to get color based on status
  Color get _statusColor {
    switch (record.status) {
      case QCStatus.approved:
        return Colors.green;
      case QCStatus.rejected:
        return Colors.red;
      case QCStatus.onHold:
        return Colors.orange;
    }
  }

  // Helper to get icon based on status
  IconData get _statusIcon {
    switch (record.status) {
      case QCStatus.approved:
        return Icons.check_circle;
      case QCStatus.rejected:
        return Icons.cancel;
      case QCStatus.onHold:
        return Icons.hourglass_bottom;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // Left border showing status color
        border: Border(
          left: BorderSide(color: _statusColor, width: 6),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER: Material Name + Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  record.batch.material,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Icon(_statusIcon, color: _statusColor, size: 28),
            ],
          ),

          const SizedBox(height: 8),

          // BATCH INFO
          Text(
            "Batch: ${record.batch.batchNo}",
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15,color: Colors.black),
          ),

          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),

          // REMARKS
          if (record.remarks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Remarks: ", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blueAccent)),
                  Expanded(
                    child: Text(
                      record.remarks,
                      style: TextStyle(color: Colors.grey.shade800),
                    ),
                  ),
                ],
              ),
            ),

          // FOOTER: Reviewer + Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "By: ${record.reviewedBy}",
                style: TextStyle(fontSize: 12, color: Colors.grey,fontWeight: FontWeight.bold),
              ),
              Text(
                _formatDate(record.timestamp),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Simple Date Formatter (No external packages needed)
  String _formatDate(DateTime dt) {
    // Returns format like: "10:30 AM - 12/12/2025"
    final String time = "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    final String date = "${dt.day}/${dt.month}/${dt.year}";
    return "$time - $date";
  }
}