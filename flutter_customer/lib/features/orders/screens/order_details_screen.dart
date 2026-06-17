import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/orders_provider.dart';
import '../../reviews/screens/add_review_screen.dart';
import '../../../core/theme/app_theme.dart';

class OrderDetailsScreen extends ConsumerStatefulWidget {
  final String orderId;
  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends ConsumerState<OrderDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(ordersProvider);
    // في الواقع هنا يجب البحث في حالة الـ provider أو طلب التفاصيل من الـ API
    final order = ordersState.orders.firstWhere(
      (o) => o.id.toString() == widget.orderId || o.uuid == widget.orderId,
      orElse: () => throw Exception('Order not found'),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل الطلب #${order.uuid.substring(0, 8)}'),
        centerTitle: true,
        actions: [
          if (order.providerUuid.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.chat_outlined),
              onPressed: () {
                // Navigate to Chat Screen with Provider UUID
                context.push('/chat/${order.providerUuid}',
                    extra: {'name': order.providerName});
              },
              tooltip: 'تواصل مع المزود',
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            _buildStatusCard(order),
            const SizedBox(height: 24),

            const Text('المنتجات',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...order.items.map((item) => _buildItemRow(item)).toList(),

            const Divider(height: 32),
            _buildSummaryRow('المجموع الفرعي', '${order.totalAmount} ج.س'),
            _buildSummaryRow('رسوم التوصيل', '0.00 ج.س'),
            const Divider(height: 32),
            _buildSummaryRow('الإجمالي الكلي', '${order.totalAmount} ج.س',
                isTotal: true),

            const SizedBox(height: 32),
            const Text('معلومات التوصيل',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildInfoCard(Icons.location_on_outlined, 'عنوان التوصيل',
                order.shippingAddress),
            _buildInfoCard(
                Icons.payment_outlined,
                'طريقة الدفع',
                order.paymentMethod == 'cash'
                    ? 'نقداً عند الاستلام'
                    : 'المحفظة/بطاقة'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(Order order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          const Text('حالة الطلب الحالية',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            order.statusText,
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 16),
          // قريباً يمكن إضافة خط زمن (Timeline) هنا
        ],
      ),
    );
  }

  Widget _buildItemRow(Map item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item['main_image'] ?? '',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey[100],
                  child: const Icon(Icons.image)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['product_name'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                if (item['selected_attributes'] != null &&
                    (item['selected_attributes'] as Map).isNotEmpty)
                  Text(
                    (item['selected_attributes'] as Map)
                        .entries
                        .map((e) => '${e.key}: ${e.value}')
                        .join(' | '),
                    style: TextStyle(color: Colors.blue[600], fontSize: 11),
                  ),
                Text('${item['quantity']} × ${item['price']} ج.س',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                if (item['product_uuid'] != null)
                  TextButton.icon(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (c) => AddReviewScreen(
                            productUuid: item['product_uuid'],
                            productName: item['product_name'],
                          ),
                        )),
                    icon: const Icon(Icons.star_border,
                        size: 16, color: Colors.amber),
                    label: const Text('تقييم المنتج',
                        style: TextStyle(fontSize: 11)),
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 30)),
                  ),
              ],
            ),
          ),
          Text(
              '${(double.parse(item['price'].toString()) * (item['quantity'] as int)).toStringAsFixed(2)} ج.س'),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: isTotal ? 18 : 14,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  fontSize: isTotal ? 18 : 14,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                  color: isTotal ? AppTheme.primaryColor : Colors.black)),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration:
                BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
            child: Icon(icon, size: 20, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13)),
              Text(value,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}
