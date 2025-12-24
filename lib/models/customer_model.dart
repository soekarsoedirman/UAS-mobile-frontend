class Customer {
  final String id;
  final String name;
  final String email;
  // Tambahkan field lain sesuai database Anda

  Customer({required this.id, required this.name, required this.email});

  // Factory untuk membuat object dari JSON
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id:
          json['customer_id']?.toString() ??
          '', // Sesuaikan key dengan response JSON backend
      name: json['customer_name'] ?? 'No Name',
      email: json['email'] ?? '',
    );
  }

  // Method untuk mengubah object ke JSON (untuk POST/PUT)
  Map<String, dynamic> toJson() {
    return {'customer_name': name, 'email': email};
  }
}
