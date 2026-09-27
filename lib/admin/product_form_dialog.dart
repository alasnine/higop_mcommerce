import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';

class ProductFormDialog extends StatefulWidget {
  final Product? existing; // null = adding a new product

  const ProductFormDialog({super.key, this.existing});

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _imageCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _stockCtrl;
  late String _category;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    _nameCtrl = TextEditingController(text: p?.productName ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _imageCtrl = TextEditingController(text: p?.imageUrl ?? '');
    _priceCtrl = TextEditingController(text: p?.price.toStringAsFixed(2) ?? '');
    _stockCtrl = TextEditingController(text: p?.stock.toString() ?? '');
    // Guard against a category value that doesn't exactly match one of our
    // four options (typo, extra space, old data) — fall back safely instead
    // of crashing the dropdown.
    _category = AppConstants.categories.contains(p?.category)
        ? p!.category
        : AppConstants.categories.first;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _imageCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final data = {
      'productName': _nameCtrl.text.trim(),
      'category': _category,
      'description': _descCtrl.text.trim(),
      'imageUrl': _imageCtrl.text.trim(),
      'price': double.parse(_priceCtrl.text.trim()),
      'stock': int.parse(_stockCtrl.text.trim()),
    };

    try {
      final service = ProductService();
      if (_isEditing) {
        await service.updateProduct(widget.existing!.id, data);
      } else {
        await service.addProduct(
          productName: data['productName'] as String,
          category: data['category'] as String,
          description: data['description'] as String,
          imageUrl: data['imageUrl'] as String,
          price: data['price'] as double,
          stock: data['stock'] as int,
        );
      }
      if (mounted) Navigator.of(context).pop(true); // true = saved successfully
    } catch (e) {
      debugPrint('Save product error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _numberValidator(String? v, {bool allowDecimal = true}) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final n = allowDecimal ? double.tryParse(v) : int.tryParse(v);
    if (n == null) return 'Enter a valid number';
    if (n < 0) return 'Cannot be negative';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Product' : 'Add Product'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                  validator: (v) => Validators.required(v, 'Product name'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: AppConstants.categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v!),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                  validator: (v) => Validators.required(v, 'Description'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _imageCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Image URL',
                    hintText: 'https://...',
                  ),
                  validator: (v) => Validators.required(v, 'Image URL'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceCtrl,
                        decoration: const InputDecoration(labelText: 'Price (₱)'),
                        keyboardType: TextInputType.number,
                        validator: (v) => _numberValidator(v, allowDecimal: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _stockCtrl,
                        decoration: const InputDecoration(labelText: 'Stock'),
                        keyboardType: TextInputType.number,
                        validator: (v) => _numberValidator(v, allowDecimal: false),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(_isEditing ? 'Save Changes' : 'Add Product'),
        ),
      ],
    );
  }
}