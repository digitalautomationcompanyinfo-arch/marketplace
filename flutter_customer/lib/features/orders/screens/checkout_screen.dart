// checkout_screen.dart - World-class checkout like Amazon
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../cart/providers/cart_provider.dart';
import '../providers/orders_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _selectedPayment = 0;
  int _selectedAddress = 0;
  bool _isPlacingOrder = false;

  final _paymentMethods = [
    {
      'label': 'بطاقة ائتمانية/مدى',
      'icon': Icons.credit_card,
      'sub': '**** **** **** 4532'
    },
    {
      'label': 'محفظة كيف نخدمك',
      'icon': Icons.account_balance_wallet,
      'sub': 'الرصيد: 150 ج.س'
    },
    {
      'label': 'الدفع عند الاستلام',
      'icon': Icons.payments_outlined,
      'sub': 'نقداً أو بطاقة'
    },
  ];

  final _addresses = [
    {
      'label': 'المنزل',
      'detail': 'الرياض، حي النخيل، شارع الأمير فيصل، مبنى 12',
      'icon': Icons.home_outlined
    },
    {
      'label': 'العمل',
      'detail': 'الرياض، حي العليا، برج المملكة، الطابق 15',
      'icon': Icons.work_outline
    },
  ];

  double _subtotal(CartState cart) => cart.totalAmount;
  double get _delivery => 0;
  double _total(CartState cart) => _subtotal(cart) + _delivery;

  Future<void> _placeOrder(CartState state) async {
    if (state.items.isEmpty) return;

    setState(() => _isPlacingOrder = true);

    try {
      // 1. تجميع السلع حسب المزود
      final Map<int, List<CartItem>> groupedItems = {};
      for (var item in state.items) {
        groupedItems[item.providerId] = (groupedItems[item.providerId] ?? [])
          ..add(item);
      }

      // 2. إنشاء طلب لكل مزود
      for (var entry in groupedItems.entries) {
        final providerId = entry.key;
        final items = entry.value
            .map((i) => {
                  'product_id': i.productId,
                  'quantity': i.quantity,
                  'selected_attributes': i.selectedAttributes,
                })
            .toList();

        await ref.read(ordersProvider.notifier).placeOrder({
          'provider_id': providerId,
          'items': items,
          'shipping_address': _addresses[_selectedAddress]['detail'],
          'payment_method': _selectedPayment == 2 ? 'cash' : 'wallet'
        });
      }

      // 3. إفراغ السلة
      await ref.read(cartProvider.notifier).clearCart();

      if (mounted) {
        setState(() => _isPlacingOrder = false);
        context.pushReplacement('/orders');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPlacingOrder = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('فشل الطلب: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: const Text('تأكيد الطلب'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Address Section ────────────────────
                  _SectionHeader(title: 'عنوان التوصيل 📍', onEdit: () {}),
                  ...List.generate(
                      _addresses.length,
                      (i) => _SelectableCard(
                            title: _addresses[i]['label'] as String,
                            subtitle: _addresses[i]['detail'] as String,
                            icon: _addresses[i]['icon'] as IconData,
                            isSelected: _selectedAddress == i,
                            onTap: () => setState(() => _selectedAddress = i),
                          )),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('إضافة عنوان جديد'),
                  ),
                  const SizedBox(height: 20),

                  // ─── Order Items ────────────────────────
                  _SectionHeader(title: 'محتوى الطلب 🛍️'),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppTheme.radiusMd,
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: Column(
                      children: cartState.items.asMap().entries.map((e) {
                        final isLast = e.key == cartState.items.length - 1;
                        final item = e.value;
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: AppTheme.bgLight,
                                      borderRadius: AppTheme.radiusSm,
                                    ),
                                    child: item.mainImage.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius: AppTheme.radiusSm,
                                            child: Image.network(item.mainImage,
                                                fit: BoxFit.cover))
                                        : const Icon(Icons.restaurant_menu,
                                            color: AppTheme.primaryLight),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(item.name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14)),
                                        Text(item.providerName,
                                            style: AppTheme.bodySm),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${((double.tryParse(item.price) ?? 0.0) * item.quantity).toStringAsFixed(0)} ج.س',
                                        style: AppTheme.priceLg
                                            .copyWith(fontSize: 15),
                                      ),
                                      Text('× ${item.quantity}',
                                          style: AppTheme.bodySm),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (!isLast) const Divider(height: 1),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ─── Payment Section ────────────────────
                  _SectionHeader(title: 'طريقة الدفع 💳'),
                  ...List.generate(
                      _paymentMethods.length,
                      (i) => _SelectableCard(
                            title: _paymentMethods[i]['label'] as String,
                            subtitle: _paymentMethods[i]['sub'] as String,
                            icon: _paymentMethods[i]['icon'] as IconData,
                            isSelected: _selectedPayment == i,
                            onTap: () => setState(() => _selectedPayment = i),
                          )),
                  const SizedBox(height: 20),

                  // ─── Order Notes ────────────────────────
                  _SectionHeader(title: 'ملاحظات (اختياري) 📝'),
                  TextField(
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'أي تعليمات خاصة للمطعم أو المندوب؟',
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppTheme.borderColor)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ─── Promo Code ─────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'رمز الخصم',
                            prefixIcon: const Icon(Icons.local_offer_outlined),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(80, 52),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text('تطبيق'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ─── Price Summary ──────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withOpacity(0.05),
                          AppTheme.primaryLight.withOpacity(0.05)
                        ],
                      ),
                      borderRadius: AppTheme.radiusMd,
                      border: Border.all(
                          color: AppTheme.primaryLight.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        _PriceRow('المجموع الفرعي',
                            '${_subtotal(cartState).toStringAsFixed(0)} ج.س'),
                        _PriceRow('رسوم التوصيل', 'مجاني 🎉',
                            color: AppTheme.accentColor),
                        _PriceRow('الضريبة (15%)',
                            '${(_subtotal(cartState) * 0.15).toStringAsFixed(0)} ج.س'),
                        const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Divider(height: 1)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('الإجمالي المستحق',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(
                                '${(_total(cartState) * 1.15).toStringAsFixed(0)} ج.س',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 24,
                                    color: AppTheme.primaryColor)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Place Order Button ──────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: AppTheme.shadowMd,
            ),
            child: ElevatedButton(
              onPressed: _isPlacingOrder ? null : () => _placeOrder(cartState),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: const RoundedRectangleBorder(
                    borderRadius: AppTheme.radiusMd),
              ),
              child: _isPlacingOrder
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_bag_outlined, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          'تأكيد الطلب · ${(_total(cartState) * 1.15).toStringAsFixed(0)} ج.س',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onEdit;
  const _SectionHeader({required this.title, this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTheme.headingSm),
          if (onEdit != null)
            TextButton(
                onPressed: onEdit,
                child:
                    const Text('تغيير', style: TextStyle(fontFamily: 'Cairo'))),
        ],
      ),
    );
  }
}

class _SelectableCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectableCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryLight.withOpacity(0.05)
              : Colors.white,
          borderRadius: AppTheme.radiusMd,
          border: Border.all(
            color: isSelected ? AppTheme.primaryLight : AppTheme.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryLight.withOpacity(0.1)
                    : AppTheme.bgLight,
                borderRadius: AppTheme.radiusSm,
              ),
              child: Icon(icon,
                  color:
                      isSelected ? AppTheme.primaryLight : AppTheme.textMuted,
                  size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTheme.bodySm),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                    color: AppTheme.primaryLight, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 14),
              )
            else
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.borderColor, width: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? color;
  const _PriceRow(this.label, this.value, {this.bold = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: bold ? AppTheme.headingSm : AppTheme.bodyMd),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
              fontSize: bold ? 18 : 14,
              color: color ??
                  (bold ? AppTheme.textPrimary : AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
