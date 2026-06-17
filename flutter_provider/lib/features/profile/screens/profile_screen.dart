import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProviderProfileScreen extends ConsumerWidget {
  const ProviderProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('الملف الشخصي والمحفظة'),
        backgroundColor: const Color(0xFF1A3C5E),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStoreInfoCard(),
            const SizedBox(height: 16),
            _buildWalletCard(),
            const SizedBox(height: 16),
            _buildSettingsMenu(),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)]),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration:
                BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
            child: const Icon(Icons.store, size: 40, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('متجر الأناقة',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('تصنيف: خدمات الصيانة',
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    Text(' 4.7 (120 تقييم)',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF2980B9)),
              onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildWalletCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF2980B9), Color(0xFF1A3C5E)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('الرصيد المتاح',
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
              Icon(Icons.account_balance_wallet, color: Colors.white70),
            ],
          ),
          const SizedBox(height: 8),
          const Text('4,520.00 ج.س',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1A3C5E)),
                  onPressed: () {},
                  icon: const Icon(Icons.money),
                  label: const Text('سحب الرصيد',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54)),
                  onPressed: () {},
                  icon: const Icon(Icons.history),
                  label: const Text('السجل'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsMenu() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)]),
      child: Column(
        children: [
          _buildMenuItem(
              Icons.workspace_premium, 'باقة الاشتراك (نشطة)', () {}),
          const Divider(height: 1),
          _buildMenuItem(
              Icons.business_center, 'إدارة الخدمات والمنتجات', () {}),
          const Divider(height: 1),
          _buildMenuItem(Icons.store, 'إدارة الفروع (Phase 68)', () {
            // Navigator.push(context, MaterialPageRoute(builder: (c) => const BranchesScreen()));
          }),
          const Divider(height: 1),
          _buildMenuItem(Icons.calendar_month, 'جدول المواعيد (Phase 69)', () {
            // Navigator.push(context, MaterialPageRoute(builder: (c) => const BookingCalendarScreen()));
          }),
          const Divider(height: 1),
          _buildMenuItem(Icons.access_time_filled, 'ضبط التوفر (Phase 69)', () {
            // Navigator.push(context, MaterialPageRoute(builder: (c) => const AvailabilitySettingsScreen()));
          }),
          const Divider(height: 1),
          _buildMenuItem(Icons.location_on, 'مناطق التغطية', () {}),
          const Divider(height: 1),
          _buildMenuItem(Icons.access_time, 'أوقات العمل', () {}),
          const Divider(height: 1),
          _buildMenuItem(Icons.notifications, 'إعدادات الإشعارات', () {}),
          const Divider(height: 1),
          _buildMenuItem(Icons.headset_mic, 'الدعم الفني', () {}),
          const Divider(height: 1),
          _buildMenuItem(Icons.logout, 'تسجيل الخروج', () {},
              isDestructive: true),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap,
      {bool isDestructive = false}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red.withOpacity(0.1)
                : const Color(0xFF2980B9).withOpacity(0.1),
            shape: BoxShape.circle),
        child: Icon(icon,
            color: isDestructive ? Colors.red : const Color(0xFF2980B9),
            size: 20),
      ),
      title: Text(title,
          style: TextStyle(
              color: isDestructive ? Colors.red : Colors.black87,
              fontWeight: FontWeight.bold)),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }
}
