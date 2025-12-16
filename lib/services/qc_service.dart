import 'package:flutter/foundation.dart';
import '../models/batch.dart';
import '../models/qc_record.dart';

class QCService {
  static final QCService _instance = QCService._internal();
  factory QCService() => _instance;

  QCService._internal() {
    // Initialize Notifiers
    pendingBatchesNotifier.value = List.from(_pendingBatches);
    qcHistoryNotifier.value = List.from(_qcHistory);
  }

  final List<Batch> _pendingBatches = [];
  final List<QCRecord> _qcHistory = [];

  // ✅ TWO NOTIFIERS NOW
  final ValueNotifier<List<Batch>> pendingBatchesNotifier = ValueNotifier([]);
  final ValueNotifier<List<QCRecord>> qcHistoryNotifier = ValueNotifier([]);

  List<Batch> get pendingBatches => List.unmodifiable(_pendingBatches);
  List<QCRecord> get qcHistory => List.unmodifiable(_qcHistory);

  void addBatchForQC(Batch batch) {
    _pendingBatches.add(batch);
    _notifyListeners();
  }

  void submitQC({
    required Batch batch,
    required QCStatus status,
    required String remarks,
    required String reviewedBy,
    Map<String, dynamic>? parameters,
  }) {
    final record = QCRecord(
      batch: batch,
      status: status,
      remarks: remarks,
      reviewedBy: reviewedBy,
      timestamp: DateTime.now(),
      parameters: parameters ?? {},
    );

    // Logic: Keep in pending if On Hold, remove otherwise
    if (status != QCStatus.onHold) {
      _pendingBatches.removeWhere((b) => b.batchNo.trim() == batch.batchNo.trim());
    }

    _qcHistory.add(record);
    _notifyListeners();
  }

  void _notifyListeners() {
    // Update BOTH notifiers
    pendingBatchesNotifier.value = List.from(_pendingBatches);
    qcHistoryNotifier.value = List.from(_qcHistory);
  }
}