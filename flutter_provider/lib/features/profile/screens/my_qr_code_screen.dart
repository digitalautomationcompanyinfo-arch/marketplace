import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_theme.dart';
import '../../dashboard/providers/dashboard_provider.dart';

class MyQrCodeScreen extends ConsumerWidget {
  const MyQrCodeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashState = ref.watch(dashboardProvider);
    final profile = dashState.providerProfile;
    final qrUrl = profile?['qr_code_url'];
    final publicUrl = profile?['public_url'];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('كود QR الموحد',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A3C5E), Color(0xFF2C3E50)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
            child: Column(
              children: [
                // Premium Branded Card
                Container(
                  padding: const EdgeInsets.all(2), // Border size
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                        colors: [Colors.amber, Colors.orangeAccent]),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      children: [
                        // Sudanese Themed Header
                        Image.asset('assets/images/logo_icons.png', height: 40),
                        const SizedBox(height: 8),
                        const Text(
                          'كيف نخدمك',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1A3C5E),
                              letterSpacing: 1.2),
                        ),
                        const Text('سودان - السودان (Sudan)',
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                        const Divider(height: 32, color: Colors.amberAccent),

                        // Provider Info
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.grey[100],
                          backgroundImage: profile?['logo_url'] != null
                              ? NetworkImage(profile?['logo_url'])
                              : null,
                          child: profile?['logo_url'] == null
                              ? const Icon(Icons.store, color: Colors.blue)
                              : null,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          profile?['business_name'] ?? 'مزود خدمة',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),

                        // QR Code
                        if (qrUrl != null)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey[200]!, width: 2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Image.network(
                              qrUrl,
                              width: 200,
                              height: 200,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const SizedBox(
                                    width: 200,
                                    height: 200,
                                    child: Center(
                                        child: CircularProgressIndicator()));
                              },
                            ),
                          )
                        else
                          const SizedBox(
                              width: 200,
                              height: 200,
                              child:
                                  Center(child: CircularProgressIndicator())),

                        const SizedBox(height: 24),
                        const Text(
                          'امسح الكود للطلب المباشر أو زيارة المتجر',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Share Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (publicUrl != null)
                        Share.share(
                            'تفضل بزيارة متجري على تطبيق "كيف نخدمك": $publicUrl');
                    },
                    icon: const Icon(Icons.share_rounded, color: Colors.white),
                    label: const Text('مشاركة رابط المتجر',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[700],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 5,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                // FIX MEDIUM-7: Download QR image and save/share it (was empty no-op)
                TextButton.icon(
                  onPressed: qrUrl == null
                      ? null
                      : () async {
                          try {
                            final tempDir = await getTemporaryDirectory();
                            final filePath = '${tempDir.path}/qr_code.png';
                            await Dio().download(qrUrl, filePath);
                            await Share.shareXFiles(
                              [XFile(filePath, mimeType: 'image/png')],
                              text: 'كود QR الخاص بمتجري على تطبيق "كيف نخدمك"',
                            );
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('تعذر حفظ الصورة')),
                              );
                            }
                          }
                        },
                  icon: const Icon(Icons.save_alt, color: Colors.white70),
                  label: const Text('حفظ و مشاركة صورة QR',
                      style: TextStyle(color: Colors.white70)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
