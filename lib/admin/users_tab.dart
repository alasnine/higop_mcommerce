import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../services/user_service.dart';

class UsersTab extends StatelessWidget {
  const UsersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AppUser>>(
      stream: UserService().watchAllUsers(),
      builder: (context, snap) {
        if (snap.hasError) {
          debugPrint('Users error: ${snap.error}');
          return const Center(child: Text('Could not load users.'));
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final users = snap.data!;
        if (users.isEmpty) {
          return const Center(child: Text('No registered users yet.'));
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Role')),
              ],
              rows: users.map((user) {
                final isAdmin = user.isAdmin;
                return DataRow(cells: [
                  DataCell(Text(user.name)),
                  DataCell(Text(user.email)),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isAdmin ? Colors.purple : Colors.blue)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        user.role,
                        style: TextStyle(
                          color: isAdmin ? Colors.purple.shade700 : Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
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