import 'product.dart';

class CartItem {
  final Product product;
  final String size;
  final String sugar;
  final String topping;
  final String? temperature; // only set for Coffee category items
  int quantity;

  CartItem({
    required this.product,
    required this.size,
    required this.sugar,
    required this.topping,
    this.temperature,
    this.quantity = 1,
  });

  // A unique key per combination, so different customizations of the same
  // drink (including hot vs iced) stay as separate cart lines.
  String get lineKey =>
      '${product.id}_${size}_${sugar}_${topping}_${temperature ?? "na"}';

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
