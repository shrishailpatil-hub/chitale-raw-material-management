import 'package:flutter/material.dart';
import 'dart:math';
import '../services/database_helper.dart';
import '../models/batch.dart';
import 'scanner_screen.dart';

class ProductionEntryScreen extends StatefulWidget {
  final String workerName; // ✅ Accept Name
  const ProductionEntryScreen({super.key, required this.workerName});

  @override
  State<ProductionEntryScreen> createState() => _ProductionEntryScreenState();
}

class _ProductionEntryScreenState extends State<ProductionEntryScreen> {
  // State
  List<Map<String, dynamic>> products = [];
  String? selectedProduct;
  final _finalBatchController = TextEditingController();

  // List of raw materials added to this mix
  List<Map<String, dynamic>> addedIngredients = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _generateBatchId();
  }

  void _loadProducts() async {
    final data = await DatabaseHelper.instance.getFinishedGoods();
    setState(() => products = data);
  }

  void _generateBatchId() {
    // Auto-generate a batch ID for the finished good (e.g., FG-2025-999)
    final randomId = Random().nextInt(9000) + 1000;
    _finalBatchController.text = "FG-2025-$randomId";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C4175),
        title: const Text('Production Entry', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. PRODUCT DETAILS CARD
            _sectionTitle("Finished Product Details"),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    dropdownColor: Colors.white,
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                    decoration: InputDecoration(
                        labelText: 'Select Product',
                        labelStyle: const TextStyle(color: Colors.black54),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
                    ),
                    value: selectedProduct,
                    items: products.map((p) {
                      return DropdownMenuItem<String>(
                          value: p['name'],
                          child: Text(p['name'], style: const TextStyle(color: Colors.black))
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => selectedProduct = val),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _finalBatchController,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: 'Final Batch ID',
                      labelStyle: const TextStyle(color: Colors.black54),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. INGREDIENTS LIST
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionTitle("Raw Materials Used"),
                ElevatedButton.icon(
                  onPressed: _scanIngredient,
                  icon: const Icon(Icons.qr_code_scanner, size: 18),
                  label: const Text("Scan Bag"),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7CCC)),
                )
              ],
            ),

            const SizedBox(height: 8),

            if (addedIngredients.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12)
                ),
                child: const Center(child: Text("No ingredients scanned yet.", style: TextStyle(color: Colors.grey))),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: addedIngredients.length,
                itemBuilder: (ctx, index) {
                  final item = addedIngredients[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: const Icon(Icons.inventory_2, color: Colors.blue),
                      title: Text(item['material'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("Batch: ${item['batchNo']}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("${item['qty']} Kg", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => setState(() => addedIngredients.removeAt(index)),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 40),

            // 3. SUBMIT BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: (selectedProduct != null && addedIngredients.isNotEmpty)
                      ? const Color(0xFF1C4175)
                      : Colors.grey,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: (selectedProduct != null && addedIngredients.isNotEmpty)
                    ? _submitProduction
                    : null,
                child: const Text("CONFIRM PRODUCTION", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- LOGIC ----------------

  void _scanIngredient() async {
    // 1. Scan QR
    final code = await Navigator.push<String>(context, MaterialPageRoute(builder: (_) => const ScannerScreen()));
    if (code == null) return;

    // 2. Lookup in DB
    final batchMap = await DatabaseHelper.instance.getBatch(code);
    if (batchMap == null) {
      _showError("Batch not found!");
      return;
    }

    final batch = Batch.fromMap(batchMap);

    // 3. Check Logic (Must be Approved & Have Stock)
    if (batch.status != BatchStatus.approved) {
      _showError("Batch NOT Approved!");
      return;
    }
    if (batch.currentQty <= 0) {
      _showError("Batch is Empty!");
      return;
    }

    // 4. Ask for Quantity
    _showQtyDialog(batch);
  }

  void _showQtyDialog(Batch batch) {
    final qtyController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Use ${batch.material}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Available: ${batch.currentQty} ${batch.unit}"),
            const SizedBox(height: 10),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Quantity to Use (Kg)", border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              double usedQty = double.tryParse(qtyController.text) ?? 0;
              if (usedQty > 0 && usedQty <= batch.currentQty) {
                setState(() {
                  addedIngredients.add({
                    'batchNo': batch.batchNo,
                    'material': batch.material,
                    'qty': usedQty
                  });
                });
                Navigator.pop(ctx);
              } else {
                _showError("Invalid Quantity");
              }
            },
            child: const Text("Add"),
          )
        ],
      ),
    );
  }

  void _submitProduction() async {
    // 1. Loop through ingredients and deduct stock + save log
    for (var item in addedIngredients) {
      // 1. Deduct Stock
      await DatabaseHelper.instance.issueBatchQty(item['batchNo'], item['qty']);

      // 2. Save Log with WORKER ID
      await DatabaseHelper.instance.insertProductionLog({
        'finalBatchNo': _finalBatchController.text,
        'productName': selectedProduct,
        'rawMaterialBatchNo': item['batchNo'],
        'qtyUsed': item['qty'],
        'timestamp': DateTime.now().toIso8601String(),
        'workerId': widget.workerName, // SAVING THE LOG!
      });
    }

    // 2. Show Success
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Production Logged Successfully!")));
      Navigator.pop(context);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  Widget _sectionTitle(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold))
  );
}