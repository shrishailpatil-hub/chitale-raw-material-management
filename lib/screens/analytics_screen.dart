import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/database_helper.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  // Data for Charts
  List<Map<String, dynamic>> inventoryData = [];
  List<Map<String, dynamic>> productionData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  void _loadAnalytics() async {
    final inv = await DatabaseHelper.instance.getInventoryStats();
    final prod = await DatabaseHelper.instance.getProductionStats();

    setState(() {
      inventoryData = inv;
      productionData = prod;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Business Intelligence", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 1. INVENTORY BAR CHART
            const Text("Current Stock Levels (Kg)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 20),
            Container(
              height: 300,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: inventoryData.isEmpty
                  ? const Center(child: Text("No Stock Data"))
                  : BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxY(),
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,

                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < inventoryData.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                inventoryData[index]['material'].toString().substring(0, 3).toUpperCase(),

                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),

                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),

                            style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade300, strokeWidth: 1),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(bottom: BorderSide(color: Colors.black, width: 1), left: BorderSide(color: Colors.black, width: 1)),
                  ),
                  barGroups: inventoryData.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: (entry.value['totalQty'] as num).toDouble(),
                          color: const Color(0xFF069DFA),
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                        )
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 2. PRODUCTION PIE CHART
            const Text("Production Mix (Batches)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 20),
            Container(
              height: 300,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: productionData.isEmpty
                  ? const Center(child: Text("No Production Data"))
                  : PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: productionData.asMap().entries.map((entry) {
                    final isEven = entry.key % 2 == 0;
                    return PieChartSectionData(
                      color: isEven ? const Color(0xFF2E7CCC) : Colors.orange,
                      value: (entry.value['batchCount'] as int).toDouble(),
                      title: '${entry.value['batchCount']}',
                      radius: 60,
                      titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    );
                  }).toList(),
                ),
              ),
            ),

            // LEGEND FOR PIE CHART
            if (productionData.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: productionData.asMap().entries.map((e) =>
                      ListTile(
                        leading: Icon(Icons.circle, color: e.key % 2 == 0 ? const Color(0xFF2E7CCC) : Colors.orange),
                        title: Text(e.value['productName'], style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        trailing: Text("${e.value['batchCount']} Batches", style: const TextStyle(color: Colors.black)),
                        dense: true,
                      )
                  ).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  double _getMaxY() {
    if (inventoryData.isEmpty) return 100;
    double max = 0;
    for (var item in inventoryData) {
      double val = (item['totalQty'] as num).toDouble();
      if (val > max) max = val;
    }
    return max * 1.2;
  }
}