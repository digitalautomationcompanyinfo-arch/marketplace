import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/orders_provider.dart';

class ProviderOrdersScreen extends ConsumerStatefulWidget {
  const ProviderOrdersScreen({super.key});

  @override
  ConsumerState<ProviderOrdersScreen> createState() => _ProviderOrdersScreenState();
}

import '../../../core/network/socket_service.dart';

class _ProviderOrdersScreenState extends ConsumerState<ProviderOrdersScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  bool _isSearching = false;
  StreamSubscription? _socketSub;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      ref.read(providerOrdersProvider.notifier).loadOrders();
      final socket = ref.read(socketServiceProvider);
      await socket.init();
      _socketSub = socket.orderEvents.listen((event) {
        if (mounted) {
          ref.read(providerOrdersProvider.notifier).loadOrders();
        }
      });
    });
  }

  @override
  void dispose() {
    _socketSub?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F4F8),
        appBar: AppBar(
          title: _isSearching 
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(hintText: 'ابحث باسم العميل أو رقم الطلب...', hintStyle: TextStyle(color: Colors.white70), border: InputBorder.none),
                onSubmitted: (val) => ref.read(providerOrdersProvider.notifier).loadOrders(search: val),
              )
            : const Text('الطلبات الواردة'),
          backgroundColor: const Color(0xFF1A3C5E),
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: () {
                setState(() => _isSearching = !_isSearching);
                if (!_isSearching) {
                  _searchCtrl.clear();
                  ref.read(providerOrdersProvider.notifier).loadOrders();
                }
              },
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: [
              Tab(text: 'الكل'),
              Tab(text: 'جديدة'),
              Tab(text: 'قيد التجهيز'),
              Tab(text: 'في الطريق'),
              Tab(text: 'مكتملة'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OrdersList(status: 'all'),
            _OrdersList(status: 'pending'),
            _OrdersList(status: 'processing'), // Backend can handle mapping if I want, or I just filter client side for better UX if data is small
            _OrdersList(status: 'out_for_delivery'),
            _OrdersList(status: 'delivered'),
          ],
        ),
      ),
    );
  }
}

class _OrdersList extends ConsumerWidget {
  final String status;
  const _OrdersList({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(providerOrdersProvider);
    
    // Client-side filtering for immediate tab switching feel, 
    // but loadOrders handles the initial server-side fetch.
    final filtered = state.orders.where((o) {
      if (status == 'all') return true;
      if (status == 'processing') return o.status == 'accepted' || o.status == 'processing';
      return o.status == status;
    }).toList();

    return RefreshIndicator(
      onRefresh: () => ref.read(providerOrdersProvider.notifier).loadOrders(),
      child: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : filtered.isEmpty
              ? Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text('لا توجد طلبات ${status == 'all' ? '' : 'في هذه القائمة'}', style: TextStyle(color: Colors.grey[600])),
                  ],
                ))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => _OrderCard(order: filtered[index]),
                ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final ProviderOrder order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => context.push('/orders/${order.id}', extra: order),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('طلب #${order.uuid.substring(0, 8)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  _StatusBadge(status: order.status, text: order.statusText),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('العميل', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('الإجمالي', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text('${order.totalAmount} ج.س', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2980B9))),
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
}

class _StatusBadge extends StatelessWidget {
  final String status, text;
  const _StatusBadge({required this.status, required this.text});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'pending': color = Colors.orange; break;
      case 'accepted': case 'processing': color = Colors.blue; break;
      case 'out_for_delivery': color = Colors.purple; break;
      case 'delivered': color = Colors.green; break;
      case 'cancelled': color = Colors.red; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.5))),
      child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}

