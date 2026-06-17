import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';

class ProviderLoginScreen extends ConsumerStatefulWidget {
  const ProviderLoginScreen({super.key});
  @override
  ConsumerState<ProviderLoginScreen> createState() =>
      _ProviderLoginScreenState();
}

class _ProviderLoginScreenState extends ConsumerState<ProviderLoginScreen> {
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const SizedBox(height: 48),
            const SizedBox(height: 24),
            Center(
                child:
                    Image.asset('assets/images/logo_primary.png', height: 150)),
            const SizedBox(height: 16),
            const Text('بوابة مزود الخدمة',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A3C5E))),
            const Text('أدر نشاطك التجاري بكل سهولة',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 48),
            TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                    labelText: 'رقم الهاتف',
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 16),
            TextField(
                controller: _password,
                obscureText: _obscure,
                decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    suffixIcon: IconButton(
                        icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility),
                        onPressed: () =>
                            setState(() => _obscure = !_obscure)))),
            const SizedBox(height: 28),
            SizedBox(
                height: 52,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A3C5E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    onPressed: authState.isLoading
                        ? null
                        : () async {
                            await ref
                                .read(authProvider.notifier)
                                .login(_phone.text, _password.text);
                            if (mounted && ref.read(authProvider).isLoggedIn) {
                              context.go('/dashboard');
                            } else if (ref.read(authProvider).error != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text(ref.read(authProvider).error!)));
                            }
                          },
                    child: authState.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('دخول',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)))),
          ]),
        ),
      ),
    );
  }
}
