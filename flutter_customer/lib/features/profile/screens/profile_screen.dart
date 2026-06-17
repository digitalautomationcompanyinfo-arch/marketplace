import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Header
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    child:
                        const Icon(Icons.person, size: 50, color: Colors.grey),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                          color: Colors.blue, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt,
                          size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?['full_name'] ?? 'مستخدم',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              user?['phone'] ?? user?['email'] ?? '',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),

            // Menu Items
            _buildMenuItem(
              icon: Icons.assignment_outlined,
              title: 'طلباتي',
              onTap: () => context.push('/orders'),
            ),
            _buildMenuItem(
              icon: Icons.shopping_cart_outlined,
              title: 'سلة التسوق',
              onTap: () => context.push('/cart'),
            ),
            _buildMenuItem(
              icon: Icons.account_balance_wallet_outlined,
              title: 'المحفظة',
              onTap: () => context.push('/wallet'),
            ),
            _buildMenuItem(
              icon: Icons.notifications_none,
              title: 'الإشعارات',
              onTap: () => context.push('/notifications'),
            ),
            _buildMenuItem(
              icon: Icons.favorite_border,
              title: 'المفضلة',
              onTap: () {},
            ),
            const Divider(),
            _buildMenuItem(
              icon: Icons.help_outline,
              title: 'مركز المساعدة الذكي 🇸🇩',
              onTap: () => context.push('/support'),
            ),
            _buildMenuItem(
              icon: Icons.info_outline,
              title: 'عن التطبيق',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
