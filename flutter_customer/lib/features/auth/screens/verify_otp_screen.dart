// verify_otp_screen.dart - OTP verification
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class VerifyOtpScreen extends ConsumerStatefulWidget {
  final String identifier;
  const VerifyOtpScreen({super.key, required this.identifier});
  @override
  ConsumerState<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends ConsumerState<VerifyOtpScreen> {
  final _otpCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _verify() async {
    if (_otpCtrl.text.length < 4) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التحقق من الهوية')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
                color: AppTheme.primaryLight.withOpacity(0.1),
                shape: BoxShape.circle),
            child: const Icon(Icons.sms_outlined,
                color: AppTheme.primaryLight, size: 40),
          ),
          const SizedBox(height: 24),
          Text('أدخل رمز التحقق', style: AppTheme.headingMd),
          const SizedBox(height: 8),
          Text('تم إرسال الرمز إلى ${widget.identifier}',
              style: AppTheme.bodyMd, textAlign: TextAlign.center),
          const SizedBox(height: 32),
          TextField(
            controller: _otpCtrl,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 12),
            decoration: InputDecoration(
              counterText: '',
              hintText: '------',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _loading ? null : _verify,
            child: _loading
                ? const CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5)
                : const Text('تحقق'),
          ),
          TextButton(
            onPressed: () => ref
                .read(authProvider.notifier)
                .resendOtp(widget.identifier, 'sms'),
            child: const Text('إعادة إرسال عبر SMS'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => ref
                .read(authProvider.notifier)
                .resendOtp(widget.identifier, 'whatsapp'),
            icon: const Icon(Icons.send_rounded, color: Colors.green),
            label: const Text('إرسال الرمز عبر WhatsApp',
                style: TextStyle(
                    color: Colors.green, fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.green),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ]),
      ),
    );
  }
}
