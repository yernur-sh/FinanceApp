import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import 'edit_profile_screen.dart';
import 'security_screen.dart';
import 'help_support_screen.dart';
import 'about_app_screen.dart';
import 'notifications_screen.dart';

class ProfileScreen extends StatelessWidget {
  final bool embedded;
  const ProfileScreen({super.key, this.embedded = false});

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: kBorder),
        ),
        title: Text('Жүйеден шығу', style: appBody(color: kTextPrimary, fontWeight: FontWeight.w700)),
        content: Text('Шын мәнінде аккаунттан шыққыңыз келе ме?',
            style: appBody(color: kTextSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Бас тарту', style: appBody(color: kTextMuted)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: kClay,
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
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) {
        final user = snapshot.data;
        final rawName = user?.displayName ?? '';
        final email = user?.email ?? 'email@example.com';

        final displayName = rawName.isNotEmpty
            ? rawName
            : (email.contains('@') ? email.split('@')[0] : 'Пайдаланушы');

        return _buildContent(context, displayName, email);
      },
    );
  }

  Widget _buildContent(BuildContext context, String displayName, String email) {
    final content = ListView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 120),
      children: [
        if (embedded) ...[
          Text('Профиль', style: appDisplay(fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
        ],
        Center(
          child: Column(
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  gradient: kAccentGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: kAccent.withOpacity(0.35),
                      blurRadius: 26,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person,
                  size: 44,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                displayName,
                style: appBody(fontSize: 20, fontWeight: FontWeight.w700, color: kTextPrimary),
              ),
              const SizedBox(height: 2),
              Text(
                email,
                style: appBody(fontSize: 14, color: kTextMuted),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        _buildSectionTitle('Жеке баптаулар'),
        const SizedBox(height: 10),
        _buildSettingsCard([
          _ProfileOptionTile(
            icon: Icons.person_outline_rounded,
            title: 'Деректерді өңдеу',
            subtitle: 'Аты-жөн, профиль суреті',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EditProfileScreen()),
            ),
          ),
          _ProfileOptionTile(
            icon: Icons.notifications_none_rounded,
            title: 'Хабарландырулар',
            subtitle: 'Бюджет лимиті ескертулері',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationsScreen()),
            ),
          ),
          _ProfileOptionTile(
            icon: Icons.lock_outline_rounded,
            title: 'Қауіпсіздік',
            subtitle: 'Құпия сөзді өзгерту',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SecurityScreen()),
            ),
            isLast: true,
          ),
        ]),

        const SizedBox(height: 24),

        _buildSectionTitle('Қолданба'),
        const SizedBox(height: 10),
        _buildSettingsCard([
          _ProfileOptionTile(
            icon: Icons.help_outline_rounded,
            title: 'Көмек және қолдау',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
            ),
          ),
          _ProfileOptionTile(
            icon: Icons.info_outline_rounded,
            title: 'Қолданба туралы',
            subtitle: 'Нұсқасы v1.0.0',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutAppScreen()),
            ),
            isLast: true,
          ),
        ]),

        const SizedBox(height: 32),

        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton.icon(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout_rounded, color: kClay),
            label: Text(
              'Аккаунттан шығу',
              style: appBody(color: kClay, fontWeight: FontWeight.w700, fontSize: 15),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: kClay.withOpacity(0.4)),
              backgroundColor: kClayBg,
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
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Профиль',
            style: appBody(fontWeight: FontWeight.w700, fontSize: 20)),
        centerTitle: true,
      ),
      body: AppBackground(safeArea: false, child: SafeArea(child: content)),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: appBody(fontSize: 13, fontWeight: FontWeight.w700, color: kTextMuted, letterSpacing: 0.4),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return GlassCard(
      padding: EdgeInsets.zero,
      radius: 20,
      child: Column(
        children: children,
      ),
    );
  }
}

class _ProfileOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isLast;

  const _ProfileOptionTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: kBorder)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kAccentBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: kAccentLight, size: 20),
        ),
        title: Text(
          title,
          style: appBody(fontWeight: FontWeight.w600, fontSize: 15, color: kTextPrimary),
        ),
        subtitle: subtitle != null
            ? Text(
          subtitle!,
          style: appBody(fontSize: 12, color: kTextMuted),
        )
            : null,
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: kTextMuted,
        ),
      ),
    );
  }
}