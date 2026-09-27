import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cart_item.dart';
import '../models/order.dart';

class OrderService {
  final _db = FirebaseFirestore.instance;

  // CREATE (the C in CRUD): turns the cart into one order document.
  Future<void> placeOrder({
    required String userName,
    required String deliveryAddress,
    required String notes,
    required String paymentMethod,
    required List<CartItem> cartItems,
    required double subtotal,
    required double deliveryFee,
  }) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await _db.collection('orders').add({
      'userId': uid,
      'userName': userName,
      'deliveryAddress': deliveryAddress,
      'notes': notes,
      'paymentMethod': paymentMethod,
      'items': cartItems.map((c) => OrderItem.fromCartItem(c).toMap()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': subtotal + deliveryFee,
      'status': 'Pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // READ: live list of the current user's own orders, newest first.
  Stream<List<AppOrder>> watchMyOrders() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _db
        .collection('orders')
        .where('userId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(AppOrder.fromDoc).toList());
  }

  // READ (admin): live list of every order, newest first.
  Stream<List<AppOrder>> watchAllOrders() {
    return _db
        .collection('orders')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(AppOrder.fromDoc).toList());
  }

  // UPDATE (admin): change an order's status.
  Future<void> updateStatus(String orderId, String status) {
    return _db.collection('orders').doc(orderId).update({'status': status});
  }
}