import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();
  int get itemCount => _items.values.fold(0, (sum, i) => sum + i.quantity);
  double get subtotal => _items.values.fold(0, (sum, i) => sum + i.lineTotal);
  bool get isEmpty => _items.isEmpty;

  void addItem({
    required Product product,
    required String size,
    required String sugar,
    required String topping,
    String? temperature,
    int quantity = 1,
  }) {
    final temp = CartItem(
      product: product,
      size: size,
      sugar: sugar,
      topping: topping,
      temperature: temperature,
      quantity: quantity,
    );
    final key = temp.lineKey;

    if (_items.containsKey(key)) {
      _items[key]!.quantity += quantity;
    } else {
      _items[key] = temp;
    }
    notifyListeners(); // tells every widget watching this cart to rebuild
  }

  void increaseQuantity(String lineKey) {
    _items[lineKey]?.quantity += 1;
    notifyListeners();
  }

  void decreaseQuantity(String lineKey) {
    final item = _items[lineKey];
    if (item == null) return;
    if (item.quantity > 1) {
      item.quantity -= 1;
    } else {
      _items.remove(lineKey);
    }
    notifyListeners();
  }

  void removeItem(String lineKey) {
    _items.remove(lineKey);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
