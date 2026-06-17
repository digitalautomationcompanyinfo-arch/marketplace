import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_service.dart';

class ProviderOrder {
  final String id;
  final String uuid, status, totalAmount, customerName, customerPhone;
  final DateTime createdAt;
  final List items;

  ProviderOrder(
      {required this.id,
      required this.uuid,
      required this.status,
      required this.totalAmount,
      required this.customerName,
      required this.customerPhone,
      required this.createdAt,
      required this.items});

  factory ProviderOrder.fromJson(Map j) => ProviderOrder(
        id: j['id'] as String,
        uuid: j['uuid'] as String,
        status: j['status'] as String,
        totalAmount: j['total_amount'] as String,
        customerName: j['customer_name'] as String,
        customerPhone: j['customer_phone'] as String,
        createdAt: DateTime.parse(j['created_at'] as String),
        items: j['items'] as List? ?? [],
      );

  String get statusText {
    switch (status) {
      case 'pending':
        return 'طلب جديد';
      case 'accepted':
        return 'مقبول';
      case 'processing':
        return 'جاري التجهيز';
      case 'out_for_delivery':
        return 'جاري التوصيل';
      case 'delivered':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }
}

class ProviderOrdersState {
  final List<ProviderOrder> orders;
  final bool isLoading;
  final String? error;

  ProviderOrdersState(
      {this.orders = const [], this.isLoading = false, this.error});

  ProviderOrdersState copyWith(
          {List<ProviderOrder>? orders, bool? isLoading, String? error}) =>
      ProviderOrdersState(
        orders: orders ?? this.orders,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class ProviderOrdersNotifier extends StateNotifier<ProviderOrdersState> {
  ProviderOrdersNotifier() : super(ProviderOrdersState());

  Future<void> loadOrders({String? status, String? search}) async {
    state = state.copyWith(isLoading: true);
    try {
      final res = await ApiService.instance
          .getProviderOrders(status: status, search: search);
      final list = (res['data'] as List)
          .map((o) => ProviderOrder.fromJson(o as Map))
          .toList();
      state = state.copyWith(orders: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateStatus(String orderId, String status) async {
    try {
      await ApiService.instance.updateOrderStatus(orderId, status);
      await loadOrders();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final providerOrdersProvider =
    StateNotifierProvider<ProviderOrdersNotifier, ProviderOrdersState>(
        (ref) => ProviderOrdersNotifier());
