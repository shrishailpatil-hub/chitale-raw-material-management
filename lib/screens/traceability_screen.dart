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
              padding: EdgeInsets.only(left: 16, bottom: 8),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Ingredients Used:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))
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
                  leading: const Icon(Icons.subdirectory_arrow_right, size: 18, color: Colors.green),
                  title: Text("Batch: ${ing['rawMaterialBatchNo']}"), // e.g. SUG-001
                  subtitle: Text("Qty Used: ${ing['qtyUsed']} Kg"),
                ),
              )),
            const SizedBox(height: 10),
          ]
        ],
      ),
    );
  }
}