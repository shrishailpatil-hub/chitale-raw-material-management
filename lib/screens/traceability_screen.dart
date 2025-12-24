import 'package:flutter/material.dart';
import '../services/database_helper.dart';

class TraceabilityScreen extends StatefulWidget {
  const TraceabilityScreen({super.key});

  @override
  State<TraceabilityScreen> createState() => _TraceabilityScreenState();
}

class _TraceabilityScreenState extends State<TraceabilityScreen> {
  List<Map<String, dynamic>> productionRuns = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final data = await DatabaseHelper.instance.getProductionHistory();
    setState(() {
      productionRuns = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C4175),
        title: const Text('Traceability Review', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : productionRuns.isEmpty
          ? const Center(child: Text("No Production Data Found"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: productionRuns.length,
        itemBuilder: (context, index) {
          final run = productionRuns[index];
          return _ProductionRunCard(run: run);
        },
      ),
    );
  }
}

class _ProductionRunCard extends StatefulWidget {
  final Map<String, dynamic> run;
  const _ProductionRunCard({required this.run});

  @override
  State<_ProductionRunCard> createState() => _ProductionRunCardState();
}

class _ProductionRunCardState extends State<_ProductionRunCard> {
  bool expanded = false;
  List<Map<String, dynamic>> ingredients = [];

  void _toggleExpand() async {
    if (!expanded && ingredients.isEmpty) {
      // Load ingredients only when expanded (Lazy Loading)
      final data = await DatabaseHelper.instance.getIngredientsForBatch(widget.run['finalBatchNo']);
      setState(() => ingredients = data);
    }
    setState(() => expanded = !expanded);
  }

  // ✅ NEW FUNCTION: Fetch & Show Batch Details
  void _showBatchDetails(String batchNo) async {
    // 1. Fetch Basic Details
    final batchData = await DatabaseHelper.instance.getBatch(batchNo);

    // 2. Fetch QC Details (New!)
    final qcData = await DatabaseHelper.instance.getLatestQCRecord(batchNo);

    if (!mounted) return;

    if (batchData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Batch Details Not Found"), backgroundColor: Colors.red),
      );
      return;
    }

    // 3. Show Dialog
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          children: [
            const Icon(Icons.verified_user, size: 40, color: Colors.blue),
            const SizedBox(height: 10),
            Text("Batch: $batchNo", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sectionHeader("Inbound Details"),
              _detailRow("Material", batchData['material']),
              _detailRow("Vendor", batchData['vendor']),
              _detailRow("GRN", batchData['grn']),
              _detailRow("Received", batchData['regDate']),

              const Divider(),
              _sectionHeader("Quality Control"),
              if (qcData != null) ...[
                _detailRow("Status", qcData['status'].toString().toUpperCase()),
                _detailRow("Approved By", qcData['reviewedBy']), // ✅ Shows who clicked Approve
                _detailRow("QC Date", qcData['timestamp'].toString().split('T')[0]),
                if (qcData['remarks'].toString().isNotEmpty)
                  _detailRow("Remarks", qcData['remarks']),
              ] else ...[
                const Text("No QC Record Found (Auto-Approved?)", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
              ],

              const Divider(),
              _sectionHeader("Inventory"),
              _detailRow("Original Qty", "${batchData['initialQty']} ${batchData['unit']}"),
              _detailRow("Current Qty", "${batchData['currentQty']} ${batchData['unit']}"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.0)),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            onTap: _toggleExpand,
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFE3F2FD),
              child: Icon(Icons.inventory_2, color: Color(0xFF1C4175)),
            ),
            title: Text(widget.run['productName'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Batch: ${widget.run['finalBatchNo']}"),
                Text("By: ${widget.run['workerId']} • ${widget.run['timestamp'].toString().split('T')[0]}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            trailing: Icon(expanded ? Icons.expand_less : Icons.expand_more),
          ),

          if (expanded) ...[
            const Divider(),
            const Padding(
              padding: EdgeInsets.only(left: 16, bottom: 8, top: 8),
              child: Align(
                  alignment: Alignment.centerLeft,
                  // Changed to Black/Blue because White on White is invisible
                  child: Text("Ingredients Used (Tap for Details):",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0996F3), fontSize: 13))
              ),
            ),

            if (ingredients.isEmpty)
              const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())
            else
              ...ingredients.map((ing) => Container(
                color: Colors.grey.shade50,
                child: ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  // ✅ ADDED ON TAP
                  onTap: () => _showBatchDetails(ing['rawMaterialBatchNo']),
                  leading: const Icon(Icons.subdirectory_arrow_right, size: 18, color: Colors.green),
                  title: Text(
                    "Batch: ${ing['rawMaterialBatchNo']}",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, decoration: TextDecoration.underline), // Underline suggests clickable
                  ),
                  subtitle: Text("Qty Used: ${ing['qtyUsed']} Kg", style: const TextStyle(color: Colors.black87)),
                  trailing: const Icon(Icons.info, size: 16, color: Colors.grey),
                ),
              )),
            const SizedBox(height: 10),
          ]
        ],
      ),
    );
  }
}