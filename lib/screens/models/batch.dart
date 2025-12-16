enum BatchStatus { newBatch, onHold, approved, rejected }

class Batch {
  final String material;
  final String batchNo;
  final String vendor;
  final String grn;
  final String regDate;
  final String mfgDate;
  final String expDate;
  final String sampleQty;

  // ✅ New Field: Mutable status so we can update it to "On Hold"
  BatchStatus status;

  Batch({
    required this.material,
    required this.batchNo,
    required this.vendor,
    required this.grn,
    required this.regDate,
    required this.mfgDate,
    required this.expDate,
    required this.sampleQty,
    this.status = BatchStatus.newBatch, // Default is 'New'
  });
}