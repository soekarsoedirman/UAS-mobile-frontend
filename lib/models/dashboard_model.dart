class DashboardData {
  final int totalRevenue;
  final int totalProducts;
  final int totalTransactions;

  DashboardData({
    required this.totalRevenue,
    required this.totalProducts,
    required this.totalTransactions,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      totalRevenue:
          double.tryParse(json['total_revenue'].toString())?.toInt() ?? 0,
      totalProducts: int.tryParse(json['total_products'].toString()) ?? 0,
      totalTransactions:
          int.tryParse(json['total_transactions'].toString()) ?? 0,
    );
  }
}
