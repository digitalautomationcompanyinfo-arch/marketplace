// provider_home_screen.dart - World-class provider dashboard like Uber Driver
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/dashboard_provider.dart';

class ProviderHomeScreen extends ConsumerStatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  ConsumerState<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends ConsumerState<ProviderHomeScreen> {
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(dashboardProvider.notifier).loadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    final dashState = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: RefreshIndicator(
        onRefresh: () => ref.read(dashboardProvider.notifier).loadDashboard(),
        child: CustomScrollView(
        slivers: [
          // ─── App Bar ──────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 160,
            backgroundColor: AppTheme.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // براند "كيف نخدمك"
                    Row(
                      children: [
                        Image.asset('assets/images/logo_icons.png', height: 28),
                        const SizedBox(width: 8),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('كيف نخدمك', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                            Text('How Can We Serve You', style: TextStyle(color: Colors.white70, fontSize: 8)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: const Text('م', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('مرحباً، مطعم البيت 👋', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                              Text(
                                _isOnline ? 'متصل - يمكن الآن استقبال الطلبات' : 'غير متصل - مؤقف الاستقبال',
                                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Online/Offline toggle
                    GestureDetector(
                      onTap: () => setState(() => _isOnline = !_isOnline),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: _isOnline ? AppTheme.accentColor : const Color(0xFFE74C3C),
                          borderRadius: AppTheme.radiusMd,
                          boxShadow: _isOnline ? AppTheme.shadowGreen : [
                            BoxShadow(color: AppTheme.errorColor.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10, height: 10,
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isOnline ? '🟢 متصل - اضغط للتوقف' : '🔴 متوقف - اضغط للبدء',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: dashState.isLoading
              ? const Padding(padding: EdgeInsets.all(50), child: Center(child: CircularProgressIndicator()))
              : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Stats Grid ────────────────────────
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12,
                    childAspectRatio: 1.7,
                    children: [
                      _buildStatCard('إجمالي الطلبات', '${dashState.stats?['totalOrders'] ?? 0}', '', Icons.receipt_long_outlined, const Color(0xFF2980B9)),
                      _buildStatCard('أرباح اليوم', '${dashState.stats?['totalRevenue'] ?? 0} ج.س', '', Icons.account_balance_wallet_outlined, const Color(0xFF27AE60)),
                      _buildStatCard('التقييم العام', '${dashState.stats?['averageRating'] ?? '5.0'} ⭐', '', Icons.star_outline, const Color(0xFFF39C12)),
                      _buildStatCard('إجمالي الزيارات', '${dashState.stats?['views'] ?? 0}', '', Icons.visibility_outlined, const Color(0xFF8E44AD)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ─── Quick Actions ─────────────────────
                  const Text('إجراءات سريعة', style: AppTheme.headingSm),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _QuickAction(icon: Icons.qr_code_2_outlined, label: 'كود الخاص بي', color: AppTheme.primaryLight, onTap: () => context.push('/provider/my-qr')),
                      const SizedBox(width: 12),
                      _QuickAction(icon: Icons.inventory_2_outlined, label: 'منتجاتي', color: AppTheme.accentColor, onTap: () => context.push('/provider/products')),
                      const SizedBox(width: 12),
                      _QuickAction(icon: Icons.bar_chart_outlined, label: 'التقارير', color: AppTheme.warningColor, onTap: () => context.push('/provider/analytics')),
                      const SizedBox(width: 12),
                      _QuickAction(icon: Icons.chat_outlined, label: 'الرسائل', color: AppTheme.primaryColor, onTap: () => context.push('/provider/messages')),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ─── Incoming Orders ───────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('الطلبات الواردة', style: AppTheme.headingSm),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_incomingOrders.where((o) => o['status'] == 'new').length} جديد',
                          style: const TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  ...dashState.incomingOrders.map((order) => _OrderCard(
                    order: order,
                    onAccept: () => ref.read(dashboardProvider.notifier).updateOrderStatus(order['id'], 'accepted'),
                    onReject: () => ref.read(dashboardProvider.notifier).updateOrderStatus(order['id'], 'cancelled'),
                  )),

                  const SizedBox(height: 24),

                  // ─── Revenue Summary ────────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryColor, AppTheme.primaryLight],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: AppTheme.radiusLg,
                      boxShadow: AppTheme.shadowLg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.trending_up, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text('ملخص الأسبوع', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text('${dashState.stats?['summary']?['total_revenue'] ?? 0} ج.س', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                        const Text('إجمالي الأرباح هذا الأسبوع', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _WeekStat('طلبات', '${dashState.stats?['summary']?['completed_orders'] ?? 0}'),
                            Container(width: 1, height: 30, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 16)),
                            _WeekStat('زيارات', '${dashState.stats?['views'] ?? 0}'),
                            Container(width: 1, height: 30, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 16)),
                            _WeekStat('التقييم', '${dashState.stats?['rating_avg'] ?? 0}'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white54),
                            minimumSize: const Size(double.infinity, 44),
                          ),
                          child: const Text('عرض التقرير التفصيلي'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String sub, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.radiusMd,
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(sub, style: TextStyle(fontSize: 10, color: color.withOpacity(0.8), fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppTheme.radiusMd,
            border: Border.all(color: AppTheme.borderColor),
            boxShadow: AppTheme.shadowSm,
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Map order;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  const _OrderCard({required this.order, required this.onAccept, required this.onReject});

  @override
  Widget build(BuildContext context) {
    final isNew = order['status'] == 'new';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.radiusMd,
        border: Border.all(color: isNew ? AppTheme.primaryLight.withOpacity(0.4) : AppTheme.borderColor),
        boxShadow: isNew ? AppTheme.shadowPrimary : AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isNew ? AppTheme.primaryColor : AppTheme.warningColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(
                  isNew ? Icons.new_releases_outlined : Icons.restaurant_outlined,
                  color: isNew ? Colors.white : AppTheme.warningColor, size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  isNew ? '🔔 طلب جديد!' : '🍳 جاري التحضير',
                  style: TextStyle(
                    color: isNew ? Colors.white : AppTheme.warningColor,
                    fontWeight: FontWeight.w800, fontSize: 14,
                  ),
                ),
                const Spacer(),
                Text(
                  order['id'] as String,
                  style: TextStyle(color: isNew ? Colors.white70 : AppTheme.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 16, color: AppTheme.textMuted),
                    const SizedBox(width: 6),
                    Text(order['user_name']?.toString() ?? 'عميل', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  (order['items'] as List?)?.map((i) => '${i['product_name']} × ${i['quantity']}').join('، ') ?? 'بدون منتجات', 
                  style: AppTheme.bodyMd
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _Badge(icon: Icons.attach_money, label: '${order['total_amount']} ج.س', color: AppTheme.accentColor),
                    const SizedBox(width: 10),
                    _Badge(icon: Icons.access_time, label: order['created_at']?.toString().substring(11, 16) ?? '', color: AppTheme.warningColor),
                  ],
                ),
                if (isNew) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onReject,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.errorColor,
                            side: const BorderSide(color: AppTheme.errorColor),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: const Text('رفض'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: onAccept,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentColor,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: const Text('قبول الطلب ✅'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Badge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _WeekStat extends StatelessWidget {
  final String label;
  final String value;
  const _WeekStat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
      ],
    );
  }
}

