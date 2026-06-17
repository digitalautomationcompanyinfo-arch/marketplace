import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/orders_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/socket_service.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(ordersProvider.notifier).loadOrders();
      await ref.read(socketServiceProvider).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen for socket events to refresh orders
    ref.listen(socketServiceProvider, (prev, next) {
      next.orderUpdates.listen((event) {
        if (mounted) {
          ref.read(ordersProvider.notifier).loadOrders();
        }
      });
    });

    final ordersState = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('طلباتي'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(ordersProvider.notifier).loadOrders(),
        child: ordersState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ordersState.orders.isEmpty
                ? _buildEmptyOrders()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: ordersState.orders.length,
                    itemBuilder: (context, index) {
                      final order = ordersState.orders[index];
                      return _buildOrderCard(order);
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyOrders() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            children: [
              Icon(Icons.assignment_outlined,
                  size: 100, color: Colors.grey[300]),
              const SizedBox(height: 16),
              const Text('لا توجد طلبات سابقة',
                  style: TextStyle(fontSize: 18, color: Colors.grey)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('استكشف الخدمات والمنتجات'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => context.push('/orders/${order.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'طلب #${order.uuid.substring(0, 8)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  _buildStatusBadge(order.status, order.statusText),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      order.providerLogo,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 50,
                        height: 50,
                        color: Colors.blue[50],
                        child: const Icon(Icons.store, color: Colors.blue),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.providerName,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                          '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${order.totalAmount} ج.س',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${order.items.length} منتجات',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, String text) {
    Color color;
    switch (status) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'accepted':
      case 'processing':
        color = Colors.blue;
        break;
      case 'out_for_delivery':
        color = Colors.purple;
        break;
      case 'delivered':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}
