import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../l10n/locale_controller.dart';
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
        title: Text(AppLocalizations.of(context)!.logoutTitle, style: appBody(color: kTextPrimary, fontWeight: FontWeight.w700)),
        content: Text(AppLocalizations.of(context)!.logoutConfirm,
            style: appBody(color: kTextSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel, style: appBody(color: kTextMuted)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: kClay,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.logoutAction),
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
            : (email.contains('@') ? email.split('@')[0] : AppLocalizations.of(context)!.userFallback);

        return _buildContent(context, displayName, email);
      },
    );
  }

  Widget _buildContent(BuildContext context, String displayName, String email) {
    final content = ListView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 120),
      children: [
        if (embedded) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(AppLocalizations.of(context)!.profileTitle,
                    style: appDisplay(fontSize: 24, fontWeight: FontWeight.w700)),
              ),
              const _LanguageSwitcher(),
            ],
          ),
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

        _buildSectionTitle(AppLocalizations.of(context)!.personalSettings),
        const SizedBox(height: 10),
        _buildSettingsCard([
          _ProfileOptionTile(
            icon: Icons.person_outline_rounded,
            title: AppLocalizations.of(context)!.editData,
            subtitle: AppLocalizations.of(context)!.editDataSubtitle,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EditProfileScreen()),
            ),
          ),
          _ProfileOptionTile(
            icon: Icons.notifications_none_rounded,
            title: AppLocalizations.of(context)!.notifications,
            subtitle: AppLocalizations.of(context)!.notificationsSubtitle,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationsScreen()),
            ),
          ),
          _ProfileOptionTile(
            icon: Icons.lock_outline_rounded,
            title: AppLocalizations.of(context)!.security,
            subtitle: AppLocalizations.of(context)!.securitySubtitle,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SecurityScreen()),
            ),
            isLast: true,
          ),
        ]),

        const SizedBox(height: 24),

        _buildSectionTitle(AppLocalizations.of(context)!.appSection),
        const SizedBox(height: 10),
        _buildSettingsCard([
          _ProfileOptionTile(
            icon: Icons.help_outline_rounded,
            title: AppLocalizations.of(context)!.helpSupport,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
            ),
          ),
          _ProfileOptionTile(
            icon: Icons.info_outline_rounded,
            title: AppLocalizations.of(context)!.aboutApp,
            subtitle: AppLocalizations.of(context)!.appVersion('1.0.0'),
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
              AppLocalizations.of(context)!.logoutButton,
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
        title: Text(AppLocalizations.of(context)!.profileTitle,
            style: appBody(fontWeight: FontWeight.w700, fontSize: 20)),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(child: _LanguageSwitcher()),
          ),
        ],
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

/// Small pill button (globe icon + language code) that opens a menu to pick
/// the app's language. Reads/writes the language through [LocaleController],
/// so it works the same whether the profile screen is shown standalone or
/// embedded inside another tab.
///
/// Uses an imperative `showMenu()` call instead of `PopupMenuButton` on
/// purpose: `showMenu()`'s Future only completes once the menu's closing
/// animation has fully finished and its route has been removed. That lets us
/// apply the locale change strictly *after* the popup route is gone, instead
/// of mid-animation — which is what was causing the
/// "Looking up a deactivated widget's ancestor is unsafe" crash: the
/// `ValueListenableBuilder` around `MaterialApp` in main.dart rebuilds the
/// whole app (and its Overlay) as soon as the locale changes, and if that
/// happens while the popup's route is still animating out, the route's
/// `LayoutBuilder` ends up looking up an ancestor from an element that's
/// already been torn down.
class _LanguageSwitcher extends StatelessWidget {
  const _LanguageSwitcher();

  static const Map<String, String> _labels = {
    'kk': 'Қазақша',
    'ru': 'Русский',
    'en': 'English',
  };

  Future<void> _openMenu(BuildContext context, Locale currentLocale) async {
    final button = context.findRenderObject() as RenderBox;
    final overlayBox = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset(0, button.size.height + 6), ancestor: overlayBox),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlayBox),
      ),
      Offset.zero & overlayBox.size,
    );

    // This Future only resolves once the menu is fully closed (selection
    // animation included) — that's the key difference from PopupMenuButton.
    final selected = await showMenu<Locale>(
      context: context,
      position: position,
      color: kSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: kBorder),
      ),
      items: LocaleController.supportedLocales.map((locale) {
        final isSelected = locale.languageCode == currentLocale.languageCode;
        return PopupMenuItem<Locale>(
          value: locale,
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                size: 18,
                color: isSelected ? kAccentLight : kTextMuted,
              ),
              const SizedBox(width: 10),
              Text(
                _labels[locale.languageCode] ?? locale.languageCode,
                style: appBody(
                  fontSize: 14,
                  color: kTextPrimary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );

    if (selected != null) {
      LocaleController.setLocale(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LocaleController.locale,
      builder: (context, currentLocale, _) {
        return Builder(
          builder: (buttonContext) => GestureDetector(
            onTap: () => _openMenu(buttonContext, currentLocale),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: kAccentBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.language_rounded, size: 16, color: kAccentLight),
                  const SizedBox(width: 6),
                  Text(
                    currentLocale.languageCode.toUpperCase(),
                    style:
                    appBody(fontSize: 12.5, fontWeight: FontWeight.w700, color: kAccentLight),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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