import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  final bool embedded;
  const ProfileScreen({super.key, this.embedded = false});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = (user?.displayName?.isNotEmpty ?? false)
        ? user!.displayName!
        : 'Пайдаланушы аты';
    final email = user?.email ?? 'email@example.com';

    final content = ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 16),
        const CircleAvatar(
          radius: 48,
          backgroundColor: Colors.deepPurple,
          child: Icon(Icons.person, size: 48, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text(displayName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge),
        Text(email,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 32),
        FilledButton.icon(
          onPressed: () => _logout(context),
          icon: const Icon(Icons.logout),
          label: const Text('Шығу'),
          style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
        ),
      ],
    );

    if (embedded) return content;

    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: content,
    );
  }
}