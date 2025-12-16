class Batch {
  final String material;
  final String batchNo;
  final String vendor;
  final String grn;
  final String regDate;
  final String mfgDate;
  final String expDate;
  final String sampleQty;

  const Batch({
    required this.material,
    required this.batchNo,
    required this.vendor,
    required this.grn,
    required this.regDate,
    required this.mfgDate,
    required this.expDate,
    required this.sampleQty,
  });
}
