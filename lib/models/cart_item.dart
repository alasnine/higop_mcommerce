import 'product.dart';

class CartItem {
  final Product product;
  final String size;
  final String sugar;
  final String topping;
  int quantity;

  CartItem({
    required this.product,
    required this.size,
    required this.sugar,
    required this.topping,
    this.quantity = 1,
  });

  // A unique key per combination, so "Large, 50%, Pearls" and
  // "Small, 100%, None" of the same drink are separate cart lines.
  String get lineKey => '${product.id}_${size}_${sugar}_$topping';

  double get unitPrice {
    final sizeAddOn = _sizePrices[size] ?? 0;
    final toppingAddOn = _toppingPrices[topping] ?? 0;
    return product.price + sizeAddOn + toppingAddOn;
  }

  double get lineTotal => unitPrice * quantity;

  static const _sizePrices = {'Small': 0, 'Medium': 10, 'Large': 20};
  static const _toppingPrices = {
    'None': 0,
    'Pearls': 10,
    'Nata de Coco': 10,
    'Cream Cheese': 15,
  };
}