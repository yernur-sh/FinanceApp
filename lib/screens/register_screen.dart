import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final credential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await credential.user?.updateDisplayName(_nameController.text.trim());
      await credential.user?.reload();

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'Бұл email тіркелген';
          break;
        case 'invalid-email':
          message = 'Email қате енгізілген';
          break;
        case 'weak-password':
          message = 'Құпия сөз тым әлсіз';
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
    // 🔴 ТҮЗЕТІЛДІ: AppBackground Scaffold-тың сыртына шығарылды, ал Scaffold фоны transparent болды
    return AppBackground(
      safeArea: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: kTextPrimary, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        gradient: kAccentGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: kAccent.withOpacity(0.4),
                            blurRadius: 26,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.person_add_alt_1_rounded,
                          size: 34, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Тіркелу',
                    textAlign: TextAlign.center,
                    style: appDisplay(fontSize: 26, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Жаңа аккаунт құрып бастаңыз',
                    textAlign: TextAlign.center,
                    style: appBody(color: kTextMuted, fontSize: 13.5),
                  ),
                  const SizedBox(height: 26),
                  GlassCard(
                    padding: const EdgeInsets.all(22),
                    radius: 26,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          style: appBody(fontSize: 14.5),
                          decoration: appFieldDecoration(
                            'Аты-жөні',
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                          validator: (value) => (value == null || value.isEmpty)
                              ? 'Атыңызды енгізіңіз'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: appBody(fontSize: 14.5),
                          decoration: appFieldDecoration(
                            'Email',
                            prefixIcon: const Icon(Icons.email_outlined),
                          ),
                          validator: (value) {
                            if (value == null || !value.contains('@')) {
                              return 'Дұрыс email енгізіңіз';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          style: appBody(fontSize: 14.5),
                          decoration: appFieldDecoration(
                            'Құпия сөз',
                            prefixIcon: const Icon(Icons.lock_outline),
                          ),
                          validator: (value) {
                            if (value == null || value.length < 6) {
                              return 'Кемінде 6 таңба болу керек';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmController,
                          obscureText: true,
                          style: appBody(fontSize: 14.5),
                          decoration: appFieldDecoration(
                            'Құпия сөзді қайталаңыз',
                            prefixIcon: const Icon(Icons.lock_outline),
                          ),
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return 'Құпия сөздер сәйкес келмейді';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        GradientButton(
                          label: 'Тіркелу',
                          loading: _isLoading,
                          onPressed: _isLoading ? null : _register,
                        ),
                      ],
                    ),
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