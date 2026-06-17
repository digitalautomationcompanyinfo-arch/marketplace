import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../dashboard/providers/dashboard_provider.dart';

class EarningsScreen extends ConsumerWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);
    final stats = dashboard.stats;
    final profile = dashboard.providerProfile;
    final transactions = dashboard.walletTransactions;

    final balance = (profile?['wallet_balance'] as num?)?.toDouble() ?? 0.0;
    final totalRevenue =
        (stats?['summary']?['total_revenue'] as num?)?.toDouble() ?? 0.0;
    final completedOrders =
        stats?['summary']?['completed_orders']?.toString() ?? '0';

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: const Text('الأرباح والتقارير'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
      ),
      body: dashboard.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(dashboardProvider.notifier).loadDashboard(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Current Balance
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.primaryLight
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: AppTheme.radiusLg,
                        boxShadow: AppTheme.shadowMd,
                      ),
                      child: Column(
                        children: [
                          const Text('الرصيد المتاح للسحب',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 16)),
                          const SizedBox(height: 12),
                          Text(
                            '${balance.toStringAsFixed(2)} ج.س',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'سيتم تفعيل ميزة طلب السحب قريباً')));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppTheme.primaryColor,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('طلب سحب الأرباح',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Summary Row
                    Row(
                      children: [
                        _buildSummaryCard(
                            'إجمالي الأرباح',
                            '${totalRevenue.toStringAsFixed(0)} ج.س',
                            Icons.trending_up,
                            Colors.green),
                        const SizedBox(width: 16),
                        _buildSummaryCard('الطلبات المكتملة', completedOrders,
                            Icons.check_circle_outline, Colors.blue),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Recent Transactions
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text('سجل العمليات الأخير',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),

                    if (transactions.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Text('لا توجد عمليات مسجلة حالياً',
                              style: TextStyle(color: AppTheme.textMuted)),
                        ),
                      )
                    else
                      ...transactions.map((t) => _buildTransactionTile(t)),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppTheme.radiusMd,
          border: Border.all(color: AppTheme.borderColor),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(title,
                style: const TextStyle(
                    fontSize: 14, color: AppTheme.textSecondary)),
            const SizedBox(height: 4),
            Text(value,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTile(Map<String, dynamic> t) {
    final type = t['type'] ?? '';
    final isIncome =
        ['payout', 'admin_adjustment', 'conversion'].contains(type);
    final amount = (t['amount'] as num?)?.toDouble() ?? 0.0;
    final date = t['created_at']?.toString().split('T')[0] ?? '';
    final notes = t['notes'] ?? (isIncome ? 'ربح مضاف' : 'خصم من الرصيد');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.radiusMd,
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isIncome
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            child: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: isIncome ? Colors.green : Colors.red),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notes,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(date,
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 11)),
              ],
            ),
          ),
          Text('${isIncome ? "+" : "-"}${amount.abs().toStringAsFixed(2)} ج.س',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isIncome ? Colors.green : Colors.red)),
        ],
      ),
    );
  }
}
