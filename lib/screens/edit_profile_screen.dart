import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  bool _isLoading = false;

  User? get _user => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _user?.displayName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _getInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'U';
    final parts = trimmed.split(' ');
    if (parts.length > 1 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return trimmed[0].toUpperCase();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final newName = _nameController.text.trim();
      await _user?.updateDisplayName(newName);
      await _user?.reload();

      if (!mounted) return;
      Navigator.pop(context, true);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Қате: ${e.message}'), backgroundColor: kClay),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showPhotoComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Профиль суретін өзгерту жақын арада қолжетімді болады'),
        backgroundColor: kSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = _user?.email ?? '';
    final currentName = _nameController.text;

    return Scaffold(
      backgroundColor: const Color(0xFF03050A),
      body: AppBackground(
        safeArea: false,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: kTextPrimary, size: 18),
                      ),
                      Text(
                        'Деректерді өңдеу',
                        style: appDisplay(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: GestureDetector(
                      onTap: _showPhotoComingSoon,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 96,
                            height: 96,
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
                            alignment: Alignment.center,
                            child: Text(
                              _getInitials(currentName),
                              style: appDisplay(
                                  fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ),
                          Positioned(
                            right: -2,
                            bottom: -2,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: kSurface,
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF03050A), width: 3),
                              ),
                              child: const Icon(Icons.camera_alt_rounded,
                                  color: kAccentLight, size: 15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      'Суретті ауыстыру үшін басыңыз',
                      style: appBody(fontSize: 12, color: kTextMuted),
                    ),
                  ),
                  const SizedBox(height: 28),
                  GlassCard(
                    padding: const EdgeInsets.all(22),
                    radius: 26,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          onChanged: (_) => setState(() {}),
                          style: appBody(fontSize: 14.5),
                          decoration: appFieldDecoration(
                            'Аты-жөні',
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                          validator: (value) => (value == null || value.trim().isEmpty)
                              ? 'Атыңызды енгізіңіз'
                              : null,
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Email',
                          style: appBody(
                              fontSize: 12.5, color: kTextMuted, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: kBorder),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.email_outlined, color: kTextMuted, size: 19),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  email,
                                  style: appBody(fontSize: 14, color: kTextMuted),
                                ),
                              ),
                              const Icon(Icons.lock_outline_rounded, color: kTextMuted, size: 16),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.only(left: 2),
                          child: Text(
                            'Email өзгерту үшін қолдау қызметіне хабарласыңыз',
                            style: appBody(fontSize: 11, color: kTextMuted),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  GradientButton(
                    label: 'Сақтау',
                    loading: _isLoading,
                    onPressed: _isLoading ? null : _save,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
