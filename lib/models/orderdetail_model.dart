class OrderDetailModel {
  final String orderId;
  final String customerName;
  final String productId;
  final String productName;
  final String orderDate;
  final int quantity;
  final double sales;
  final String postalCode;

  OrderDetailModel({
    required this.orderId,
    required this.customerName,
    required this.productId,
    required this.productName,
    required this.orderDate,
    required this.quantity,
    required this.sales,
    required this.postalCode,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailModel(
      orderId: json['order_id']?.toString() ?? '-',
      customerName: json['customer_name']?.toString() ?? 'Unknown',
      productId: json['product_id']?.toString() ?? '-',
      productName: json['product_name']?.toString() ?? 'Unknown Product',
      orderDate: json['order_date']?.toString() ?? '-',
      quantity: int.tryParse(json['quantity'].toString()) ?? 0,
      sales: double.tryParse(json['sales'].toString()) ?? 0.0,
      postalCode: json['postalcode']?.toString() ?? '-',
    );
  }
}