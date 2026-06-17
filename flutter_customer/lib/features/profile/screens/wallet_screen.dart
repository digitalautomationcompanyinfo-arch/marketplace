import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/wallet_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(walletProvider.notifier).loadTransactions());
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletProvider);
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('محفظتي'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(walletProvider.notifier).loadTransactions(),
        child: CustomScrollView(
          slivers: [
            // Balance Card
            SliverToBoxAdapter(
              child: _buildBalanceCard(
                  double.tryParse(user?['wallet_balance']?.toString() ?? '0') ??
                      0.0),
            ),

            // Actions
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                        child: _actionBtn(Icons.add_circle_outline,
                            'شحن الرصيد', () => _showTopupDialog())),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _actionBtn(Icons.history, 'التقارير', () {})),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('آخر العمليات',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),

            if (walletState.isLoading)
              const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()))
            else if (walletState.transactions.isEmpty)
              const SliverFillRemaining(
                  child: Center(child: Text('لا توجد عمليات سابقة')))
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      _transactionItem(walletState.transactions[index]),
                  childCount: walletState.transactions.length,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(double balance) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF1E293B), Color(0xFF0F172A)]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          const Text('الرصيد المتاح',
              style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            '${NumberFormat('#,###').format(balance)} ج.س',
            style: const TextStyle(
                color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.security, color: Colors.greenAccent, size: 16),
              SizedBox(width: 4),
              Text('متصل ببوابة دفع آمنة',
                  style: TextStyle(color: Colors.white60, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 28),
            const SizedBox(height: 8),
            Text(label,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _transactionItem(WalletTransaction tx) {
    final isNegative = tx.type == 'purchase' || tx.type == 'payout';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isNegative ? Colors.red[50] : Colors.green[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              isNegative ? Icons.arrow_outward : Icons.arrow_downward,
              color: isNegative ? Colors.red : Colors.green,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.typeText,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(tx.notes,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    maxLines: 1),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isNegative ? "-" : "+"}${tx.amount} ج.س',
                style: TextStyle(
                  color: isNegative ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                DateFormat('MMM dd, HH:mm').format(tx.createdAt),
                style: TextStyle(color: Colors.grey[400], fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showTopupDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('شحن المحفظة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'أدخل المبلغ الذي ترغب في شحنه لمحفظتك (بالجنيه السوداني)'),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'المبلغ',
                suffixText: 'ج.س',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(ctrl.text);
              if (amount != null && amount > 0) {
                Navigator.pop(context);
                try {
                  await ref.read(walletProvider.notifier).topup(amount);
                  // تحديث رصيد المستخدم في authProvider أيضاً
                  await ref.read(authProvider.notifier).refreshProfile();
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم شحن الرصيد بنجاح')));
                } catch (e) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('فشل الشحن: $e')));
                }
              }
            },
            child: const Text('شحن الآن'),
          ),
        ],
      ),
    );
  }
}
