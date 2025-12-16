import 'batch.dart'; // Import Batch to access Batch class

enum QCStatus { approved, onHold, rejected }

class QCRecord {
  final Batch batch;
  final QCStatus status;
  final String remarks;
  final String reviewedBy;
  final DateTime timestamp;
  final Map<String, dynamic> parameters;

  QCRecord({
    required this.batch,
    required this.status,
    required this.remarks,
    required this.reviewedBy,
    required this.timestamp,
    required this.parameters,
  });
}