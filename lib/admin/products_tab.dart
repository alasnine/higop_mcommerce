import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import 'product_form_dialog.dart';

class ProductsTab extends StatelessWidget {
  const ProductsTab({super.key});

  Future<void> _openForm(BuildContext context, {Product? existing}) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => ProductFormDialog(existing: existing),
    );
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(existing == null ? 'Product added' : 'Product updated')),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context, Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Remove "${product.productName}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ProductService().deleteProduct(product.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${product.productName} deleted')),
          );
        }
      } catch (e) {
        debugPrint('Delete error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Product>>(
        stream: ProductService().watchProducts(),
        builder: (context, snap) {
          if (snap.hasError) {
            debugPrint('Products error: ${snap.error}');
            return const Center(child: Text('Could not load products.'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final products = snap.data!;
          if (products.isEmpty) {
            return const Center(child: Text('No products yet. Tap + to add one.'));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Image')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Category')),
                  DataColumn(label: Text('Price')),
                  DataColumn(label: Text('Stock')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: products.map((p) {
                  final soldOut = p.stock <= 0;
                  return DataRow(cells: [
                    DataCell(
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: p.imageUrl.isEmpty
                            ? Container(width: 40, height: 40, color: Colors.grey.shade300)
                            : Image.network(p.imageUrl,
                                width: 40, height: 40, fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    Container(width: 40, height: 40, color: Colors.grey.shade300)),
                      ),
                    ),
                    DataCell(Text(p.productName)),
                    DataCell(Text(p.category)),
                    DataCell(Text('₱${p.price.toStringAsFixed(2)}')),
                    DataCell(Text(
                      soldOut ? 'SOLD OUT' : '${p.stock}',
                      style: TextStyle(color: soldOut ? Colors.red : null),
                    )),
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          tooltip: 'Edit',
                          onPressed: () => _openForm(context, existing: p),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          color: Colors.red.shade700,
                          tooltip: 'Delete',
                          onPressed: () => _confirmDelete(context, p),
                        ),
                      ],
                    )),
                  ]);
                }).toList(),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
    );
  }
}