import 'package:flutter/material.dart';

class ManagerOverrideScreen extends StatefulWidget {
  final String materialName;
  final String batchNo;
  final double qty;

  const ManagerOverrideScreen({
    super.key,
    required this.materialName,
    required this.batchNo,
    required this.qty,
  });

  @override
  State<ManagerOverrideScreen> createState() => _ManagerOverrideScreenState();
}

class _ManagerOverrideScreenState extends State<ManagerOverrideScreen> {
  final _pinController = TextEditingController();
  final _reasonController = TextEditingController(); // For "Other" reason

  // Standard Reasons (Standardization is key for industry)
  final List<String> reasons = [
    "Quality Issue (Wet/Damaged)",
    "Customer Specific Request",
    "Lab Sampling Required",
    "Old Batch Inaccessible",
    "Other"
  ];
  String? selectedReason;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F0), // Red tint = Warning
      appBar: AppBar(
        title: const Text("Manager Override Required"),
        backgroundColor: Colors.red.shade900,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, null), // Cancel
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ⚠️ WARNING CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade300, width: 2),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red.shade700, size: 40),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "FEFO Violation Detected",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "You are attempting to issue ${widget.batchNo} which is NOT the oldest batch.",
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 🔒 AUTH FORM
            const Text("Authorization", style: TextStyle(fontSize: 20, color: Colors.black,fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                labelText: "Manager PIN",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline,color: Colors.black,),
              ),
            ),

            const SizedBox(height: 20),

            // REASON DROPDOWN
            DropdownButtonFormField<String>(
              dropdownColor: Colors.white,
              decoration: const InputDecoration(
                labelText: "Reason for Override",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.comment,color: Colors.black,),
              ),
              value: selectedReason,
              items: reasons.map((r) => DropdownMenuItem(value: r, child: Text(r,style: TextStyle(color: Colors.black),))).toList(),
              onChanged: (val) => setState(() => selectedReason = val),
            ),

            // "OTHER" TEXT FIELD (Shows only if "Other" is selected)
            if (selectedReason == "Other") ...[
              const SizedBox(height: 15),
              TextField(
                controller: _reasonController,
                style: TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  labelText: "Specify Reason",
                  border: OutlineInputBorder(),
                ),
              ),
            ],

            const SizedBox(height: 40),

            // AUTHORIZE BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade800,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.gavel),
                label: const Text("AUTHORIZE & LOG", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                onPressed: _authorize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _authorize() {
    // 1. Check PIN (Hardcoded for Phase 1)
    if (_pinController.text != "1234") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid Manager PIN"), backgroundColor: Colors.red));
      return;
    }

    // 2. Validate Reason
    if (selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a reason"), backgroundColor: Colors.red));
      return;
    }

    // 3. Get Final Text
    String finalReason = selectedReason == "Other" ? _reasonController.text : selectedReason!;
    if (finalReason.isEmpty) return;

    // 4. Return Success
    Navigator.pop(context, {
      'authorized': true,
      'reason': finalReason,
      'manager': 'Manager (PIN)', // In Phase 3, we can use specific Manager IDs
    });
  }
}