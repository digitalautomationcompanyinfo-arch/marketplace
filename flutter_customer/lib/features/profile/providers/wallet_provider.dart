import '../../../core/services/api_service.dart';
import '../../../core/utils/security_utils.dart';

class WalletTransaction {
  final String id;
  final double amount;
  final String type, notes;
  final DateTime createdAt;

  WalletTransaction(
      {required this.id,
      required this.amount,
      required this.type,
      required this.notes,
      required this.createdAt});

  factory WalletTransaction.fromJson(Map j) => WalletTransaction(
        id: j['id'] as String,
        amount: double.parse(j['amount'].toString()),
        type: j['type'] as String,
        notes: j['notes'] as String? ?? '',
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  String get typeText {
    switch (type) {
      case 'topup':
        return 'شحن رصيد';
      case 'purchase':
        return 'عملية شراء';
      case 'refund':
        return 'استرجاع';
      case 'payout':
        return 'سحب أرباح';
      case 'admin_adjustment':
        return 'تعديل إداري';
      default:
        return type;
    }
  }
}

class WalletState {
  final List<WalletTransaction> transactions;
  final bool isLoading;
  final String? error;

  WalletState(
      {this.transactions = const [], this.isLoading = false, this.error});

  WalletState copyWith(
          {List<WalletTransaction>? transactions,
          bool? isLoading,
          String? error}) =>
      WalletState(
        transactions: transactions ?? this.transactions,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class WalletNotifier extends StateNotifier<WalletState> {
  WalletNotifier() : super(WalletState());

  Future<void> loadTransactions() async {
    state = state.copyWith(isLoading: true);
    try {
      final res = await ApiService.instance.getWalletTransactions();
      final list = (res['data'] as List)
          .map((t) => WalletTransaction.fromJson(t as Map))
          .toList();
      state = state.copyWith(transactions: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> topup(double amount) async {
    state = state.copyWith(isLoading: true);
    try {
      // FIX F12: Check device integrity for financial operations
      await SecurityUtils.ensureSecureDevice();

      final res = await ApiService.instance.initTopup(amount);
      final txId = res['data']['transaction_id'] as String;

      // محاكاة اكتمال الدفع
      await ApiService.instance.verifyTopup(txId, amount);
      await loadTransactions();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}

final walletProvider = StateNotifierProvider<WalletNotifier, WalletState>(
    (ref) => WalletNotifier());
