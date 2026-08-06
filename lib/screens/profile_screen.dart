import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  final bool embedded;
  const ProfileScreen({super.key, this.embedded = false});

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Жүйеден шығу'),
        content: const Text('Шын мәнінде аккаунттан шыққыңыз келе ме?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Бас тарту', style: TextStyle(color: Colors.grey)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE05B49),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Шығу'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await FirebaseAuth.instance.signOut();
      if (!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final rawName = user?.displayName ?? '';
    final email = user?.email ?? 'email@example.com';

    // Егер displayName бос болса, email-дің басын пайдалану
    final displayName = rawName.isNotEmpty
        ? rawName
        : (email.contains('@') ? email.split('@')[0] : 'Пайдаланушы');

    final content = ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        // --- ПРОФИЛЬ ХЕДЕРІ (Аватар + Аты) ---
// --- ПРОФИЛЬ ХЕДЕРІ (Дефолтный персон суреті + Аты) ---
        Center(
          child: Column(
            children: [
              const CircleAvatar(
                radius: 46,
                backgroundColor: Color(0xFF6C63FF),
                child: Icon(
                  Icons.person,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                displayName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                email,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // --- БӨЛІМ 1: ДЕРЕКТЕР МЕН БАПТАУЛАР ---
        _buildSectionTitle('Жеке баптаулар'),
        const SizedBox(height: 10),
        _buildSettingsCard([
          _ProfileOptionTile(
            icon: Icons.person_outline_rounded,
            title: 'Деректерді өңдеу',
            subtitle: 'Аты-жөн, профиль суреті',
            onTap: () {},
          ),
          _ProfileOptionTile(
            icon: Icons.notifications_none_rounded,
            title: 'Хабарландырулар',
            subtitle: 'Бюджет лимиті ескертулері',
            onTap: () {},
          ),
          _ProfileOptionTile(
            icon: Icons.lock_outline_rounded,
            title: 'Қауіпсіздік',
            subtitle: 'Құпия сөзді өзгерту',
            onTap: () {},
          ),
        ]),

        const SizedBox(height: 24),

        // --- БӨЛІМ 2: ҚОЛДАНБА ТУРАЛЫ ---
        _buildSectionTitle('Қолданба'),
        const SizedBox(height: 10),
        _buildSettingsCard([
          _ProfileOptionTile(
            icon: Icons.help_outline_rounded,
            title: 'Көмек және қолдау',
            onTap: () {},
          ),
          _ProfileOptionTile(
            icon: Icons.info_outline_rounded,
            title: 'Қолданба туралы',
            subtitle: 'Нұсқасы v1.0.0',
            onTap: () {},
          ),
        ]),

        const SizedBox(height: 32),

        // --- ШЫҒУ БАТЫРМАСЫ ---
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout_rounded, color: Color(0xFFE05B49)),
            label: const Text(
              'Аккаунттан шығу',
              style: TextStyle(
                color: Color(0xFFE05B49),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFFFD5D0)),
              backgroundColor: const Color(0xFFFFF5F5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );

    if (embedded) return content;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text(
          'Профиль',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: content,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

// Ішкі виджет: Баптаулар тилы
class _ProfileOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _ProfileOptionTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F1FF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF6C63FF), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: Colors.black87,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
        subtitle!,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
      )
          : null,
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: Colors.grey.shade400,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}