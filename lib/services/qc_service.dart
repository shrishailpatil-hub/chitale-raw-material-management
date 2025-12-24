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
      parameters: parameters ?? {},
    );

    String dbStatus = status.name;

    await DatabaseHelper.instance.updateBatchStatus(
        batch.batchNo,
        status.name
    );

    await DatabaseHelper.instance.insertQCRecord(record.toMap());

    await refreshPendingList();
    await _loadHistory();
  }

  Future<void> _loadHistory() async {
    final recordsData = await DatabaseHelper.instance.getQCRecords();

    // Use a Map to keep only the LATEST record for each batchNo
    Map<String, QCRecord> latestRecords = {};

    for (var row in recordsData) {
      final batchMap = await DatabaseHelper.instance.getBatch(row['batchNo']);
      if (batchMap != null) {
        final batch = Batch.fromMap(batchMap);
        final timestamp = DateTime.parse(row['timestamp']);
        final batchNo = row['batchNo'];

        final currentRecord = QCRecord(
          batch: batch,
          status: QCStatus.values.firstWhere((e) => e.name == row['status']),
          remarks: row['remarks'],
          reviewedBy: row['reviewedBy'],
          timestamp: timestamp,
        );

        // Only keep the record if it's newer than what we already have for this batch
        if (!latestRecords.containsKey(batchNo) ||
            timestamp.isAfter(latestRecords[batchNo]!.timestamp)) {
          latestRecords[batchNo] = currentRecord;
        }
      }
    }

    // Update the notifier with the filtered list
    qcHistoryNotifier.value = latestRecords.values.toList();
  }
}