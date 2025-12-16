import 'package:flutter/material.dart';

class InboundEntryScreen extends StatefulWidget {
  const InboundEntryScreen({super.key});

  @override
  State<InboundEntryScreen> createState() => _InboundEntryScreenState();
}

class _InboundEntryScreenState extends State<InboundEntryScreen> {
  final _vendorController = TextEditingController();
  final _vehicleController = TextEditingController();
  final _dateController = TextEditingController();

  final _materialController = TextEditingController();
  final _batchController = TextEditingController();
  final _mfgDateController = TextEditingController();
  final _expDateController = TextEditingController();
  final _totalQtyController = TextEditingController();
  final _sampleQtyController = TextEditingController();

  @override
  void dispose() {
    _vendorController.dispose();
    _vehicleController.dispose();
    _dateController.dispose();
    _materialController.dispose();
    _batchController.dispose();
    _mfgDateController.dispose();
    _expDateController.dispose();
    _totalQtyController.dispose();
    _sampleQtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C4175),
        title: const Text(
          'Inbound Entry (GRN)',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Shipment Details
            _sectionTitle('Shipment Details'),
            _card(
              children: [
                _input('Vendor', _vendorController),
                const SizedBox(height: 12),
                _input('Vehicle Number', _vehicleController),
                const SizedBox(height: 12),
                _dateInput('Date', _dateController),
              ],
            ),

            const SizedBox(height: 24),

            /// Batch Details
            _sectionTitle('Batch Details'),
            _card(
              children: [
                _input('Material', _materialController),
                const SizedBox(height: 12),
                _input('Batch No', _batchController),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _dateInput('Mfg Date', _mfgDateController)),
                    const SizedBox(width: 12),
                    Expanded(child: _dateInput('Exp Date', _expDateController)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _input('Total Qty (Kg)', _totalQtyController, isNumber: true)),
                    const SizedBox(width: 12),
                    Expanded(child: _input('Sample Qty (g)', _sampleQtyController, isNumber: true)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 32),

            /// Generate Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7CCC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _onGeneratePressed,
                child: const Text(
                  'GENERATE GRN & PRINT QR',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ---------------- UI Helpers ----------------

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  Widget _input(String label, TextEditingController controller,
      {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,

      // 👇 THIS LINE FIXES THE VISIBILITY
      style: const TextStyle(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),

      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFBBBBBB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2E7CCC), width: 2),
        ),
      ),
    );

  }

  Widget _dateInput(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime(2035),
          initialDate: DateTime.now(),
        );

        if (date != null) {
          controller.text =
          '${date.day}/${date.month}/${date.year}';
        }
      },
    );
  }

  /// ---------------- Logic ----------------

  void _onGeneratePressed() {
    // For now: just verify data is captured
    debugPrint('Vendor: ${_vendorController.text}');
    debugPrint('Vehicle: ${_vehicleController.text}');
    debugPrint('Material: ${_materialController.text}');
    debugPrint('Batch: ${_batchController.text}');
    debugPrint('Total Qty: ${_totalQtyController.text}');
    debugPrint('Sample Qty: ${_sampleQtyController.text}');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('GRN Generated (mock)')),
    );
  }
}
