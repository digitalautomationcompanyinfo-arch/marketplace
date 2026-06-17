import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/cart_provider.dart';
import '../../orders/providers/orders_provider.dart';
import '../../../core/theme/app_theme.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(cartProvider.notifier).loadCart());
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('سلة التسوق'),
        centerTitle: true,
        actions: [
          if (cartState.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
              onPressed: () => _confirmClearCart(),
            ),
        ],
      ),
      body: cartState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartState.items.isEmpty
              ? _buildEmptyCart()
              : Column(
                  children: [
                    Expanded(
                      child: _buildGroupedCart(cartState),
                    ),
                    _buildCheckoutSection(cartState),
                  ],
                ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 100, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('سلة التسوق فارغة',
              style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/home'),
            child: const Text('ابدأ التسوق الآن'),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedCart(CartState state) {
    final Map<int, List<CartItem>> grouped = {};
    for (var item in state.items) {
      grouped[item.providerId] = (grouped[item.providerId] ?? [])..add(item);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final entry = grouped.entries.elementAt(index);
        final providerName = entry.value.first.providerName;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProviderHeader(providerName),
            ...entry.value.map((item) => _buildCartItem(item)),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildProviderHeader(String name) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Row(
        children: [
          const Icon(Icons.storefront, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 8),
          Text(
            name,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.blueGrey),
          ),
          const SizedBox(width: 8),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.mainImage,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey[200],
                  child:
                      const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  if (item.selectedAttributes.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        item.selectedAttributes.entries
                            .map((e) => '${e.key}: ${e.value}')
                            .join(' | '),
                        style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 11,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text('${item.price} ج.س',
                      style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            // Quantity
            Column(
              children: [
                Row(
                  children: [
                    _qtyBtn(Icons.remove, () => _updateQty(item, -1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text('${item.quantity}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    _qtyBtn(Icons.add, () => _updateQty(item, 1)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.red, size: 20),
                  onPressed: () =>
                      ref.read(cartProvider.notifier).removeItem(item.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }

  Widget _buildCheckoutSection(CartState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5))
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('الإجمالي',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('${state.totalAmount.toStringAsFixed(2)} ج.س',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => context.push('/checkout'),
                child: const Text('المتابعة لإتمام الطلب',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateQty(CartItem item, int delta) {
    final newQty = item.quantity + delta;
    if (newQty > 0) {
      ref.read(cartProvider.notifier).updateQuantity(item.id, newQty);
    }
  }

  void _confirmClearCart() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مسح السلة'),
        content: const Text('هل أنت متأكد من رغبتك في إفراغ سلة التسوق؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              ref.read(cartProvider.notifier).clearCart();
              Navigator.pop(context);
            },
            child: const Text('نعم، امسح', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // تمت إزالة دالة _checkout من هنا وتم نقلها إلى CheckoutScreen
}
