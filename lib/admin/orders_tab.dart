import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import '../utils/app_theme.dart';

class OrdersTab extends StatelessWidget {
  const OrdersTab({super.key});

  static const _statuses = ['Pending', 'Processing', 'Delivered'];

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

  Future<void> _changeStatus(BuildContext context, AppOrder order, String newStatus) async {
    try {
      await OrderService().updateStatus(order.id, newStatus);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${order.userName}\'s order marked as $newStatus')),
        );
      }
    } catch (e) {
      debugPrint('Update status error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AppOrder>>(
      stream: OrderService().watchAllOrders(),
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

        return Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Customer')),
                DataColumn(label: Text('Items')),
                DataColumn(label: Text('Total')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Update Status')),
              ],
              rows: orders.map((order) {
                final itemsSummary = order.items
                    .map((it) => '${it.quantity}x ${it.productName}')
                    .join(', ');
                return DataRow(cells: [
                  DataCell(Text(order.userName)),
                  DataCell(
                    SizedBox(
                      width: 220,
                      child: Text(itemsSummary,
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  DataCell(Text('₱${order.total.toStringAsFixed(2)}')),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(order.status).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        order.status,
                        style: TextStyle(
                          color: _statusColor(order.status),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    DropdownButton<String>(
                      value: order.status,
                      underline: const SizedBox(),
                      items: _statuses
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (newStatus) {
                        if (newStatus != null && newStatus != order.status) {
                          _changeStatus(context, order, newStatus);
                        }
                      },
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}