import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  final _products = FirebaseFirestore.instance.collection('products');

  // READ (the R in CRUD): a live list of all products.
  Stream<List<Product>> watchProducts() {
    return _products.snapshots().map((snap) {
      final list = snap.docs.map(Product.fromDoc).toList();
      list.sort((a, b) => a.productName.compareTo(b.productName));
      return list;
    });
  }

  // CREATE
  Future<void> addProduct({
    required String productName,
    required String category,
    required String description,
    required String imageUrl,
    required double price,
    required int stock,
  }) {
    return _products.add({
      'productName': productName,
      'category': category,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      'stock': stock,
    });
  }

  // UPDATE
  Future<void> updateProduct(String id, Map<String, dynamic> data) {
    return _products.doc(id).update(data);
  }

  // DELETE
  Future<void> deleteProduct(String id) {
    return _products.doc(id).delete();
  }
}