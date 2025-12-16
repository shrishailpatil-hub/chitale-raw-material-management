import '../models/batch.dart';

class BatchService {
  // ---------------- MOCK PENDING QC BATCHES ----------------
  static List<Batch> getPendingQCBatches() {
    return const [
      Batch(
        material: 'Whole Wheat Flour',
        batchNo: '#BATCH-2025-10-28',
        vendor: 'ABC Agro Supplies',
        grn: '#25-9981',
        regDate: '01/11/2025',
        mfgDate: '28/10/2025',
        expDate: '28/04/2026',
        sampleQty: '500 g',
      ),
      Batch(
        material: 'Sugar (Fine Refine)',
        batchNo: '#BATCH-2025-12-30',
        vendor: 'Sweetener Solution Ltd',
        grn: '#25-9982',
        regDate: '15/11/2025',
        mfgDate: '30/10/2025',
        expDate: '30/04/2026',
        sampleQty: '500 g',
      ),
      Batch(
        material: 'Milk Powder',
        batchNo: '#BATCH-2025-14-10',
        vendor: 'ABC Agro Supplies',
        grn: '#25-9983',
        regDate: '20/11/2025',
        mfgDate: '10/11/2025',
        expDate: '10/05/2026',
        sampleQty: '500 g',
      ),
    ];
  }

  // ---------------- MOCK QR SCAN ----------------
  static Batch scanBatchFromQR() {
    // later: replace with QR payload parsing
    return const Batch(
      material: 'Sugar (Fine Grade)',
      batchNo: '#BATCH-2025-10-28',
      vendor: 'ABC Agro Supplies',
      grn: '#25-9982',
      regDate: '01/11/2025',
      mfgDate: '28/10/2025',
      expDate: '28/04/2026',
      sampleQty: '500 g',
    );
  }
}
