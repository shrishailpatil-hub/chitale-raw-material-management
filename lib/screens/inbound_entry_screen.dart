import 'package:flutter/material.dart';
import 'dart:math';
import '../models/batch.dart';
import '../services/database_helper.dart';
import '../models/user.dart';

class InboundEntryScreen extends StatefulWidget {
  final User currentUser;
  const InboundEntryScreen({super.key, required this.currentUser});

  @override
  State<InboundEntryScreen> createState() => _InboundEntryScreenState();
}

class _InboundEntryScreenState extends State<InboundEntryScreen> {
  final _vendorController = TextEditingController();
  final _vehicleController = TextEditingController();
  final _dateController = TextEditingController();
  final _batchController = TextEditingController();
  final _mfgDateController = TextEditingController();
  final _expDateController = TextEditingController();
  final _totalQtyController = TextEditingController();
  final _sampleQtyController = TextEditingController();

  // ✅ New Dropdown State
  List<Map<String, dynamic>> materials = [];
  String? selectedMaterial;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C4175),
        title: const Text('Inbound Entry (GRN)', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _sectionTitle('Shipment Details'),
            _card(children: [
              _input('Vendor', _vendorController),
              const SizedBox(height: 12),
              _input('Vehicle Number', _vehicleController),
              const SizedBox(height: 12),
              _dateInput('Date', _dateController),
            ]),
            const SizedBox(height: 24),
            _sectionTitle('Batch Details'),
            _card(children: [
              // ✅ DROPDOWN REPLACES TEXT FIELD
              DropdownButtonFormField<String>(
                dropdownColor: Colors.white,
                decoration: InputDecoration(
                    labelText: 'Material',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
                ),
                value: selectedMaterial,
                // Force Selected Text to Black
                style: const TextStyle(color: Colors.black, fontSize: 16),
                // Force Arrow Icon to Black
                icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                items: materials.map((m) {
                  return DropdownMenuItem<String>(
                    value: m['name'],
                    child: Text(m['name'], style: const TextStyle(color: Colors.black)),
                  );
                }).toList(),
                onChanged: (val) => setState(() => selectedMaterial = val),
              ),
              const SizedBox(height: 12),
              _input('Batch No', _batchController),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _dateInput('Mfg Date', _mfgDateController)),
                const SizedBox(width: 12),
                Expanded(child: _dateInput('Exp Date', _expDateController)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _input('Total Qty (Kg)', _totalQtyController, isNumber: true)),
                const SizedBox(width: 12),
                Expanded(child: _input('Sample Qty (g)', _sampleQtyController, isNumber: true)),
              ]),
            ]),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7CCC),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                onPressed: _onGeneratePressed,
                child: const Text('GENERATE GRN & SAVE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onGeneratePressed() async {
    // ✅ Check Dropdown
    if (selectedMaterial == null || _batchController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select Material and enter Batch No'), backgroundColor: Colors.red));
      return;
    }

    double totalQty = double.tryParse(_totalQtyController.text) ?? 0.0;
    final randomId = Random().nextInt(9000) + 1000;
    final generatedGRN = 'GRN-2025-$randomId';

    final newBatch = Batch(
      material: selectedMaterial!, // ✅ Uses Standard Name
      batchNo: _batchController.text,
      vendor: _vendorController.text,
      grn: generatedGRN,
      regDate: _dateController.text.isEmpty ? 'Today' : _dateController.text,
      mfgDate: _mfgDateController.text,
      expDate: _expDateController.text,
      sampleQty: _sampleQtyController.text.isEmpty ? 'N/A' : '${_sampleQtyController.text} g',
      initialQty: totalQty,
      currentQty: totalQty,
      unit: 'Kg',
    );

    // ✅ CRITICAL FIX: Add "Inbound Manager" and "isIssued" before saving
    final batchMap = newBatch.toMap();
    batchMap['inboundManager'] = widget.currentUser.name; // Save who created it
    batchMap['isIssued'] = 0; // Default: Not Issued (0)

    await DatabaseHelper.instance.insertBatch(batchMap);

    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Success!"),
          content: Text("Batch Saved Successfully.\nGRN: $generatedGRN"),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text("Done"),
            )
          ],
        ),
      );
    }
  }

  Widget _sectionTitle(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
          alignment: Alignment.centerLeft,
          child: Text(text, style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w700))
      )
  );

  Widget _card({required List<Widget> children}) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(children: children)
  );

  Widget _input(String label, TextEditingController controller, {bool isNumber = false}) => TextField(
    controller: controller,
    style: const TextStyle(color: Colors.black), // 👈 THIS MAKES TEXT BLACK
    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );

  Widget _dateInput(String label, TextEditingController controller) => TextField(
      controller: controller,
      style: const TextStyle(color: Colors.black), // 👈 THIS MAKES TEXT BLACK
      readOnly: true,
      decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          suffixIcon: const Icon(Icons.calendar_today)
      ),
      onTap: () async {
        DateTime? date = await showDatePicker(
            context: context,
            firstDate: DateTime(2020),
            lastDate: DateTime(2035),
            initialDate: DateTime.now()
        );
        if (date != null) controller.text = '${date.day}/${date.month}/${date.year}';
      }
  );
}