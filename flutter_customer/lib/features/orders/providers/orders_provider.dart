import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/socket_service.dart';

class Order {
  final String id;
  final String uuid, status, totalAmount, paymentMethod, shippingAddress;
  final String providerName, providerLogo, providerUuid;
  final DateTime createdAt;
  final List items;

  Order(
      {required this.id,
      required this.uuid,
      required this.status,
      required this.totalAmount,
      required this.paymentMethod,
      required this.shippingAddress,
      required this.providerName,
      required this.providerLogo,
      required this.providerUuid,
      required this.createdAt,
      required this.items});

  factory Order.fromJson(Map j) => Order(
        id: j['id'] as String,
        uuid: j['uuid'] as String,
        status: j['status'] as String,
        totalAmount: j['total_amount'] as String,
        paymentMethod: j['payment_method'] as String? ?? 'cash',
        shippingAddress: j['shipping_address'] as String? ?? 'غير محدد',
        providerName: j['provider_name'] as String,
        providerLogo: j['provider_logo'] as String? ?? '',
        providerUuid: j['provider_uuid'] as String? ?? '',
        createdAt: DateTime.parse(j['created_at'] as String),
        items: j['items'] as List? ?? [],
      );

  String get statusText {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'accepted':
        return 'مقبول';
      case 'processing':
        return 'جاري التجهيز';
      case 'out_for_delivery':
        return 'في الطريق';
      case 'delivered':
        return 'تم التوصيل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }
}

class OrdersState {
  final List<Order> orders;
  final bool isLoading;
  final String? error;

  OrdersState({this.orders = const [], this.isLoading = false, this.error});

  OrdersState copyWith({List<Order>? orders, bool? isLoading, String? error}) =>
      OrdersState(
        orders: orders ?? this.orders,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class OrdersNotifier extends StateNotifier<OrdersState> {
  final Ref ref;
  StreamSubscription? _socketSub;

  OrdersNotifier(this.ref) : super(OrdersState()) {
    // FIX INTEGRATION: Listen to real-time status updates from WebSocket
    _socketSub = ref.read(socketServiceProvider).orderUpdates.listen((data) {
      if (data['type'] == 'order_status_update') {
        final orderId = data['order_id']?.toString();
        final uuid = data['uuid']?.toString();
        final newStatus = data['status'];

        if (newStatus != null) {
          state = state.copyWith(
            orders: state.orders.map((o) {
              if (o.id == orderId || o.uuid == uuid) {
                // Update specific order status in-place
                return Order(
                  id: o.id,
                  uuid: o.uuid,
                  status: newStatus, // New status from socket
                  totalAmount: o.totalAmount,
                  paymentMethod: o.paymentMethod,
                  shippingAddress: o.shippingAddress,
                  providerName: o.providerName,
                  providerLogo: o.providerLogo,
                  providerUuid: o.providerUuid,
                  createdAt: o.createdAt,
                  items: o.items,
                );
              }
              return o;
            }).toList(),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _socketSub?.cancel();
    super.dispose();
  }

  Future<void> loadOrders() async {
    state = state.copyWith(isLoading: true);
    try {
      final res = await ApiService.instance.getMyOrders();
      final list =
          (res['data'] as List).map((o) => Order.fromJson(o as Map)).toList();
      state = state.copyWith(orders: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> placeOrder(Map data) async {
    state = state.copyWith(isLoading: true);
    try {
      await ApiService.instance.createOrder(data);
      await loadOrders();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final ordersProvider = StateNotifierProvider<OrdersNotifier, OrdersState>(
    (ref) => OrdersNotifier(ref));
