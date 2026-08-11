import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = AppLocalizations.of(context)!.userNotFound;
          break;
        case 'wrong-password':
          message = AppLocalizations.of(context)!.wrongPassword;
          break;
        case 'invalid-email':
          message = AppLocalizations.of(context)!.invalidEmail;
          break;
        case 'invalid-credential':
          message = AppLocalizations.of(context)!.invalidCredential;
          break;
        default:
          message = AppLocalizations.of(context)!.errorWithMessage(e.message ?? '');
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: kClay,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF03050A),
      body: AppBackground(
        safeArea: false,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          gradient: kAccentGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: kAccent.withOpacity(0.4),
                              blurRadius: 30,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.account_balance_wallet_rounded,
                            size: 38, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      AppLocalizations.of(context)!.loginTitle,
                      textAlign: TextAlign.center,
                      style: appDisplay(fontSize: 28, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppLocalizations.of(context)!.loginSubtitle,
                      textAlign: TextAlign.center,
                      style: appBody(color: kTextMuted, fontSize: 13.5),
                    ),
                    const SizedBox(height: 30),
                    GlassCard(
                      padding: const EdgeInsets.all(22),
                      radius: 26,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: appBody(fontSize: 14.5),
                            decoration: appFieldDecoration(
                              AppLocalizations.of(context)!.emailLabel,
                              prefixIcon: const Icon(Icons.email_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppLocalizations.of(context)!.emailRequired;
                              }
                              if (!value.contains('@')) {
                                return AppLocalizations.of(context)!.emailInvalid;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: appBody(fontSize: 14.5),
                            decoration: appFieldDecoration(
                              AppLocalizations.of(context)!.passwordLabel,
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: kTextSecondary,
                                ),
                                onPressed: () {
                                  setState(
                                          () => _obscurePassword = !_obscurePassword);
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.length < 6) {
                                return AppLocalizations.of(context)!.passwordTooShort;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          GradientButton(
                            label: AppLocalizations.of(context)!.loginTitle,
                            loading: _isLoading,
                            onPressed: _isLoading ? null : _login,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: Text(
                        AppLocalizations.of(context)!.noAccountRegister,
                        style: appBody(
                            color: kAccentLight, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}