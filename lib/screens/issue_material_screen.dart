import 'package:flutter/material.dart';
import '../models/batch.dart';
import '../services/database_helper.dart';
import 'scanner_screen.dart';
import 'manager_override_screen.dart';

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

  void _loadMaterials() async {
    final data = await DatabaseHelper.instance.getMaterials();
    setState(() {
      materials = data;
    });
  }

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
            const Text("Select Material to Issue:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text("Choose Material"),
                  value: selectedMaterial,
                  items: materials.map((m) {
                    return DropdownMenuItem<String>(
                      value: m['name'],
                      child: Text(m['name'], style: const TextStyle(color: Colors.black)),
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
                borderColor: Colors.blue.shade800, // Darker border
                icon: Icons.lightbulb,
                textColor: Colors.blue.shade900,   // Dark Text
                children: [
                  Text("Batch: ${fefoBatch!.batchNo}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                  Text("Expiry: ${fefoBatch!.expDate}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  Text("Location: ${fefoBatch!.shelfLocation ?? 'Unknown'}", style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
                  Text("Available: ${fefoBatch!.currentQty} ${fefoBatch!.unit}", style: const TextStyle(color: Colors.black)),
                ],
              )
            else if (selectedMaterial != null && !isLoading)
              _infoCard(
                title: "Out of Stock",
                color: Colors.red.shade50,
                borderColor: Colors.red,
                icon: Icons.warning,
                textColor: Colors.red.shade900,
                children: [
                  const Text("No approved batches found for this material.", style: TextStyle(color: Colors.black)),
                ],
              ),

            const SizedBox(height: 20),

            // SCAN SECTION
            if (fefoBatch != null) ...[
              const Divider(),
              const SizedBox(height: 10),

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
          borderColor: isMatch ? Colors.green.shade800 : Colors.orange.shade800,
          icon: isMatch ? Icons.check_circle : Icons.warning_amber,
          textColor: isMatch ? Colors.green.shade900 : Colors.deepOrange.shade900,
          children: [
            Text("Scanned: ${scannedBatch!.batchNo}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            Text("Available: ${scannedBatch!.currentQty} ${scannedBatch!.unit}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
            if (!isMatch)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text("You are not picking the oldest batch. Manager approval required.", style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold)),
              ),
          ],
        ),

        const SizedBox(height: 20),

        // ISSUE QTY INPUT (Optional now, mostly for record keeping)
        TextField(
          controller: _qtyController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.black),
          decoration: const InputDecoration(
            labelText: "Quantity to Move (Kg)",
            border: OutlineInputBorder(),
            suffixText: "Kg",
            labelStyle: TextStyle(color: Colors.black87),
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
      _showError("Please enter a valid quantity");
      return;
    }

    // STRICT STOCK CHECK
    if (qty > scannedBatch!.currentQty) {
      _showError("⚠️ NOT ENOUGH STOCK!\nYou have ${scannedBatch!.currentQty} Kg available.");
      return;
    }

    String? overrideReason;

    // IF MISMATCH -> GO TO OVERRIDE SCREEN
    if (!isMatch) {
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ManagerOverrideScreen(
                materialName: scannedBatch!.material,
                batchNo: scannedBatch!.batchNo,
                qty: qty,
              )
          )
      );

      if (result == null || result['authorized'] != true) {
        return;
      }

      overrideReason = result['reason'];
    }

    // ✅ THE BUG FIX: MARK AS ISSUED (isIssued = 1)
    // We do NOT deduct stock here. We just move it to the floor.
    // Ramesh (Worker) will deduct it when he uses it.

    final db = await DatabaseHelper.instance.database;
    await db.update(
        'batches',
        {'isIssued': 1},
        where: 'batchNo = ?',
        whereArgs: [scannedBatch!.batchNo]
    );

    // 2. SAVE OVERRIDE LOG (If applicable)
    if (overrideReason != null) {
      await DatabaseHelper.instance.insertOverrideLog({
        'batchNo': scannedBatch!.batchNo,
        'material': scannedBatch!.material,
        'qtyRequested': qty,
        'managerName': 'Manager (PIN)',
        'reason': overrideReason,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Batch Moved to Factory Floor!")));
      Navigator.pop(context);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  Widget _infoCard({
    required String title,
    required Color color,
    required Color borderColor,
    required IconData icon,
    required Color textColor,
    required List<Widget> children
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor)
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
                children: [
                  Icon(icon, color: borderColor),
                  const SizedBox(width: 8),
                  Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16))
                ]
            ),
            Divider(color: borderColor.withOpacity(0.5)),
            ...children,
          ]
      ),
    );
  }
}