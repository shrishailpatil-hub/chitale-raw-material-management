import 'package:flutter/material.dart';
import '../models/batch.dart';
import '../services/qc_service.dart';
import 'qc_review_screen.dart';

class PendingQCScreen extends StatelessWidget {
  const PendingQCScreen({super.key});

  @override
  Widget build(BuildContext context) {
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

          // ---------------- REACTIVE LIST ----------------
          Expanded(
            child: ValueListenableBuilder<List<Batch>>(
              // ✅ THIS IS THE KEY: Listen to the Service directly
              valueListenable: QCService().pendingBatchesNotifier,
              builder: (context, batches, child) {

                if (batches.isEmpty) {
                  return const Center(
                    child: Text(
                      'No pending QC batches 🎉',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: batches.length,
                  itemBuilder: (context, index) {
                    final batch = batches[index];
                    return _PendingQCCard(batch: batch);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- QC CARD ----------------
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
            builder: (_) => QCReviewScreen(batch: batch),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    batch.material,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD875),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Pending',
                    style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Batch No: ${batch.batchNo}', style: const TextStyle(color: Colors.black)),
          ],
        ),
      ),
    );
  }
}