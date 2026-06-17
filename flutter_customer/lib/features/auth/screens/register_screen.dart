// register_screen.dart - World-class registration
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authProvider.notifier).register(
          _nameCtrl.text.trim(),
          _phoneCtrl.text.trim(),
          _passCtrl.text,
        );

    if (!mounted) return;
    final state = ref.read(authProvider);
    if (state.isLoggedIn) {
      context.go('/home');
    } else if (state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: AppTheme.textPrimary),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('إنشاء حساب جديد', style: AppTheme.headingXl),
              const SizedBox(height: 8),
              Text('انضم إلى آلاف المستخدمين', style: AppTheme.bodyMd),
              const SizedBox(height: 36),
              TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                      labelText: 'الاسم الكامل',
                      prefixIcon: Icon(Icons.person_outline)),
                  validator: (v) => v!.isEmpty ? 'أدخل اسمك' : null),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                      labelText: 'رقم الهاتف',
                      prefixIcon: Icon(Icons.phone_outlined)),
                  validator: (v) => v!.isEmpty ? 'أدخل رقم الهاتف' : null),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                      labelText: 'كلمة المرور',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                          icon: Icon(_obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () =>
                              setState(() => _obscure = !_obscure))),
                  validator: (v) =>
                      v!.length < 6 ? 'كلمة المرور قصيرة جداً' : null),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: state.isLoading ? null : _register,
                child: state.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : const Text('إنشاء الحساب'),
              ),
              const SizedBox(height: 24),
              Center(
                  child: TextButton(
                onPressed: () => context.go('/auth/login'),
                child: const Text('لدي حساب بالفعل - تسجيل الدخول'),
              )),
            ]),
          ),
        ),
      ),
    );
  }
}
