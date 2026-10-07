import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_item.dart';
import '../providers/cart_provider.dart';
import '../utils/constants.dart';

class CartTab extends StatelessWidget {
  final VoidCallback onBrowseMore;
  final VoidCallback onCheckout;

  const CartTab({
    super.key,
    required this.onBrowseMore,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    // watch() = rebuild this screen whenever the cart changes
    final cart = context.watch<CartProvider>();

    if (cart.isEmpty) {
      return SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_bag_outlined, size: 72, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Your cart is empty', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            FilledButton(onPressed: onBrowseMore, child: const Text('Browse Drinks')),
          ],
        ),
      );
    }

    final deliveryFee = AppConstants.deliveryFee.toDouble();
    final total = cart.subtotal + deliveryFee;

    return Column(
      children: [
        Container(
          width: double.infinity,
          color: Theme.of(context).colorScheme.primary,
          padding: EdgeInsets.fromLTRB(
              20, MediaQuery.paddingOf(context).top + 20, 20, 16),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cart',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('estimated delivery: 20 - 30 mins',
                  style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: cart.items.length,
            separatorBuilder: (_, _) => const Divider(height: 24),
            itemBuilder: (context, i) => _CartLine(item: cart.items[i]),
          ),
        ),
        SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextButton.icon(
                  onPressed: onBrowseMore,
                  icon: const Icon(Icons.add),
                  label: const Text('ADD MORE ITEMS'),
                ),
                const Divider(),
                _PriceRow(label: 'Subtotal', value: cart.subtotal),
                _PriceRow(label: 'Delivery Fee', value: deliveryFee),
                const Divider(),
                _PriceRow(label: 'TOTAL', value: total, bold: true),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: onCheckout,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('PROCEED TO CHECKOUT'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CartLine extends StatelessWidget {
  final CartItem item;
  const _CartLine({required this.item});

  @override
  Widget build(BuildContext context) {
    // read() here: this button performs an action, it doesn't need to rebuild itself
    final cart = context.read<CartProvider>();

    final subtitleParts = [
      if (item.temperature != null) item.temperature!,
      item.size,
      '${item.sugar} sugar',
      item.topping,
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: item.product.imageUrl.isEmpty
              ? Container(
                  width: 56,
                  height: 56,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.local_cafe),
                )
              : Image.network(
                  item.product.imageUrl,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 56,
                    height: 56,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.local_cafe),
                  ),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.product.productName,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(
                subtitleParts.join(' · '),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _QtyButton(
                    icon: Icons.remove,
                    onTap: () => cart.decreaseQuantity(item.lineKey),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('${item.quantity}'),
                  ),
                  _QtyButton(
                    icon: Icons.add,
                    onTap: () => cart.increaseQuantity(item.lineKey),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: Theme.of(context).colorScheme.error,
                    onPressed: () => cart.removeItem(item.lineKey),
                  ),
                ],
              ),
            ],
          ),
        ),
        Text('₱${item.lineTotal.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final double value;
  final bool bold;
  const _PriceRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      fontSize: bold ? 16 : 14,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text('₱${value.toStringAsFixed(2)}', style: style),
        ],
      ),
    );
  }
}
