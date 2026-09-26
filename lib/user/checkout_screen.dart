import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../services/order_service.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _payment = 'Cash';
  bool _placing = false;
  bool _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadSavedAddress();
  }

  Future<void> _loadSavedAddress() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    _addressCtrl.text = (doc.data()?['address'] as String?) ?? '';
    if (mounted) setState(() => _loadingProfile = false);
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    final cart = context.read<CartProvider>();
    if (cart.isEmpty) return;

    setState(() => _placing = true);
    final uid = FirebaseAuth.instance.currentUser!.uid;

    try {
      // Save the address to the profile for next time (allowed by the updated rule)
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'address': _addressCtrl.text.trim(),
      });

      await OrderService().placeOrder(
        userName: FirebaseAuth.instance.currentUser?.displayName ?? 'Customer',
        deliveryAddress: _addressCtrl.text.trim(),
        notes: _notesCtrl.text.trim(),
        paymentMethod: _payment,
        cartItems: cart.items,
        subtotal: cart.subtotal,
        deliveryFee: AppConstants.deliveryFee.toDouble(),
      );

      cart.clear();

      if (mounted) {
        Navigator.of(context).pop(); // back to Cart (now empty)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed! Track it in your Profile.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Checkout error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not place your order. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final deliveryFee = AppConstants.deliveryFee.toDouble();
    final total = cart.subtotal + deliveryFee;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: _loadingProfile
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text('Delivery Address',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _addressCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'House/Unit No., Street, Barangay',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => Validators.required(v, 'Delivery address'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      hintText: 'e.g. Ring the doorbell',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Payment Method',
                      style: Theme.of(context).textTheme.titleMedium),
                  ...['Cash', 'Online Payment', 'Debit/Credit Card'].map(
                    (m) => RadioListTile<String>(
                      title: Text(m),
                      value: m,
                      groupValue: _payment,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (v) => setState(() => _payment = v!),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Order Summary',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...cart.items.map(
                    (i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text('${i.quantity}x ${i.product.productName}'),
                          ),
                          Text('₱${i.lineTotal.toStringAsFixed(2)}'),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal'),
                      Text('₱${cart.subtotal.toStringAsFixed(2)}'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Delivery Fee'),
                      Text('₱${deliveryFee.toStringAsFixed(2)}'),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('₱${total.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _placing ? null : _placeOrder,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: _placing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('PLACE ORDER'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}