import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String productName;
  final String category;
  final String description;
  final String imageUrl;
  final double price;
  final int stock;

  const Product({
    required this.id,
    required this.productName,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.stock,
  });

  // Builds a Product from one Firestore document
  factory Product.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Product(
      id: doc.id,
      productName: (d['productName'] as String?) ?? '',
      category: (d['category'] as String?) ?? '',
      description: (d['description'] as String?) ?? '',
      imageUrl: (d['imageUrl'] as String?) ?? '',
      // Firestore may return int or double, so read it as num first
      price: (d['price'] as num?)?.toDouble() ?? 0,
      stock: (d['stock'] as num?)?.toInt() ?? 0,
    );
  }
}