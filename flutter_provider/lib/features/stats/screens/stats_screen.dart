import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import 'package:intl/intl.dart' as intl;

class ProviderStatsScreen extends ConsumerStatefulWidget {
  const ProviderStatsScreen({super.key});

  @override
  ConsumerState<ProviderStatsScreen> createState() =>
      _ProviderStatsScreenState();
}

class _ProviderStatsScreenState extends ConsumerState<ProviderStatsScreen> {
  @override
  void initState() {
    super.initState();
    // Dashboard loads everything on init, but we can refresh here if needed
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);
    final stats = state.stats;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('الإحصاءات والتقارير'),
        backgroundColor: const Color(0xFF1A3C5E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(dashboardProvider.notifier).loadDashboard(),
          ),
        ],
      ),
      body: state.isLoading && stats == null
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text(state.error!))
              : _buildBody(stats!),
    );
  }

  Widget _buildBody(Map<String, dynamic> stats) {
    final chartData = (stats['chartData'] as List? ?? []);
    final topProducts = (stats['topProducts'] as List? ?? []);
    final summary = stats['summary'] as Map? ?? {};

    return RefreshIndicator(
      onRefresh: () => ref.read(dashboardProvider.notifier).loadDashboard(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ─── فلتر الفترة الزمنية ──────────────────────
          _buildFilters(),
          const SizedBox(height: 24),

          // ─── رسم بياني الإيرادات (كان المشاهدات) ────────────────
          _SectionTitle('إيرادات آخر 7 أيام (ج.س)'),
          const SizedBox(height: 12),
          _ChartCard(
            child: chartData.isEmpty
                ? const Center(child: Text('لا توجد بيانات كافية'))
                : BarChart(_buildBarData(chartData)),
          ),

          const SizedBox(height: 24),

          // ─── أداء المنتجات ────────────────────────
          _SectionTitle('أعلى 5 منتجات مبيعاً'),
          const SizedBox(height: 12),
          _ChartCard(
            height: 220,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topProducts.length,
              itemBuilder: (context, i) {
                final p = topProducts[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                          child: Text(p['name'],
                              style: const TextStyle(fontSize: 13))),
                      Text('${p['total_sold']} مبيعات',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2980B9))),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // ─── توزيع التقييمات ──────────────────────────
          _SectionTitle('نظرة عامة على التقييمات'),
          const SizedBox(height: 12),
          _ChartCard(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                    label: 'المتوسط',
                    value: '${stats['rating_avg']} ⭐',
                    color: Colors.orange),
                _StatItem(
                    label: 'الإجمالي',
                    value: '${stats['rating_count']}',
                    color: Colors.blue),
                _StatItem(
                    label: 'المشاهدات',
                    value: '${stats['views']}',
                    color: Colors.purple),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ─── بطاقات الملخص ───────────────────────────
          _SectionTitle('ملخص الأداء'),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _MiniStat(
                  label: 'إجمالي الطلبات',
                  value: '${summary['total_orders'] ?? 0}',
                  icon: Icons.shopping_bag,
                  color: const Color(0xFF2980B9)),
              _MiniStat(
                  label: 'طلبات مكتملة',
                  value: '${summary['completed_orders'] ?? 0}',
                  icon: Icons.check_circle,
                  color: const Color(0xFF27AE60)),
              _MiniStat(
                  label: 'طلبات ملغاة',
                  value: '${summary['cancelled_orders'] ?? 0}',
                  icon: Icons.cancel,
                  color: const Color(0xFFE74C3C)),
              _MiniStat(
                  label: 'الرسائل',
                  value: '${stats['total_conversations'] ?? 0}',
                  icon: Icons.chat,
                  color: const Color(0xFF8E44AD)),
            ],
          ),

          const SizedBox(height: 32),
        ]),
      ),
    );
  }

  BarChartData _buildBarData(List chartData) {
    return BarChartData(
      gridData: const FlGridData(show: false),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
            sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (v, _) {
            if (v.toInt() >= chartData.length) return const Text('');
            final date = DateTime.parse(chartData[v.toInt()]['date']);
            return Text(intl.DateFormat('E', 'ar').format(date),
                style: const TextStyle(fontSize: 10));
          },
        )),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      barGroups: chartData.asMap().entries.map((e) {
        final revenue = double.tryParse(e.value['revenue'].toString()) ?? 0;
        return BarChartGroupData(x: e.key, barRods: [
          BarChartRodData(
              toY: revenue,
              color: const Color(0xFF2980B9),
              width: 22,
              borderRadius: BorderRadius.circular(4)),
        ]);
      }).toList(),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
          children: ['آخر 7 أيام', 'آخر 30 يوم', 'هذا العام']
              .map((label) => Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: label == 'آخر 7 أيام'
                          ? const Color(0xFF2980B9)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 4)
                      ],
                    ),
                    child: Text(label,
                        style: TextStyle(
                            color: label == 'آخر 7 أيام'
                                ? Colors.white
                                : Colors.black87,
                            fontWeight: FontWeight.w600)),
                  ))
              .toList()),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatItem(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Column(children: [
        Text(value,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ]);
}

Widget _SectionTitle(String text) => Text(text,
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));

class _ChartCard extends StatelessWidget {
  final Widget child;
  final double height;
  const _ChartCard({required this.child, this.height = 180});

  @override
  Widget build(BuildContext context) => Container(
        height: height,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: child,
      );
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;
  const _LegendItem(this.label, this.color);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [
          Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ]),
      );
}

class _MiniStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _MiniStat(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
        child: Row(children: [
          Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 22)),
          const SizedBox(width: 10),
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color)),
                Text(label,
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ]),
        ]),
      );
}
