import 'package:flutter/material.dart';
import 'pages/login.dart';
import 'pages/tambah_produk.dart'; // Import halaman

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Commerce App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF6F8FB),
      ),
      home: const LoginPage(), // Halaman awal
      routes: {'/tambah_produk': (context) => const AddProductPage()},
    );
  }
}
