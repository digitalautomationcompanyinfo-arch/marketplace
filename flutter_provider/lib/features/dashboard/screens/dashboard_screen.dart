import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';

class ProviderDashboardScreen extends ConsumerWidget {
  const ProviderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        backgroundColor: const Color(0xFF1A3C5E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
              icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Greeting ─────────────────────────────
              const Text('أهلاً بك مجدداً،',
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
              const Text('كيف العمل اليوم؟ ✋',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A3C5E))),
              const SizedBox(height: 24),

              // ─── Performance Row (At-a-glance) ────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05), blurRadius: 10)
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _SimpleStat(
                        icon: Icons.visibility,
                        label: 'مشاهدات',
                        value: '1.2k',
                        color: Colors.blue),
                    _SimpleStat(
                        icon: Icons.star,
                        label: 'تقييمك',
                        value: '4.8',
                        color: Colors.amber),
                    _SimpleStat(
                        icon: Icons.account_balance_wallet,
                        label: 'أرباحك',
                        value: '85k',
                        color: Colors.green),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ─── Bids Inbox Highlight ──────────────────
              const _BidsInboxCard(count: 3),

              const SizedBox(height: 24),

              // ─── روابط سريعة ───────────────────────────
              const Text('إجراءات سريعة',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _QuickAction(
                      icon: Icons.add_box,
                      label: 'إضافة منتج',
                      onTap: () => context.push('/products/add')),
                  _QuickAction(
                      icon: Icons.list_alt,
                      label: 'الطلبات',
                      onTap: () => context.push('/orders')),
                  _QuickAction(
                      icon: Icons.gavel_outlined,
                      label: 'المناقصات',
                      onTap: () => context.push('/tendering/feed')),
                  _QuickAction(
                      icon: Icons.bar_chart,
                      label: 'الإحصاءات',
                      onTap: () => context.push('/stats')),
                  _QuickAction(
                      icon: Icons.chat_outlined,
                      label: 'المحادثات',
                      onTap: () => context.push('/conversations')),
                  _QuickAction(
                      icon: Icons.qr_code_scanner,
                      label: 'كودي QR',
                      onTap: () => context.push('/provider/my-qr')),
                  _QuickAction(
                      icon: Icons.settings, label: 'الإعدادات', onTap: () {}),
                ],
              ),

              const SizedBox(height: 24),

              // ─── آخر المنتجات ──────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('آخر المنتجات',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  TextButton(
                      onPressed: () => context.push('/products'),
                      child: const Text('عرض الكل')),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _ProviderBottomNav(),
    );
  }
}

class _SimpleStat extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _SimpleStat(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(value,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      );
}

class _BidsInboxCard extends StatelessWidget {
  final int count;
  const _BidsInboxCard({required this.count});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF27AE60), Color(0xFF2ECC71)]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          const Icon(Icons.mail_outline, color: Colors.white, size: 32),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('فرص عمل جديدة!',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                Text('هناك $count طلبات مخصصة تنتظر عرضك الآن',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 12)),
              ])),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, foregroundColor: Colors.green),
            onPressed: () => context.push('/tendering/feed'),
            child: const Text('افتح الآن'),
          ),
        ]),
      );
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  final String? badge;
  const _StatCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color,
      this.badge});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, color: color, size: 28),
            const Spacer(),
            if (badge != null)
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10)),
                  child: Text(badge!,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 11))),
          ]),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ]),
      );
}

class _SubscriptionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF1A3C5E), Color(0xFF2980B9)]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          const Icon(Icons.verified, color: Colors.amber, size: 36),
          const SizedBox(width: 12),
          const Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('الاشتراك الشهري المميز',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                Text('ينتهي في: 15 فبراير 2025',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ])),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber, foregroundColor: Colors.black),
            onPressed: () => context.push('/subscription'),
            child: const Text('تجديد'),
          ),
        ]),
      );
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Column(children: [
            Icon(icon, color: const Color(0xFF2980B9), size: 28),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center),
          ]),
        ),
      );
}

class _ProviderBottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) => NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (i) {
          final routes = [
            '/dashboard',
            '/products',
            '/messages',
            '/stats',
            '/profile'
          ];
          context.go(routes[i]);
        },
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'الرئيسية'),
          NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              selectedIcon: Icon(Icons.inventory_2),
              label: 'المنتجات'),
          NavigationDestination(
              icon: Icon(Icons.chat_outlined),
              selectedIcon: Icon(Icons.chat),
              label: 'الرسائل'),
          NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: 'الإحصاءات'),
          NavigationDestination(
              icon: Icon(Icons.store_outlined),
              selectedIcon: Icon(Icons.store),
              label: 'الملف'),
        ],
      );
}
