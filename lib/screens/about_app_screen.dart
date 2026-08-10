import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

// TODO: осы үшеуін нақты мәндермен ауыстырыңыз
const String _kPrivacyPolicyUrl = 'https://kipy.app/privacy';
const String _kTermsUrl = 'https://kipy.app/terms';
const String _kAppStoreId = '0000000000'; // App Store-дағы нақты app ID
const String _kAndroidPackageName = 'com.example.finance_app'; // Play Market applicationId

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Сілтемені ашу мүмкін болмады'),
          backgroundColor: kClay,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
    }
  }

  Future<void> _openStoreListing(BuildContext context) async {
    final url = (!kIsWeb && Platform.isIOS)
        ? 'https://apps.apple.com/app/id$_kAppStoreId'
        : 'https://play.google.com/store/apps/details?id=$_kAndroidPackageName';
    await _openUrl(context, url);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF03050A),
      body: AppBackground(
        safeArea: false,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: kTextPrimary, size: 18),
                  ),
                  Text(
                    'Қолданба туралы',
                    style: appDisplay(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        gradient: kAccentGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: kAccent.withOpacity(0.4),
                            blurRadius: 30,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.account_balance_wallet_rounded,
                          size: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Қаржылай сауаттылық',
                      style: appDisplay(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Нұсқасы v1.0.0',
                      style: appBody(fontSize: 13, color: kTextMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              GlassCard(
                radius: 22,
                child: Text(
                  'Бұл қолданба сіздің күнделікті кірістеріңіз бен шығыстарыңызды бақылауға, '
                      'бюджет орнатуға және қаржылай мақсаттарға жетуге көмектеседі. Барлық '
                      'деректеріңіз қауіпсіз түрде сақталады және тек сізге ғана қолжетімді.',
                  style: appBody(fontSize: 13.5, color: kTextSecondary, height: 1.6),
                ),
              ),
              const SizedBox(height: 20),
              GlassCard(
                padding: EdgeInsets.zero,
                radius: 20,
                child: Column(
                  children: [
                    _InfoTile(
                      icon: Icons.description_outlined,
                      title: 'Пайдалану шарттары',
                      onTap: () => _openUrl(context, _kTermsUrl),
                    ),
                    const Divider(height: 1, color: kBorder),
                    _InfoTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Құпиялылық саясаты',
                      onTap: () => _openUrl(context, _kPrivacyPolicyUrl),
                    ),
                    const Divider(height: 1, color: kBorder),
                    _InfoTile(
                      icon: Icons.star_outline_rounded,
                      title: 'Қолданбаны бағалау',
                      onTap: () => _openStoreListing(context),
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Center(
                child: Text(
                  '© 2026 Kipy. Барлық құқықтар қорғалған.',
                  style: appBody(fontSize: 11.5, color: kTextMuted),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isLast;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: kAccentBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: kAccentLight, size: 20),
      ),
      title: Text(title,
          style: appBody(fontWeight: FontWeight.w600, fontSize: 14.5, color: kTextPrimary)),
      trailing: const Icon(Icons.chevron_right_rounded, color: kTextMuted),
    );
  }
}