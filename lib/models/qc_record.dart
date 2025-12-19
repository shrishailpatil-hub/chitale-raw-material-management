import 'batch.dart';

enum QCStatus { approved, onHold, rejected }

class QCRecord {
  final Batch batch;
  final QCStatus status;
  final String remarks;
  final String reviewedBy;
  final DateTime timestamp;
  final Map<String, dynamic> parameters; // ✅ Kept this

  QCRecord({
    required this.batch,
    required this.status,
    required this.remarks,
    required this.reviewedBy,
    required this.timestamp,
    this.parameters = const {}, // ✅ Added default empty value (Fixes Error)
  });

  // Convert to Map for Database
  Map<String, dynamic> toMap() {
    return {
      'batchNo': batch.batchNo,
      'status': status.name,
      'remarks': remarks,
      'reviewedBy': reviewedBy,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}