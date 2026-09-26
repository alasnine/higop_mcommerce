import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  final _products = FirebaseFirestore.instance.collection('products');

  // READ (the R in CRUD): a live list of all products.
  // Whenever a product changes in Firestore, this stream emits a new list.
  Stream<List<Product>> watchProducts() {
    return _products.snapshots().map((snap) {
      final list = snap.docs.map(Product.fromDoc).toList();
      list.sort((a, b) => a.productName.compareTo(b.productName));
      return list;
    });
  }
}