import 'package:flutter/material.dart';
import 'models/batch.dart';
import 'qc_review_screen.dart';
import 'services/batch_service.dart';

class PendingQCScreen extends StatelessWidget {
  const PendingQCScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Batch> pendingBatches =
    BatchService.getPendingQCBatches(); // ✅ SINGLE SOURCE

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C4175),
        title: const Text(
          'Pending QC',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Column(
        children: [
          // ---------------- SEARCH ----------------
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search material or batch #',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ---------------- LIST ----------------
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: pendingBatches.length,
              itemBuilder: (context, index) {
                return _PendingQCCard(batch: pendingBatches[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------
// QC CARD
// ----------------------------------------------------

class _PendingQCCard extends StatelessWidget {
  final Batch batch;

  const _PendingQCCard({required this.batch});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QCReviewScreen(
              material: batch.material,
              batch: batch.batchNo,
              vendor: batch.vendor,
              grn: batch.grn,
              regDate: batch.regDate,
              mfgDate: batch.mfgDate,
              expDate: batch.expDate,
              sampleQty: batch.sampleQty,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 8,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  batch.material,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                _statusBadge(),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              'Batch No: ${batch.batchNo}',
              style: const TextStyle(color: Colors.black, fontSize: 16),
            ),
            Text(
              'Vendor: ${batch.vendor}',
              style: const TextStyle(color: Colors.black, fontSize: 16),
            ),

            const Divider(height: 20),

            Text(
              'Reg Date: ${batch.regDate}',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD875),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Pending',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
