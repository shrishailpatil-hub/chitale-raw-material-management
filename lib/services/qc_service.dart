import 'package:flutter/foundation.dart';
import '../models/batch.dart';
import '../models/qc_record.dart';
import '../services/database_helper.dart';

class QCService {
  static final QCService _instance = QCService._internal();
  factory QCService() => _instance;

  QCService._internal() {
    refreshPendingList();
    _loadHistory();
  }

  final ValueNotifier<List<Batch>> pendingBatchesNotifier = ValueNotifier([]);
  final ValueNotifier<List<QCRecord>> qcHistoryNotifier = ValueNotifier([]);

  // ✅ FIX: Add this Getter so the UI can read the list directly
  List<QCRecord> get qcHistory => qcHistoryNotifier.value;

  // ---------------- ACTIONS ----------------

  Future<void> refreshPendingList() async {
    final allBatches = await DatabaseHelper.instance.getAllBatches();

    final pending = allBatches
        .map((map) => Batch.fromMap(map))
        .where((b) => b.status == BatchStatus.newBatch || b.status == BatchStatus.onHold)
        .toList();

    pendingBatchesNotifier.value = pending;
  }

  void addBatchForQC(Batch batch) {
    refreshPendingList();
  }

  Future<void> submitQC({
    required Batch batch,
    required QCStatus status,
    required String remarks,
    required String reviewedBy,
    Map<String, dynamic>? parameters,
  }) async {

    final record = QCRecord(
      batch: batch,
      status: status,
      remarks: remarks,
      reviewedBy: reviewedBy,
      timestamp: DateTime.now(),
      parameters: parameters ?? {}, // ✅ Pass parameters safely
    );

    String dbStatus = status.name;

    await DatabaseHelper.instance.updateBatchStatus(
        batch.batchNo,
        dbStatus
    );

    await DatabaseHelper.instance.insertQCRecord(record.toMap());

    await refreshPendingList();
    await _loadHistory();
  }

  Future<void> _loadHistory() async {
    final recordsData = await DatabaseHelper.instance.getQCRecords();

    List<QCRecord> history = [];

    for (var row in recordsData) {
      final batchMap = await DatabaseHelper.instance.getBatch(row['batchNo']);
      if (batchMap != null) {
        final batch = Batch.fromMap(batchMap);

        history.add(QCRecord(
          batch: batch,
          status: QCStatus.values.firstWhere((e) => e.name == row['status']),
          remarks: row['remarks'],
          reviewedBy: row['reviewedBy'],
          timestamp: DateTime.parse(row['timestamp']),
          // Parameters default to empty map in model
        ));
      }
    }

    qcHistoryNotifier.value = history;
  }
}