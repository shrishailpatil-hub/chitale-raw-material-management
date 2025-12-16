import 'batch.dart';

enum QCStatus {
  approved,
  onHold,
  rejected,
}

class QCRecord {
  final Batch batch;
  final QCStatus status;
  final String remarks;
  final DateTime timestamp;
  final String reviewedBy;

  /// Future-proof parameters:
  /// temperature, humidity, pH, moisture, etc.
  final Map<String, dynamic> parameters;

  const QCRecord({
    required this.batch,
    required this.status,
    required this.remarks,
    required this.timestamp,
    required this.reviewedBy,
    required this.parameters,
  });
}
