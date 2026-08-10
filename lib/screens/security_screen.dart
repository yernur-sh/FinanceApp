import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  User? get _user => FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _user?.email;
    if (email == null) return;

    setState(() => _isLoading = true);

    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: _currentPasswordController.text,
      );
      await _user!.reauthenticateWithCredential(credential);
      await _user!.updatePassword(_newPasswordController.text);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Құпия сөз сәтті өзгертілді'),
          backgroundColor: kGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Қазіргі құпия сөз қате';
          break;
        case 'weak-password':
          message = 'Жаңа құпия сөз тым әлсіз';
          break;
        case 'requires-recent-login':
          message = 'Қауіпсіздік үшін қайта кіру қажет. Шығып, қайта кіріңіз';
          break;
        case 'too-many-requests':
          message = 'Тым көп әрекет жасалды. Сәл кейін қайталаңыз';
          break;
        default:
          message = 'Қате: ${e.message}';
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: kClay),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEmailAccount = _user?.providerData
            .any((p) => p.providerId == 'password') ??
        false;

    return Scaffold(
      backgroundColor: const Color(0xFF03050A),
      body: AppBackground(
        safeArea: false,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
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
                      'Қауіпсіздік',
                      style: appDisplay(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Center(
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      gradient: kAccentGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: kAccent.withOpacity(0.35),
                          blurRadius: 26,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.lock_outline_rounded,
                        size: 32, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 24),

                if (!isEmailAccount)
                  GlassCard(
                    radius: 22,
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: kAmber, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Сіздің аккаунтыңыз email/құпия сөз арқылы емес, басқа провайдер арқылы тіркелген. Құпия сөзді осы жерден өзгерту мүмкін емес.',
                            style: appBody(fontSize: 13, color: kTextSecondary, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Form(
                    key: _formKey,
                    child: GlassCard(
                      padding: const EdgeInsets.all(22),
                      radius: 26,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Құпия сөзді өзгерту',
                            style: appBody(
                                fontSize: 15, fontWeight: FontWeight.w700, color: kTextPrimary),
                          ),
                          const SizedBox(height: 18),
                          TextFormField(
                            controller: _currentPasswordController,
                            obscureText: _obscureCurrent,
                            style: appBody(fontSize: 14.5),
                            decoration: appFieldDecoration(
                              'Қазіргі құпия сөз',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureCurrent ? Icons.visibility_off : Icons.visibility,
                                  color: kTextSecondary,
                                ),
                                onPressed: () =>
                                    setState(() => _obscureCurrent = !_obscureCurrent),
                              ),
                            ),
                            validator: (value) => (value == null || value.isEmpty)
                                ? 'Қазіргі құпия сөзді енгізіңіз'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _newPasswordController,
                            obscureText: _obscureNew,
                            style: appBody(fontSize: 14.5),
                            decoration: appFieldDecoration(
                              'Жаңа құпия сөз',
                              prefixIcon: const Icon(Icons.lock_reset_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureNew ? Icons.visibility_off : Icons.visibility,
                                  color: kTextSecondary,
                                ),
                                onPressed: () => setState(() => _obscureNew = !_obscureNew),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.length < 6) {
                                return 'Кемінде 6 таңба болу керек';
                              }
                              if (value == _currentPasswordController.text) {
                                return 'Жаңа құпия сөз ескісінен өзгеше болуы керек';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirm,
                            style: appBody(fontSize: 14.5),
                            decoration: appFieldDecoration(
                              'Жаңа құпия сөзді қайталаңыз',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                                  color: kTextSecondary,
                                ),
                                onPressed: () =>
                                    setState(() => _obscureConfirm = !_obscureConfirm),
                              ),
                            ),
                            validator: (value) {
                              if (value != _newPasswordController.text) {
                                return 'Құпия сөздер сәйкес келмейді';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          GradientButton(
                            label: 'Құпия сөзді сақтау',
                            loading: _isLoading,
                            onPressed: _isLoading ? null : _changePassword,
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
