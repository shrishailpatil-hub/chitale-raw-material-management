import '../models/batch.dart';

class BatchService {
  static final BatchService _instance = BatchService._internal();
  factory BatchService() => _instance;
  BatchService._internal();

  // This simulates the master database of ALL batches in the warehouse
  final List<Batch> _allBatches = [];

  // Create a new batch (Called from Inbound Entry)
  void createBatch(Batch batch) {
    _allBatches.add(batch);
    print("📦 BatchService: Created master batch ${batch.batchNo}");
  }

  // Find a batch by ID (Called from QC Scanner)
  Batch? findBatchByNo(String batchNo) {
    try {
      return _allBatches.firstWhere((b) => b.batchNo == batchNo);
    } catch (e) {
      return null;
    }
  }

  List<Batch> get allBatches => List.unmodifiable(_allBatches);
}