import 'package:flutter/material.dart';

class SellerOrderListPage extends StatelessWidget {
  const SellerOrderListPage({super.key});

  Color getStatusColor(String status) {
    if (status == "Success") {
      return Colors.green;
    } else if (status == "Pending") {
      return Colors.orange;
    } else {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = [
      {
        "productName": "Sayur Bayam",
        "qty": 2,
        "price": 2000,
        "date": "12-12-2025",
        "shipMode": "Regular",
        "status": "Pending",
        "store": "Supermarket",
      },
      {
        "productName": "Buah Apel",
        "qty": 1,
        "price": 5000,
        "date": "11-12-2025",
        "shipMode": "Express",
        "status": "Success",
        "store": "Pasar Segar",
      },
      {
        "productName": "Daging Sapi",
        "qty": 1,
        "price": 100000,
        "date": "10-12-2025",
        "shipMode": "Regular",
        "status": "Success",
        "store": "Butcher Shop",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Order List Seller",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
              ],
            ),
            child: Row(
              children: [
                // ICON LEFT
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shopping_bag, color: Colors.green),
                ),

                const SizedBox(width: 12),

                // CENTER TEXT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order["productName"].toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order["store"].toString(),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Qty: ${order["qty"]} • ${order["shipMode"]}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                // RIGHT SIDE
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Rp ${order["price"]}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order["status"].toString(),
                      style: TextStyle(
                        fontSize: 12,
                        color: getStatusColor(order["status"].toString()),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
