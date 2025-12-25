import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/statistik_model.dart';
import '../services/statistik_servis.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DashboardService _service = DashboardService();

  bool isLoading = true;
  String? errorMessage;
  DashboardData? dashboardData;

  DateTime? startDate;
  DateTime? endDate;

  // Warna tema (Konsisten dengan halaman lain)
  final Color _primaryColor = const Color(0xFF0D1F3C); // Dark Blue
  final Color _accentColor = const Color(0xFF27AE60); // Green
  final Color _softGreenBg = const Color(0xFFEAF9F2); // Light Green Background

  // Formatter uang (Dolar)
  final currencyFormatter = NumberFormat.compactCurrency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 1,
  );

  // Formatter angka biasa (untuk quantity)
  final numberFormatter = NumberFormat.decimalPattern('en_US');

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await _service.getDashboardData(
        startDate: startDate,
        endDate: endDate,
      );
      setState(() {
        dashboardData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
      initialDateRange: (startDate != null && endDate != null)
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _primaryColor,
              onPrimary: Colors.white,
              onSurface: _primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
      fetchData();
    }
  }

  void _resetFilter() {
    setState(() {
      startDate = null;
      endDate = null;
    });
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Dashboard BI",
          style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                startDate == null ? Icons.filter_alt_off : Icons.filter_alt,
                color: _primaryColor,
              ),
              onPressed: _pickDateRange,
            ),
          ),
          if (startDate != null)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: IconButton(
                icon: const Icon(Icons.refresh, color: Colors.red),
                onPressed: _resetFilter,
              ),
            ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: _accentColor))
          : errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : _buildDashboard(),
    );
  }

  Widget _buildDashboard() {
    if (dashboardData == null) return const Center(child: Text("Data Kosong"));

    final summary = dashboardData!.summary;
    final charts = dashboardData!.charts;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================
          // 1. BARIS PERTAMA: Total Sales (Besar)
          // ============================================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _primaryColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _primaryColor.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Sales",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.attach_money,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  currencyFormatter.format(summary.totalSales),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ============================================
          // 2. BARIS KEDUA: Transaksi & Quantity
          // ============================================
          Row(
            children: [
              Expanded(
                child: _kpiCardSmall(
                  "Transaksi",
                  summary.totalTransactions.toString(),
                  Icons.receipt_long_rounded,
                  Colors.orange,
                  const Color(0xFFFFF8E1),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _kpiCardSmall(
                  "Quantity",
                  summary.totalQuantity.toString(),
                  Icons.shopping_basket_rounded,
                  Colors.blue,
                  const Color(0xFFE3F2FD),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ============================================
          // 3. BARIS KETIGA: Customer & Produk
          // ============================================
          Row(
            children: [
              Expanded(
                child: _kpiCardSmall(
                  "Customer",
                  summary.totalCustomers.toString(),
                  Icons.people_alt_rounded,
                  Colors.purple,
                  const Color(0xFFF3E5F5),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _kpiCardSmall(
                  "Produk",
                  summary.totalProducts.toString(),
                  Icons.inventory_2_rounded,
                  Colors.teal,
                  const Color(0xFFE0F2F1),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 24),

          // CHARTS SECTION
          _title("Tren Penjualan Bulanan"),
          _chartContainer(_lineChart(charts.monthlyTrend)),

          const SizedBox(height: 24),

          _title("Tren Penjualan Kuartalan"),
          _chartContainer(_barChart(charts.quarterlyTrend)),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _title("Kategori"),
                    _chartContainer(
                      _pieChart(charts.salesByCategory, summary.totalSales),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _title("Segmen"),
                    _chartContainer(
                      _pieChart(charts.salesBySegment, summary.totalSales),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          _title("Metode Pengiriman Populer"),
          _chartContainer(_shippingChart(charts.shippingPerformance)),

          const SizedBox(height: 24),

          _title("Top 5 Produk (Quantity)"),
          // Menggunakan isCurrency: false untuk quantity
          _listContainer(_listChart(charts.topProducts, isCurrency: false)),

          const SizedBox(height: 24),

          _title("Top 5 Kota (Sales)"),
          _listContainer(_listChart(charts.topCities)),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // WIDGET HELPERS

  Widget _kpiCardSmall(
    String title,
    String value,
    IconData icon,
    Color iconColor,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _chartContainer(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _listContainer(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _title(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: _primaryColor,
        ),
      ),
    );
  }

  // =========================================================
  // CHART WIDGETS
  // =========================================================

  Widget _lineChart(List<ChartItem> data) {
    if (data.isEmpty) {
      return const SizedBox(height: 50, child: Center(child: Text("No Data")));
    }
    return SizedBox(
      height: 250,
      child: Padding(
        padding: const EdgeInsets.only(
          right: 16.0,
          left: 6.0,
          bottom: 8.0,
          top: 10,
        ),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) {
                return FlLine(color: Colors.grey.shade100, strokeWidth: 1);
              },
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      currencyFormatter.format(value),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade400,
                      ),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < data.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          data[index].label.substring(
                            0,
                            3,
                          ), // Shorten Month name
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                isCurved: true,
                spots: data
                    .asMap()
                    .entries
                    .map((e) => FlSpot(e.key.toDouble(), e.value.value))
                    .toList(),
                color: _accentColor,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      _accentColor.withOpacity(0.2),
                      _accentColor.withOpacity(0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _barChart(List<ChartItem> data) {
    if (data.isEmpty) {
      return const SizedBox(height: 50, child: Center(child: Text("No Data")));
    }
    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: Colors.grey.shade100),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ), // Hide Left Titles for cleaner look
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < data.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        data[index].label,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          barGroups: data.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.value,
                  color: _primaryColor,
                  width: 30,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _pieChart(List<ChartItem> data, double total) {
    if (data.isEmpty) {
      return const SizedBox(height: 50, child: Center(child: Text("No Data")));
    }
    // Limit to top 4 for pie chart to avoid clutter
    final displayData = data.length > 4 ? data.sublist(0, 4) : data;

    return SizedBox(
      height: 200,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 30,
                sections: displayData.asMap().entries.map((e) {
                  final index = e.key;
                  // Generate colors
                  final color = [
                    const Color(0xFF0D1F3C),
                    const Color(0xFF27AE60),
                    const Color(0xFFF2994A),
                    const Color(0xFF2D9CDB),
                    Colors.grey,
                  ][index % 5];

                  return PieChartSectionData(
                    value: e.value.value <= 0 ? 0.1 : e.value.value,
                    color: color,
                    showTitle: false,
                    radius: 25,
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: displayData.asMap().entries.map((e) {
                final index = e.key;
                final color = [
                  const Color(0xFF0D1F3C),
                  const Color(0xFF27AE60),
                  const Color(0xFFF2994A),
                  const Color(0xFF2D9CDB),
                  Colors.grey,
                ][index % 5];
                final percent = total > 0 ? (e.value.value / total) * 100 : 0.0;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          e.value.label,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        "${percent.toStringAsFixed(1)}%",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shippingChart(List<ShippingItem> data) {
    if (data.isEmpty) {
      return const SizedBox(height: 50, child: Center(child: Text("No Data")));
    }
    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < data.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        data[index].shipMode,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: Colors.grey.shade100),
          ),
          barGroups: data.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.totalSales,
                  color: const Color(0xFFF2994A), // Orange
                  width: 40,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _listChart(List<ChartItem> data, {bool isCurrency = true}) {
    if (data.isEmpty)
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text("Tidak ada data"),
      );
    return Column(
      children: data.asMap().entries.map((e) {
        final index = e.key;

        // Tentukan format tampilan angka
        String displayValue;
        if (isCurrency) {
          displayValue = currencyFormatter.format(e.value.value);
        } else {
          // Format desimal untuk quantity (misal: 1,200)
          displayValue = numberFormatter.format(e.value.value);
        }

        return Column(
          children: [
            ListTile(
              dense: true,
              leading: CircleAvatar(
                backgroundColor: _softGreenBg,
                radius: 16,
                child: Text(
                  "${index + 1}",
                  style: TextStyle(
                    color: _accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                e.value.label,
                style: TextStyle(
                  fontSize: 14,
                  color: _primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: Text(
                displayValue,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _accentColor,
                ),
              ),
            ),
            if (index != data.length - 1)
              Divider(
                height: 1,
                color: Colors.grey.shade100,
                indent: 16,
                endIndent: 16,
              ),
          ],
        );
      }).toList(),
    );
  }
}
