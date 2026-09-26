class AppConstants {
  // Home screen category chips. Must match the `category` field in Firestore exactly.
  static const List<String> categories = [
    'Milk Tea',
    'Frappe',
    'Coffee',
    'Fruit Tea',
  ];

  // Product Details options (used in Part B). Value = extra price in pesos.
  static const Map<String, int> sizes = {'Small': 0, 'Medium': 10, 'Large': 20};
  static const List<String> sugarLevels = ['0%', '25%', '50%', '75%', '100%'];
  static const Map<String, int> toppings = {
    'None': 0,
    'Pearls': 10,
    'Nata de Coco': 10,
    'Cream Cheese': 15,
  };

  // Used at Cart and Checkout (Parts C and D).
  static const int deliveryFee = 49;
}