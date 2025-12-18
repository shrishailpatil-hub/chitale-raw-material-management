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
    print("📢 QCService: Submitting QC for ${batch.batchNo} - Status: $status");

    // ---------------------------------------------------------
    // ✅ THE MISSING LINK: Update the actual Batch object!
    // ---------------------------------------------------------
    if (status == QCStatus.approved) {
      batch.status = BatchStatus.approved;
    } else if (status == QCStatus.rejected) {
      batch.status = BatchStatus.rejected;
    } else if (status == QCStatus.onHold) {
      batch.status = BatchStatus.onHold;
    }

    // 1. Create the History Record
    final record = QCRecord(
      batch: batch,
      status: status,
      remarks: remarks,
      reviewedBy: reviewedBy,
      timestamp: DateTime.now(),
      parameters: parameters ?? {},
    );

    // 2. HANDLE PENDING LIST LOGIC
    if (status == QCStatus.onHold) {
      // Keep in list (we already updated batch.status above)
    } else {
      // Remove from Pending if Approved or Rejected
      _pendingBatches.removeWhere((b) => b.batchNo == batch.batchNo);
    }

    // 3. Add to History
    _qcHistory.add(record);

    // 4. Update UI
    _notifyListeners();
  }

  void _notifyListeners() {
    // Update BOTH notifiers
    pendingBatchesNotifier.value = List.from(_pendingBatches);
    qcHistoryNotifier.value = List.from(_qcHistory);
  }
}