import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/products_provider.dart';
import 'add_product_screen.dart';

class ProductsManagementScreen extends ConsumerWidget {
  const ProductsManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productsProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: const Text('إدارة المنتجات'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.accentColor,
        onPressed: () async {
          final result = await context.push('/products/add');
          if (result == true && context.mounted) {
            ref.read(productsProvider.notifier).loadProducts();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(productsProvider.notifier).loadProducts(),
        child: state.isLoading && state.products.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : state.products.isEmpty
                ? const Center(
                    child: Text('لا توجد منتجات حالياً',
                        style: TextStyle(fontFamily: 'Cairo')))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.products.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final p = state.products[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppTheme.radiusMd,
                          border: Border.all(color: AppTheme.borderColor),
                          boxShadow: AppTheme.shadowSm,
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: AppTheme.radiusSm,
                              child: p.mainImage.isNotEmpty
                                  ? Image.network(
                                      p.mainImage,
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _placeholderImage(),
                                    )
                                  : _placeholderImage(),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text('${p.price} ج.س',
                                      style: const TextStyle(
                                          color: AppTheme.primaryLight,
                                          fontWeight: FontWeight.bold)),
                                  if (p.attributes.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        'خصائص: ${p.attributes.keys.join(', ')}',
                                        style: const TextStyle(
                                            fontSize: 10, color: Colors.grey),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Switch(
                                  value: p.isAvailable,
                                  onChanged: (val) {
                                    ref
                                        .read(productsProvider.notifier)
                                        .toggleAvailability(
                                            p.id, p.isAvailable);
                                  },
                                  activeColor: AppTheme.accentColor,
                                ),
                                Text(
                                  p.isAvailable ? 'متاح' : 'مخفي',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: p.isAvailable
                                        ? AppTheme.accentColor
                                        : AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 4),
                            // Edit & Delete
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined,
                                      color: Colors.blue, size: 20),
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            AddProductScreen(initialProduct: p),
                                      ),
                                    );
                                    if (result == true && context.mounted) {
                                      ref
                                          .read(productsProvider.notifier)
                                          .loadProducts();
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: AppTheme.errorColor, size: 20),
                                  onPressed: () =>
                                      _confirmDelete(context, ref, p),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  Widget _placeholderImage() => Container(
        width: 70,
        height: 70,
        color: Colors.grey[200],
        child: const Icon(Icons.fastfood, color: Colors.grey),
      );

  void _confirmDelete(BuildContext context, WidgetRef ref, ProviderProduct p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف', style: TextStyle(fontFamily: 'Cairo')),
        content: Text('هل أنت متأكد من حذف "${p.name}"؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            onPressed: () {
              ref.read(productsProvider.notifier).deleteProduct(p.id);
              Navigator.pop(ctx);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
