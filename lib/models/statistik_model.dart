class DashboardData {
  final Summary summary;
  final Charts charts;

  DashboardData({
    required this.summary,
    required this.charts,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    // PERBAIKAN:
    // json di sini sudah berisi {summary: ..., charts: ...}
    // Jadi langsung panggil key-nya, TIDAK PERLU json['data'] lagi.
    return DashboardData(
      summary: Summary.fromJson(json['summary'] ?? {}),
      charts: Charts.fromJson(json['charts'] ?? {}),
    );
  }
}

/* ================= SUMMARY ================= */

class Summary {
  final double totalSales;
  final int totalTransactions;
  final double avgOrderValue;
  final int totalQuantity;
  final int totalCustomers;
  final int totalProducts;

  Summary({
    required this.totalSales,
    required this.totalTransactions,
    required this.avgOrderValue,
    required this.totalQuantity,
    required this.totalCustomers,
    required this.totalProducts,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    // PERBAIKAN: Gunakan tryParse agar aman dari null/string
    return Summary(
      totalSales: double.tryParse(json['total_sales'].toString()) ?? 0.0,
      totalTransactions: int.tryParse(json['total_transactions'].toString()) ?? 0,
      avgOrderValue: double.tryParse(json['avg_order_value'].toString()) ?? 0.0,
      totalQuantity: int.tryParse(json['total_quantity'].toString()) ?? 0,
      totalCustomers: int.tryParse(json['total_customers'].toString()) ?? 0,
      totalProducts: int.tryParse(json['total_products'].toString()) ?? 0,
    );
  }
}

/* ================= CHARTS ================= */

class Charts {
  final List<ChartItem> salesByCategory;
  final List<ChartItem> topProducts;
  final List<ChartItem> monthlyTrend;
  final List<ChartItem> quarterlyTrend;
  final List<ChartItem> yearlyTrend;
  final List<ChartItem> salesBySegment;
  final List<ChartItem> topCities;
  final List<ShippingItem> shippingPerformance;

  Charts({
    required this.salesByCategory,
    required this.topProducts,
    required this.monthlyTrend,
    required this.quarterlyTrend,
    required this.yearlyTrend,
    required this.salesBySegment,
    required this.topCities,
    required this.shippingPerformance,
  });

  factory Charts.fromJson(Map<String, dynamic> json) {
    return Charts(
      salesByCategory: _parseList(json['sales_by_category'], 'kategori_name'),
      topProducts: _parseList(json['top_products'], 'product_name'),
      monthlyTrend: _parseMonth(json['monthly_trend']),
      quarterlyTrend: _parseQuarter(json['quarterly_trend']),
      yearlyTrend: _parseYear(json['yearly_trend']),
      salesBySegment: _parseList(json['sales_by_segment'], 'segmen'),
      topCities: _parseList(json['top_cities'], 'city'),
      shippingPerformance: (json['shipping_performance'] as List? ?? [])
          .map((e) => ShippingItem.fromJson(e))
          .toList(),
    );
  }
}

/* ================= HELPERS ================= */

class ChartItem {
  final String label;
  final double value;

  ChartItem({required this.label, required this.value});
}

List<ChartItem> _parseList(List? list, String labelKey) {
  return (list ?? [])
      .map((e) => ChartItem(
            label: e[labelKey]?.toString() ?? "Unknown",
            value: double.tryParse(e['total'].toString()) ?? 0.0,
          ))
      .toList();
}

List<ChartItem> _parseMonth(List? list) {
  return (list ?? [])
      .map((e) => ChartItem(
            label: "${e['month_name']} ${e['year']}",
            value: double.tryParse(e['total'].toString()) ?? 0.0,
          ))
      .toList();
}

List<ChartItem> _parseQuarter(List? list) {
  return (list ?? [])
      .map((e) => ChartItem(
            label: "Q${e['quarter']} ${e['year']}",
            value: double.tryParse(e['total'].toString()) ?? 0.0,
          ))
      .toList();
}

List<ChartItem> _parseYear(List? list) {
  return (list ?? [])
      .map((e) => ChartItem(
            label: e['year'].toString(),
            value: double.tryParse(e['total'].toString()) ?? 0.0,
          ))
      .toList();
}

/* ================= SHIPPING ================= */

class ShippingItem {
  final String shipMode;
  final int totalOrder;
  final double totalSales;

  ShippingItem({
    required this.shipMode,
    required this.totalOrder,
    required this.totalSales,
  });

  factory ShippingItem.fromJson(Map<String, dynamic> json) {
    return ShippingItem(
      shipMode: json['shipmode']?.toString() ?? "Unknown",
      totalOrder: int.tryParse(json['total_order'].toString()) ?? 0,
      totalSales: double.tryParse(json['total_sales'].toString()) ?? 0.0,
    );
  }
}