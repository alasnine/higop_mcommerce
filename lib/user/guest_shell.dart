import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import 'shop_tab.dart';

/// Shown by AuthGate when nobody is logged in. The Home tab is fully
/// browsable (products, details) without an account. Cart and Profile
/// show a "log in to continue" prompt instead of their real content,
/// since both need a signed-in user to work (cart ties to checkout,
/// profile shows order history).
class GuestShell extends StatefulWidget {
  const GuestShell({super.key});

  @override
  State<GuestShell> createState() => _GuestShellState();
}

class _GuestShellState extends State<GuestShell> {
  int _index = 0;

  void _goToTab(int i) => setState(() => _index = i);

  void _openLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      ShopTab(user: null, onRequireLogin: _openLogin),
      _LockedTab(
        icon: Icons.shopping_bag_outlined,
        message: 'Log in to view your cart',
        onLogin: _openLogin,
      ),
      _LockedTab(
        icon: Icons.person_outline,
        message: 'Log in to view your profile and order history',
        onLogin: _openLogin,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _goToTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.local_cafe_outlined),
            selectedIcon: Icon(Icons.local_cafe),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag),
            label: 'Cart',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _LockedTab extends StatelessWidget {
  final IconData icon;
  final String message;
  final VoidCallback onLogin;

  const _LockedTab({
    required this.icon,
    required this.message,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: onLogin, child: const Text('Log In / Register')),
        ],
      ),
    );
  }
}
