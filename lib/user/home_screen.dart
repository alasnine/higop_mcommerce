import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  final AppUser user;
  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => AuthService().logout(),
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Welcome, ${user.name}!\nRole: ${user.role}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}