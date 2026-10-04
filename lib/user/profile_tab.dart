import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../models/order.dart';
import '../services/auth_service.dart';
import '../services/order_service.dart';
import '../utils/app_theme.dart';

class ProfileTab extends StatelessWidget {
  final AppUser user;
  const ProfileTab({super.key, required this.user});

  Color _statusColor(String status) {
    switch (status) {
      case 'Delivered':
        return HigopColors.dahon;
      case 'Processing':
        return HigopColors.ginto;
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: Theme.of(context).colorScheme.primary,
          padding: EdgeInsets.fromLTRB(
              20, MediaQuery.paddingOf(context).top + 24, 20, 24),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, size: 44, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text('Hi, ${user.name}!',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              Text(user.email, style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Text('MY ORDERS',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<AppOrder>>(
            stream: OrderService().watchMyOrders(),
            builder: (context, snap) {
              if (snap.hasError) {
                debugPrint('Orders error: ${snap.error}');
                return const Center(child: Text('Could not load orders.'));
              }
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final orders = snap.data!;
              if (orders.isEmpty) {
                return const Center(child: Text('No orders yet.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: orders.length,
                itemBuilder: (context, i) {
                  final order = orders[i];
                  final itemsSummary = order.items
                      .map((it) => '${it.quantity}x ${it.productName}')
                      .join(', ');
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(itemsSummary,
                                    style: const TextStyle(fontWeight: FontWeight.w600)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _statusColor(order.status).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  order.status,
                                  style: TextStyle(
                                    color: _statusColor(order.status),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('₱${order.total.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextButton.icon(
            onPressed: () => AuthService().logout(),
            icon: const Icon(Icons.logout),
            label: const Text('Log-out'),
          ),
        ),
      ],
    );
  }
}