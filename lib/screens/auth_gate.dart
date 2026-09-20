import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../admin/admin_home_screen.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../user/home_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Layer 1: is anyone logged in?
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const _Loading();
        }
        final user = authSnap.data;
        if (user == null) return const LoginScreen();

        // Layer 2: who are they? Read their role from Firestore.
        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, snap) {
            if (snap.hasError) {
              debugPrint('AuthGate error: ${snap.error}');
              return const _ProblemScreen(
                message: 'Could not load your profile.',
              );
            }
            if (!snap.hasData) return const _Loading();
            if (!snap.data!.exists) {
              // Right after registering, the profile is written a moment
              // after the account is created, so this can flash briefly.
              return const _Loading(showLogout: true);
            }

            final appUser = AppUser.fromMap(user.uid, snap.data!.data()!);
            return appUser.isAdmin
                ? AdminHomeScreen(user: appUser)
                : HomeScreen(user: appUser);
          },
        );
      },
    );
  }
}

class _Loading extends StatelessWidget {
  final bool showLogout;
  const _Loading({this.showLogout = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (showLogout) ...[
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => AuthService().logout(),
                child: const Text('Taking too long? Logout'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProblemScreen extends StatelessWidget {
  final String message;
  const _ProblemScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => AuthService().logout(),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}