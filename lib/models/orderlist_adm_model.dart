class OrderModel {
  final String orderId;
  final String customerName;
  final String productId;
  final String orderDate;
  final int quantity;
  final double sales;
  final String status;
  final String postalCode;

  OrderModel({
    required this.orderId,
    required this.customerName,
    required this.productId,
    required this.orderDate,
    required this.quantity,
    required this.sales,
    required this.status,
    required this.postalCode,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['order_id']?.toString() ?? '-',
      customerName: json['customer_name']?.toString() ?? 'Unknown Customer',
      productId: json['product_id']?.toString() ?? '-',
      orderDate: json['order_date']?.toString() ?? '-',
      quantity: int.tryParse(json['quantity'].toString()) ?? 0,
      // Mengubah sales menjadi double dengan aman
      sales: double.tryParse(json['sales'].toString()) ?? 0.0,
      status: json['status']?.toString() ?? 'Pending',
      postalCode: json['postalcode']?.toString() ?? '-',
    );
  }
}