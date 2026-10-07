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

  // Same cream tone as the wordmark image's own background, so the badge
  // blends directly into the sidebar instead of sitting on a dark card.
  static const _sidebarBg = Color(0xFFEBE1D2);

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
              backgroundColor: _sidebarBg,
              selectedIconTheme: const IconThemeData(color: HigopColors.kayumanggi),
              unselectedIconTheme: IconThemeData(
                color: HigopColors.tsokolate.withValues(alpha: 0.55),
              ),
              selectedLabelTextStyle: const TextStyle(
                color: HigopColors.tsokolate,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelTextStyle: TextStyle(
                color: HigopColors.tsokolate.withValues(alpha: 0.7),
              ),
              indicatorColor: HigopColors.kayumanggi.withValues(alpha: 0.15),
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/icon/higop_wordmark.png',
                      width: 140,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 10),
                    Text('ADMIN',
                        style: TextStyle(
                          color: HigopColors.tsokolate.withValues(alpha: 0.75),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          fontSize: 12,
                        )),
                    Text(widget.user.name,
                        style: TextStyle(
                          color: HigopColors.tsokolate.withValues(alpha: 0.6),
                          fontSize: 12,
                        )),
                  ],
                ),
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: IconButton(
                      icon: Icon(Icons.logout,
                          color: HigopColors.tsokolate.withValues(alpha: 0.75)),
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
