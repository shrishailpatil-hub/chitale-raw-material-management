import 'package:flutter/material.dart';
import '../models/batch.dart';
import '../services/database_helper.dart';
import 'scanner_screen.dart';

class IssueMaterialScreen extends StatefulWidget {
  const IssueMaterialScreen({super.key});

  @override
  State<IssueMaterialScreen> createState() => _IssueMaterialScreenState();
}

class _IssueMaterialScreenState extends State<IssueMaterialScreen> {
  // State
  List<Map<String, dynamic>> materials = [];
  String? selectedMaterial;

  Batch? fefoBatch; // The batch the system Suggests
  Batch? scannedBatch; // The batch the user Actually scanned

  final _qtyController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  // 1. Load Material Dropdown
  void _loadMaterials() async {
    final data = await DatabaseHelper.instance.getMaterials();
    setState(() {
      materials = data;
    });
  }

  // 2. Find FEFO Batch when material changes
  void _onMaterialSelected(String? val) async {
    setState(() {
      selectedMaterial = val;
      fefoBatch = null;
      scannedBatch = null;
      isLoading = true;
    });

    if (val != null) {
      final batches = await DatabaseHelper.instance.getBatchesForMaterial(val);
      if (batches.isNotEmpty) {
        setState(() {
          fefoBatch = batches.first; // The oldest one
        });
      }
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C4175),
        title: const Text('Issue Material (FEFO)', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // DROPDOWN
            const Text("Select Material to Issue:", style: TextStyle(fontSize: 16,color: Colors.black ,fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text("Choose Material"),
                  value: selectedMaterial,
                  style: TextStyle(color: Colors.black),
                  items: materials.map((m) {
                    return DropdownMenuItem<String>(
                      value: m['name'],
                      child: Text(m['name']),
                    );
                  }).toList(),
                  onChanged: _onMaterialSelected,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // FEFO SUGGESTION CARD
            if (fefoBatch != null)
              _infoCard(
                title: "Recommended Batch (FEFO)",
                color: Colors.blue.shade50,
                borderColor: Colors.blue,
                icon: Icons.lightbulb,
                children: [
                  Text("Batch: ${fefoBatch!.batchNo}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("Expiry: ${fefoBatch!.expDate}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  Text("Location: ${fefoBatch!.shelfLocation ?? 'Unknown'}", style: const TextStyle(fontWeight: FontWeight.w500)),
                  Text("Available: ${fefoBatch!.currentQty} ${fefoBatch!.unit}"),
                ],
              )
            else if (selectedMaterial != null && !isLoading)
              _infoCard(
                title: "Out of Stock",
                color: Colors.red.shade50,
                borderColor: Colors.red,
                icon: Icons.warning,
                children: [const Text("No approved batches found for this material.",style: TextStyle(color: Colors.black))],

              ),

            const SizedBox(height: 20),

            // SCAN SECTION
            if (fefoBatch != null) ...[
              const Divider(),
              const SizedBox(height: 10),

              // SCAN BUTTON OR RESULT
              if (scannedBatch == null)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text("SCAN BATCH TO PICK"),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1C4175)),
                    onPressed: _scanBatch,
                  ),
                )
              else
                _buildScanResult(),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildScanResult() {
    bool isMatch = scannedBatch!.batchNo == fefoBatch!.batchNo;

    return Column(
      children: [
        _infoCard(
          title: isMatch ? "Batch Verified" : "⚠️ Batch Mismatch (Not Oldest)",
          color: isMatch ? Colors.green.shade50 : Colors.orange.shade50,
          borderColor: isMatch ? Colors.green : Colors.orange,
          icon: isMatch ? Icons.check_circle : Icons.warning_amber,
          children: [
            Text("Scanned: ${scannedBatch!.batchNo}", style: const TextStyle(fontSize: 18,color: Colors.black ,fontWeight: FontWeight.bold)),
            Text("Available: ${scannedBatch!.currentQty} ${scannedBatch!.unit}"),
            if (!isMatch)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text("You are not picking the oldest batch. Manager approval required.", style: TextStyle(color: Colors.red, fontSize: 12)),
              ),
          ],
        ),

        const SizedBox(height: 20),

        // ISSUE QTY INPUT
        TextField(
          controller: _qtyController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Quantity to Issue",
            border: OutlineInputBorder(),
            suffixText: "Kg", // Hardcoded unit for now
          ),
        ),

        const SizedBox(height: 20),

        // CONFIRM BUTTON
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isMatch ? const Color(0xFF2E7CCC) : Colors.orange,
            ),
            onPressed: () => _confirmIssue(isMatch),
            child: Text(
              isMatch ? "CONFIRM ISSUE" : "REQUEST OVERRIDE & ISSUE",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- LOGIC ----------------

  void _scanBatch() async {
    final code = await Navigator.push<String>(context, MaterialPageRoute(builder: (_) => const ScannerScreen()));

    if (code != null) {
      final batchData = await DatabaseHelper.instance.getBatch(code);
      if (batchData != null) {
        final batch = Batch.fromMap(batchData);

        // Basic Validations
        if (batch.material != selectedMaterial) {
          _showError("Wrong Material! This is ${batch.material}");
          return;
        }
        if (batch.status != BatchStatus.approved) {
          _showError("This batch is NOT Approved (Status: ${batch.status.name})");
          return;
        }

        setState(() {
          scannedBatch = batch;
        });
      } else {
        _showError("Batch not found in database.");
      }
    }
  }

  void _confirmIssue(bool isMatch) async {
    double qty = double.tryParse(_qtyController.text) ?? 0;

    if (qty <= 0) {
      _showError("Enter a valid quantity");
      return;
    }
    if (qty > scannedBatch!.currentQty) {
      _showError("Not enough stock! Max available: ${scannedBatch!.currentQty}");
      return;
    }

    // IF MISMATCH -> ASK FOR PIN
    if (!isMatch) {
      bool approved = await _showManagerOverrideDialog();
      if (!approved) return;
    }

    // UPDATE DB
    await DatabaseHelper.instance.issueBatchQty(scannedBatch!.batchNo, qty);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Issued $qty Kg successfully!")));
      Navigator.pop(context); // Go back to dashboard
    }
  }

  Future<bool> _showManagerOverrideDialog() async {
    final pinController = TextEditingController();
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Manager Override"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Please enter Manager PIN to bypass FEFO rules."),
            TextField(controller: pinController, obscureText: true, decoration: const InputDecoration(labelText: "PIN")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          ElevatedButton(
              onPressed: () {
                if (pinController.text == "1234") {
                  Navigator.pop(ctx, true);
                } else {
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text("Wrong PIN"), backgroundColor: Colors.red));
                }
              },
              child: const Text("Approve")
          ),
        ],
      ),
    ) ?? false;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  Widget _infoCard({required String title, required Color color, required Color borderColor, required IconData icon, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, color: borderColor), const SizedBox(width: 8), Text(title, style: TextStyle(color: borderColor, fontWeight: FontWeight.bold, fontSize: 16))]),
        const Divider(),
        ...children,
      ]),
    );
  }
}