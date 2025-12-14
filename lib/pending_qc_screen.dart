import 'package:flutter/material.dart';

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
                hintStyle: TextStyle(color: Colors.grey.shade600),
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
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: const [
                _PendingQCCard(
                  material: 'Whole Wheat Flour',
                  batch: '#BATCH-2025-10-28',
                  vendor: 'ABC Agro Supplies',
                  regDate: '01/11/2025',
                ),
                _PendingQCCard(
                  material: 'Sugar (Fine Refine)',
                  batch: '#BATCH-2025-12-30',
                  vendor: 'Sweetener Solution Ltd',
                  regDate: '15/11/2025',
                ),
                _PendingQCCard(
                  material: 'Milk Powder',
                  batch: '#BATCH-2025-14-10',
                  vendor: 'ABC Agro Supplies',
                  regDate: '20/11/2025',
                ),
              ],
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
  final String material;
  final String batch;
  final String vendor;
  final String regDate;

  const _PendingQCCard({
    required this.material,
    required this.batch,
    required this.vendor,
    required this.regDate,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Open QC for $batch')),
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
                  material,
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
              'Batch No: $batch',
              style: const TextStyle(fontSize: 16,color: Colors.black),
            ),
            Text(
              'Vendor: $vendor',
              style: const TextStyle(fontSize: 16,color: Colors.black),
            ),

            const Divider(height: 20),

            Text(
              'Reg Date: $regDate',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
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
