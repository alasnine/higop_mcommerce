import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../utils/constants.dart';
import '../widgets/product_card.dart';
import '../widgets/higop_header.dart';
import 'product_details_screen.dart';

class ShopTab extends StatefulWidget {
  final AppUser? user; // null = browsing as a guest
  final VoidCallback? onRequireLogin; // shown as a "Log In" button for guests
  const ShopTab({super.key, this.user, this.onRequireLogin});

  @override
  State<ShopTab> createState() => _ShopTabState();
}

class _ShopTabState extends State<ShopTab> {
  // Created once, so tapping a chip doesn't restart the Firestore listener.
  final Stream<List<Product>> _productsStream = ProductService().watchProducts();
  String? _category; // null = show every category

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final firstName = widget.user?.name.trim().split(' ').first;

    return Column(
      children: [
        // Header: wordmark logo, "Log In" button only for guests
        HigopHeader(
          onLoginTap: widget.user == null ? widget.onRequireLogin : null,
          tagline: firstName != null
              ? 'Hi, $firstName! Higop muna.'
              : 'Higop muna. Pick your drink.',
        ),

        // Category chips (tap a selected chip again to show everything)
        SizedBox(
          height: 60,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: AppConstants.categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final c = AppConstants.categories[i];
              final selected = _category == c;
              return ChoiceChip(
                label: Text(c),
                selected: selected,
                showCheckmark: false,
                selectedColor: cs.primary,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : cs.onSurface,
                ),
                onSelected: (_) =>
                    setState(() => _category = selected ? null : c),
              );
            },
          ),
        ),

        // Product grid, live from Firestore
        Expanded(
          child: StreamBuilder<List<Product>>(
            stream: _productsStream,
            builder: (context, snap) {
              if (snap.hasError) {
                debugPrint('Products error: ${snap.error}');
                return const Center(child: Text('Could not load products.'));
              }
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              var products = snap.data!;
              if (_category != null) {
                products =
                    products.where((p) => p.category == _category).toList();
              }
              if (products.isEmpty) {
                return const Center(child: Text('No drinks here yet.'));
              }

              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
                itemCount: products.length,
                itemBuilder: (context, i) {
                  final product = products[i];
                  return ProductCard(
                    product: product,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProductDetailsScreen(product: product),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}