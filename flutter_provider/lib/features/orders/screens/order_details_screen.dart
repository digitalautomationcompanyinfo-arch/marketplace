import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/orders_provider.dart';

class ProviderOrderDetailsScreen extends ConsumerWidget {
  final ProviderOrder order;
  const ProviderOrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: Text('تفاصيل الطلب #${order.uuid.substring(0, 8)}'),
        backgroundColor: const Color(0xFF1A3C5E),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCustomerInfo(order),
            const SizedBox(height: 16),
            _buildItemsList(order),
            const SizedBox(height: 24),
            _buildActionButtons(context, ref, order),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfo(ProviderOrder order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('معلومات العميل',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.person),
            title: Text(order.customerName),
            subtitle: Text(order.customerPhone),
            trailing: IconButton(
                icon: const Icon(Icons.phone, color: Colors.green),
                onPressed: () {}),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(ProviderOrder order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('المنتجات المطلوبة',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(),
          ...order.items.map((item) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Image.network(item['main_image'] ?? '',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.image, size: 50)),
                title: Text(item['product_name'] ?? ''),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item['selected_attributes'] != null &&
                        (item['selected_attributes'] as Map).isNotEmpty)
                      Text(
                        (item['selected_attributes'] as Map)
                            .entries
                            .map((e) => '${e.key}: ${e.value}')
                            .join(' | '),
                        style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
                    Text('الكمية: ${item['quantity']} × ${item['price']} ج.س'),
                  ],
                ),
                trailing: Text(
                    '${(item['quantity'] * double.parse(item['price'].toString())).toStringAsFixed(2)} ج.س',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              )),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('الإجمالي',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('${order.totalAmount} ج.س',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2980B9))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, WidgetRef ref, ProviderOrder order) {
    if (order.status == 'delivered' || order.status == 'cancelled')
      return const SizedBox();

    return Column(
      children: [
        if (order.status == 'pending') ...[
          _actionBtn(ref, order.id, 'قبول الطلب', 'accepted', Colors.blue),
          const SizedBox(height: 12),
          _actionBtn(ref, order.id, 'رفض الطلب', 'cancelled', Colors.red,
              isOutline: true),
        ],
        if (order.status == 'accepted')
          _actionBtn(ref, order.id, 'بدء التجهيز', 'processing', Colors.orange),
        if (order.status == 'processing')
          _actionBtn(ref, order.id, 'تجهيز للتوصيل', 'out_for_delivery',
              Colors.purple),
        if (order.status == 'out_for_delivery')
          _actionBtn(ref, order.id, 'تأكيد التوصيل', 'delivered', Colors.green),
      ],
    );
  }

  Widget _actionBtn(
      WidgetRef ref, int orderId, String label, String status, Color color,
      {bool isOutline = false}) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: isOutline
          ? OutlinedButton(
              style: OutlinedButton.styleFrom(
                  foregroundColor: color,
                  side: BorderSide(color: color),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              onPressed: () => ref
                  .read(providerOrdersProvider.notifier)
                  .updateStatus(orderId, status),
              child: Text(label, style: const TextStyle(fontSize: 16)),
            )
          : ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              onPressed: () => ref
                  .read(providerOrdersProvider.notifier)
                  .updateStatus(orderId, status),
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
    );
  }
}
