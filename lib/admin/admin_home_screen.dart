import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import 'products_tab.dart';
import 'orders_tab.dart';
import 'users_tab.dart';

class AdminHomeScreen extends StatefulWidget {
  final AppUser user;
  const AdminHomeScreen({super.key, required this.user});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _index = 0;

  static const _sections = ['Products', 'Orders', 'Users'];
  static const _icons = [Icons.local_cafe, Icons.receipt_long, Icons.people];

  @override
  Widget build(BuildContext context) {
    final pages = const [ProductsTab(), OrdersTab(), UsersTab()];
    final isWide = MediaQuery.sizeOf(context).width >= 700;

    return Scaffold(
      body: Row(
        children: [
          if (isWide)
            NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              extended: true,
              backgroundColor: HigopColors.tsokolate,
              selectedIconTheme: const IconThemeData(color: Colors.white),
              unselectedIconTheme: IconThemeData(color: Colors.white.withValues(alpha: 0.6)),
              selectedLabelTextStyle: const TextStyle(color: Colors.white),
              unselectedLabelTextStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    const Icon(Icons.local_cafe, color: HigopColors.ginto, size: 32),
                    const SizedBox(height: 8),
                    const Text('HIGOP ADMIN',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(widget.user.name,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
                  ],
                ),
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white70),
                      tooltip: 'Logout',
                      onPressed: () => AuthService().logout(),
                    ),
                  ),
                ),
              ),
              destinations: List.generate(
                _sections.length,
                (i) => NavigationRailDestination(
                  icon: Icon(_icons[i]),
                  label: Text(_sections[i]),
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!isWide)
                  AppBar(
                    title: Text(_sections[_index]),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.logout),
                        onPressed: () => AuthService().logout(),
                      ),
                    ],
                  ),
                Expanded(child: IndexedStack(index: _index, children: pages)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              destinations: List.generate(
                _sections.length,
                (i) => NavigationDestination(icon: Icon(_icons[i]), label: _sections[i]),
              ),
            ),
    );
  }
}