import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    // تسجيل الدخول الحقيقي
    await ref.read(authProvider.notifier).login(
          _identifier.text.trim(),
          _password.text,
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

    return Material(
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 48),
                    Center(
                        child: Image.asset('assets/images/logo_primary.png',
                            height: 150)),
                    const SizedBox(height: 12),
                    const Text('كيف نخدمك',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A3C5E))),
                    const Text('تسجيل الدخول',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 48),
                    TextFormField(
                      controller: _identifier,
                      textDirection: TextDirection.rtl,
                      keyboardType: TextInputType.phone,
                      decoration: _inputDeco('رقم الهاتف أو البريد الإلكتروني',
                          Icons.person_outline),
                      validator: (v) => v!.isEmpty
                          ? 'يجب إدخال رقم الهاتف أو البريد الإلكتروني'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _password,
                      obscureText: _obscure,
                      decoration: _inputDeco('كلمة المرور', Icons.lock_outline)
                          .copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(_obscure
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) =>
                          v!.isEmpty ? 'يجب إدخال كلمة المرور' : null,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                          onPressed: () {},
                          child: const Text('نسيت كلمة المرور؟')),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A3C5E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: state.isLoading ? null : _login,
                        child: state.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text('تسجيل الدخول',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Row(children: [
                      Expanded(child: Divider()),
                      SizedBox(width: 8),
                      Text('أو', style: TextStyle(color: Colors.grey)),
                      SizedBox(width: 8),
                      Expanded(child: Divider()),
                    ]),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {},
                      icon: const Icon(Icons.g_mobiledata,
                          size: 24, color: Colors.red),
                      label: const Text('المتابعة بـ Google'),
                    ),
                    const SizedBox(height: 24),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Text('ليس لديك حساب؟'),
                      TextButton(
                        onPressed: () => context.push('/auth/register'),
                        child: const Text('إنشاء حساب جديد',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ]),
                  ]),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );
}
