import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../utils/constants.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late String _size;
  late String _sugar;
  late String _topping;

  @override
  void initState() {
    super.initState();
    // Sensible defaults so the dropdowns aren't empty
    _size = AppConstants.sizes.keys.first; // Small
    _sugar = AppConstants.sugarLevels[2]; // 50%
    _topping = AppConstants.toppings.keys.first; // None
  }

  double get _currentUnitPrice {
    final sizeAddOn = AppConstants.sizes[_size] ?? 0;
    final toppingAddOn = AppConstants.toppings[_topping] ?? 0;
    return widget.product.price + sizeAddOn + toppingAddOn;
  }

  void _addToOrder() {
    context.read<CartProvider>().addItem(
          product: widget.product,
          size: _size,
          sugar: _sugar,
          topping: _topping,
        );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${widget.product.productName} added to your order'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    Navigator.of(context).pop(); // back to the product grid
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: p.imageUrl.isEmpty
                  ? Container(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.local_cafe, size: 64),
                    )
                  : Image.network(
                      p.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => Container(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.local_cafe, size: 64),
                      ),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.productName,
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text(
                    '₱${_currentUnitPrice.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 24),

                  _OptionDropdown(
                    label: 'Size',
                    value: _size,
                    options: AppConstants.sizes.keys.toList(),
                    onChanged: (v) => setState(() => _size = v),
                  ),
                  const SizedBox(height: 12),
                  _OptionDropdown(
                    label: 'Sugar %',
                    value: _sugar,
                    options: AppConstants.sugarLevels,
                    onChanged: (v) => setState(() => _sugar = v),
                  ),
                  const SizedBox(height: 12),
                  _OptionDropdown(
                    label: 'Toppings',
                    value: _topping,
                    options: AppConstants.toppings.keys.toList(),
                    onChanged: (v) => setState(() => _topping = v),
                  ),
                  const SizedBox(height: 24),

                  Text('Details of the product',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      p.description.isEmpty ? 'No description yet.' : p.description,
                    ),
                  ),
                  const SizedBox(height: 100), // room above the fixed button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: p.stock <= 0 ? null : _addToOrder,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(p.stock <= 0 ? 'SOLD OUT' : 'ADD TO MY ORDER'),
            ),
          ),
        ),
      ),
    );
  }
}

// Small reusable dropdown row, matches the wireframe's Size/Sugar/Toppings look
class _OptionDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const _OptionDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 90, child: Text(label)),
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: value,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: options
                .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                .toList(),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ],
    );
  }
}