// File: lib/models/batch.dart

enum BatchStatus { newBatch, onHold, approved, rejected }

class Batch {
  final String material;
  final String batchNo;
  final String vendor;
  final String grn;
  final String regDate;
  final String mfgDate;
  final String expDate;

  // ✅ RE-ADDED SAMPLE QTY
  final String sampleQty;

  // ✅ INVENTORY FIELDS
  final double initialQty;
  double currentQty;
  final String unit;

  BatchStatus status;
  String? shelfLocation;

  Batch({
    required this.material,
    required this.batchNo,
    required this.vendor,
    required this.grn,
    required this.regDate,
    required this.mfgDate,
    required this.expDate,
    required this.sampleQty,
    required this.initialQty,
    required this.currentQty,
    required this.unit,
    this.status = BatchStatus.newBatch,
    this.shelfLocation,
  });

  // Database Helpers
  Map<String, dynamic> toMap() {
    return {
      'batchNo': batchNo,
      'material': material,
      'vendor': vendor,
      'grn': grn,
      'regDate': regDate,
      'mfgDate': mfgDate,
      'expDate': expDate,
      'sampleQty': sampleQty,
      'status': status.name,
      'shelfLocation': shelfLocation,
      'initialQty': initialQty,
      'currentQty': currentQty,
      'unit': unit,
    };
  }

  factory Batch.fromMap(Map<String, dynamic> map) {
    return Batch(
      batchNo: map['batchNo'],
      material: map['material'],
      vendor: map['vendor'],
      grn: map['grn'],
      regDate: map['regDate'],
      mfgDate: map['mfgDate'],
      expDate: map['expDate'],
      sampleQty: map['sampleQty'] ?? 'N/A',
      status: BatchStatus.values.firstWhere((e) => e.name == map['status']),
      shelfLocation: map['shelfLocation'],
      initialQty: map['initialQty'] ?? 0.0,
      currentQty: map['currentQty'] ?? 0.0,
      unit: map['unit'] ?? 'Kg',
    );
  }
}