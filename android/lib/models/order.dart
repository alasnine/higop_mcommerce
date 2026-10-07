import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item.dart';

class OrderItem {
  final String productName;
  final String size;
  final String sugar;
  final String topping;
  final String? temperature; // only set for Coffee category items
  final int quantity;
  final double unitPrice;

  const OrderItem({
    required this.productName,
    required this.size,
    required this.sugar,
    required this.topping,
    this.temperature,
    required this.quantity,
    required this.unitPrice,
  });

  factory OrderItem.fromCartItem(CartItem item) => OrderItem(
        productName: item.product.productName,
        size: item.size,
        sugar: item.sugar,
        topping: item.topping,
        temperature: item.temperature,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
      );

  Map<String, dynamic> toMap() => {
        'productName': productName,
        'size': size,
        'sugar': sugar,
        'topping': topping,
        'temperature': temperature,
        'quantity': quantity,
        'unitPrice': unitPrice,
      };

  factory OrderItem.fromMap(Map<String, dynamic> m) => OrderItem(
        productName: (m['productName'] as String?) ?? '',
        size: (m['size'] as String?) ?? '',
        sugar: (m['sugar'] as String?) ?? '',
        topping: (m['topping'] as String?) ?? '',
        temperature: m['temperature'] as String?,
        quantity: (m['quantity'] as num?)?.toInt() ?? 0,
        unitPrice: (m['unitPrice'] as num?)?.toDouble() ?? 0,
      );
}

class AppOrder {
  final String id;
  final String userId;
  final String userName;
  final String deliveryAddress;
  final String notes;
  final String paymentMethod;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String status; // Pending -> Processing -> Delivered
  final DateTime? timestamp;

  const AppOrder({
    required this.id,
    required this.userId,
    required this.userName,
    required this.deliveryAddress,
    required this.notes,
    required this.paymentMethod,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.status,
    required this.timestamp,
  });

  factory AppOrder.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final rawItems = (d['items'] as List<dynamic>? ?? [])
        .map((e) => OrderItem.fromMap(e as Map<String, dynamic>))
        .toList();
    return AppOrder(
      id: doc.id,
      userId: (d['userId'] as String?) ?? '',
      userName: (d['userName'] as String?) ?? '',
      deliveryAddress: (d['deliveryAddress'] as String?) ?? '',
      notes: (d['notes'] as String?) ?? '',
      paymentMethod: (d['paymentMethod'] as String?) ?? '',
      items: rawItems,
      subtotal: (d['subtotal'] as num?)?.toDouble() ?? 0,
      deliveryFee: (d['deliveryFee'] as num?)?.toDouble() ?? 0,
      total: (d['total'] as num?)?.toDouble() ?? 0,
      status: (d['status'] as String?) ?? 'Pending',
      timestamp: (d['timestamp'] as Timestamp?)?.toDate(),
    );
  }
}
