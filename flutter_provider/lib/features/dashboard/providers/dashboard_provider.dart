import '../../../core/network/api_service.dart';
import '../../../core/utils/security_utils.dart';

class DashboardState {
  final Map<String, dynamic>? stats;
  final Map<String, dynamic>? providerProfile;
  final List<dynamic> incomingOrders; // active orders only
  final List<dynamic> walletTransactions; // financial history
  final bool isLoading;
  final String? error;

  DashboardState({
    this.stats,
    this.providerProfile,
    this.incomingOrders = const [],
    this.walletTransactions = const [],
    this.isLoading = false,
    this.error,
  });

  DashboardState copyWith({
    Map<String, dynamic>? stats,
    Map<String, dynamic>? providerProfile,
    List<dynamic>? incomingOrders,
    List<dynamic>? walletTransactions,
    bool? isLoading,
    String? error,
  }) {
    return DashboardState(
      stats: stats ?? this.stats,
      providerProfile: providerProfile ?? this.providerProfile,
      incomingOrders: incomingOrders ?? this.incomingOrders,
      walletTransactions: walletTransactions ?? this.walletTransactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier() : super(DashboardState());

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await Future.wait([
        ApiService.instance.getProviderStats(),
        ApiService.instance.getProviderOrders(),
        ApiService.instance.getProviderProfile(),
        ApiService.instance.getProviderTransactions(),
      ]);

      final statsRes = results[0];
      final ordersRes = results[1];
      final profileRes = results[2];
      final transRes = results[3];

      final activeOrders = (ordersRes['data'] as List)
          .where((o) =>
              o['status'] == 'pending' ||
              o['status'] == 'accepted' ||
              o['status'] == 'processing')
          .toList();

      state = state.copyWith(
        stats: statsRes['data'],
        providerProfile: profileRes['data'],
        incomingOrders: activeOrders,
        walletTransactions: transRes['data'],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // FIX HIGH-6: Update local state directly instead of reloading full dashboard
  // (was firing 3 parallel API calls on every status tap)
  Future<void> updateOrderStatus(String id, String newStatus) async {
    try {
      // SECURITY: Ensure device integrity for status updates
      await SecurityUtils.ensureSecureDevice();

      await ApiService.instance.updateOrderStatus(id, newStatus);
      // Optimistically remove from active list if status is terminal
      const terminalStatuses = ['delivered', 'cancelled'];
      if (terminalStatuses.contains(newStatus)) {
        final updated =
            state.incomingOrders.where((o) => o['id'] != id).toList();
        state = state.copyWith(incomingOrders: updated);
      } else {
        // Update the status in-place
        final updated = state.incomingOrders.map((o) {
          if (o['id'] == id)
            return {...(o as Map<String, dynamic>), 'status': newStatus};
          return o;
        }).toList();
        state = state.copyWith(incomingOrders: updated);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier()..loadDashboard();
});
