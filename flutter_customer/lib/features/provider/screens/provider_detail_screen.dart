// provider_detail_screen.dart - World-class provider detail page like Amazon/Careem
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/provider_detail_provider.dart';

class ProviderDetailScreen extends ConsumerStatefulWidget {
  final String providerId;
  const ProviderDetailScreen({super.key, required this.providerId});

  @override
  ConsumerState<ProviderDetailScreen> createState() =>
      _ProviderDetailScreenState();
}

class _ProviderDetailScreenState extends ConsumerState<ProviderDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: ref.watch(providerDetailProvider(widget.providerId)).isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // ─── Hero AppBar ──────────────────────────────
                SliverAppBar(
                  expandedHeight: 280,
                  pinned: true,
                  stretch: true,
                  backgroundColor: AppTheme.primaryColor,
                  leading: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 16),
                    ),
                    onPressed: () => context.pop(),
                  ),
                  actions: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle),
                        child: Icon(
                            _isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.white,
                            size: 20),
                      ),
                      onPressed: () =>
                          setState(() => _isFavorite = !_isFavorite),
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle),
                        child: const Icon(Icons.share,
                            color: Colors.white, size: 20),
                      ),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 8),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    stretchModes: const [StretchMode.zoomBackground],
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Cover Image
                        Container(
                          decoration: const BoxDecoration(
                              gradient: AppTheme.cardGradient),
                          child: const Center(
                            child: Icon(Icons.storefront,
                                size: 80, color: Colors.white30),
                          ),
                        ),
                        // Gradient overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.6)
                              ],
                            ),
                          ),
                        ),
                        // Info overlay
                        Positioned(
                          bottom: 20,
                          right: 20,
                          left: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text('مميز ✨',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700)),
                              ),
                              const SizedBox(height: 8),
                              const Text('مطعم البيت السعودي',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900)),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      color: Colors.white70, size: 14),
                                  const SizedBox(width: 4),
                                  const Text('الرياض, حي النخيل',
                                      style: TextStyle(
                                          color: Colors.white70, fontSize: 13)),
                                  const SizedBox(width: 16),
                                  const Icon(Icons.access_time,
                                      color: Colors.white70, size: 14),
                                  const SizedBox(width: 4),
                                  const Text('مفتوح الآن',
                                      style: TextStyle(
                                          color: Color(0xFF2ECC71),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ─── Stats Row ────────────────────────────────
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        _StatItem(
                          icon: Icons.star_rounded,
                          label: ref
                                  .watch(
                                      providerDetailProvider(widget.providerId))
                                  .provider
                                  ?.ratingAvg
                                  .toStringAsFixed(1) ??
                              '0.0',
                          sub:
                              '(${ref.watch(providerDetailProvider(widget.providerId)).provider?.ratingCount ?? 0} تقييم)',
                          color: AppTheme.warningColor,
                        ),
                        _divider(),
                        _StatItem(
                            icon: Icons.timer_outlined,
                            label: '30 دقيقة',
                            sub: 'متوسط التوصيل',
                            color: AppTheme.primaryLight),
                        _divider(),
                        _StatItem(
                            icon: Icons.local_shipping_outlined,
                            label: 'مجاني',
                            sub: 'التوصيل',
                            color: AppTheme.accentColor),
                      ],
                    ),
                  ),
                ),

                // ─── Tab Bar ──────────────────────────────────
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyTabBar(_tabController),
                ),

                // ─── Tab Content ──────────────────────────────
                SliverFillRemaining(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _MenuTab(providerId: widget.providerId),
                      _ReviewsTab(providerId: widget.providerId),
                      _InfoTab(providerId: widget.providerId),
                    ],
                  ),
                ),
              ],
            ),

      // ─── Bottom CTA ───────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: AppTheme.shadowMd,
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.phone_outlined,
                  color: AppTheme.primaryLight),
              onPressed: () {},
              tooltip: 'اتصال',
            ),
            IconButton(
              icon:
                  const Icon(Icons.chat_outlined, color: AppTheme.primaryLight),
              onPressed: () => context.push('/messages'),
              tooltip: 'مراسلة',
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Show BookingPickerSheet (Phase 69)
                  // showModalBottomSheet(
                  //   context: context,
                  //   isScrollControlled: true,
                  //   builder: (c) => BookingPickerSheet(providerId: widget.providerId, providerName: 'متجر الأناقة'),
                  // );
                },
                icon: const Icon(Icons.calendar_today, size: 20),
                label: const Text('حجز موعد'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const RoundedRectangleBorder(
                      borderRadius: AppTheme.radiusMd),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => context.push('/cart'),
                icon: const Icon(Icons.shopping_cart_checkout, size: 20),
                label: const Text('أضف للسلة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const RoundedRectangleBorder(
                      borderRadius: AppTheme.radiusMd),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 40, color: AppTheme.borderColor);

  Widget _StatItem(
      {required IconData icon,
      required String label,
      required String sub,
      required Color color}) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          Text(sub, style: AppTheme.bodySm),
        ],
      ),
    );
  }
}

// ─── Menu Tab ─────────────────────────────────────────────
class _MenuTab extends ConsumerWidget {
  final String providerId;
  _MenuTab({required this.providerId});

  final categories = ['الكل'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(providerDetailProvider(providerId));
    final items = state.products;

    if (items.isEmpty && !state.isLoading) {
      return const Center(
          child: Text('لا يوجد منتجات متاحة حالياً',
              style: TextStyle(fontFamily: 'Cairo', color: Colors.grey)));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Category chips
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (_, i) => Container(
              margin: const EdgeInsetsDirectional.only(start: 8),
              child: FilterChip(
                label: Text(categories[i]),
                selected: i == 0,
                onSelected: (_) {},
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...items.map((item) => _MenuItemCard(item: item)),
      ],
    );
  }
}

class _MenuItemCard extends ConsumerWidget {
  final Map item;
  const _MenuItemCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stock = item['stock_quantity'] ?? -1;
    final isLowStock = stock != -1 && stock > 0 && stock <= 5;
    final isOutOfStock = stock == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isOutOfStock ? Colors.grey[50] : Colors.white,
        borderRadius: AppTheme.radiusMd,
        border: Border.all(
            color: isOutOfStock ? Colors.grey[300]! : AppTheme.borderColor),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(item['name'] ?? '',
                        style: AppTheme.headingSm.copyWith(
                          color:
                              isOutOfStock ? Colors.grey : AppTheme.textPrimary,
                          decoration:
                              isOutOfStock ? TextDecoration.lineThrough : null,
                        )),
                    if (item['is_featured'] == true) ...[
                      const SizedBox(width: 8),
                      _badge('مميز', AppTheme.accentColor),
                    ],
                    if (isLowStock) ...[
                      const SizedBox(width: 8),
                      _badge('كمية محدودة: $stock', AppTheme.warningColor),
                    ],
                    if (isOutOfStock) ...[
                      const SizedBox(width: 8),
                      _badge('نفذت الكمية', Colors.grey),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(item['description'] ?? '',
                    style: AppTheme.bodyMd.copyWith(
                        color: isOutOfStock ? Colors.grey : AppTheme.textMuted),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${item['price'] ?? 0} ج.س',
                        style: AppTheme.priceLg.copyWith(
                            fontSize: 18,
                            color: isOutOfStock
                                ? Colors.grey
                                : AppTheme.primaryColor)),
                    if (!isOutOfStock)
                      SizedBox(
                        height: 32,
                        child: ElevatedButton(
                          onPressed: () {
                            final attrs = item['attributes'];
                            if (attrs != null &&
                                attrs is Map &&
                                attrs.isNotEmpty) {
                              _showAttributeSelection(context, ref, item);
                            } else {
                              ref
                                  .read(cartProvider.notifier)
                                  .addToCart(item['id']);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'تمت إضافة "${item['name']}" للسلة')));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryLight,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text('إضافة',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Image
          Opacity(
            opacity: isOutOfStock ? 0.5 : 1.0,
            child: ClipRRect(
              borderRadius: AppTheme.radiusMd,
              child: item['main_image'] != null
                  ? Image.network(item['main_image'],
                      width: 90, height: 90, fit: BoxFit.cover)
                  : Container(
                      width: 90,
                      height: 90,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Color(0xFFE8F4FD), Color(0xFFD5EEF9)]),
                      ),
                      child: const Icon(Icons.restaurant_menu,
                          color: AppTheme.primaryLight, size: 36),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, color: color, fontWeight: FontWeight.w700)),
    );
  }
}

// ─── Reviews Tab ──────────────────────────────────────────
class _ReviewsTab extends ConsumerWidget {
  final String providerId;
  const _ReviewsTab({required this.providerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(providerDetailProvider(providerId));
    final reviews = state.reviews;
    final provider = state.provider;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Rating Summary
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFFFEF9E7), Color(0xFFFDF2CC)]),
            borderRadius: AppTheme.radiusMd,
          ),
          child: Row(
            children: [
              Column(
                children: [
                  Text(provider?.ratingAvg.toStringAsFixed(1) ?? '0.0',
                      style: const TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.warningColor)),
                  Row(
                      children: List.generate(
                          5,
                          (i) => const Icon(Icons.star_rounded,
                              color: AppTheme.warningColor, size: 18))),
                  const SizedBox(height: 4),
                  Text('${provider?.ratingCount ?? 0} تقييم',
                      style: AppTheme.bodySm),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [5, 4, 3, 2, 1].map((star) {
                    final pct = [0.76, 0.15, 0.05, 0.02, 0.02][5 - star];
                    return Row(
                      children: [
                        Text('$star',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                        const Icon(Icons.star,
                            color: AppTheme.warningColor, size: 12),
                        const SizedBox(width: 6),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: pct,
                            backgroundColor: Colors.grey[200],
                            color: AppTheme.warningColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text('${(pct * 100).round()}%',
                            style: const TextStyle(fontSize: 11)),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Reviews
        if (reviews.isEmpty)
          const Center(
              child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('لا توجد تقييمات حتى الآن',
                      style:
                          TextStyle(color: Colors.grey, fontFamily: 'Cairo')))),
        ...reviews.map((r) => _ReviewCard(review: r)),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Map review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.radiusMd,
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.primaryLight,
                backgroundImage: review['profile_image'] != null
                    ? NetworkImage(review['profile_image'])
                    : null,
                child: review['profile_image'] == null
                    ? Text(
                        (review['full_name'] as String?)?.isNotEmpty == true
                            ? review['full_name'][0]
                            : 'U',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700))
                    : null,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(review['full_name'] ?? 'مستخدم',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                  Text(
                      review['created_at'] != null
                          ? review['created_at'].toString().substring(0, 10)
                          : '',
                      style: AppTheme.bodySm),
                ],
              ),
              const Spacer(),
              Row(
                children: List.generate(
                  (review['rating'] as num?)?.toInt() ?? 5,
                  (_) => const Icon(Icons.star_rounded,
                      color: AppTheme.warningColor, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(review['comment'] ?? '', style: AppTheme.bodyMd),
        ],
      ),
    );
  }
}

// ─── Info Tab ─────────────────────────────────────────────
class _InfoTab extends ConsumerWidget {
  final String providerId;
  const _InfoTab({required this.providerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(providerDetailProvider(providerId));
    final info = state.provider;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoSection(title: 'معلومات الاتصال', items: [
          _InfoItem(
              icon: Icons.phone_outlined,
              label: 'هاتف',
              value: '----'), // Replace with actual tel if provided in API
          _InfoItem(
              icon: Icons.store_outlined,
              label: 'الاسم التجاري',
              value: info?.businessName ?? '----'),
        ]),
        const SizedBox(height: 16),
        _InfoSection(title: 'ساعات العمل', items: [
          _InfoItem(
              icon: Icons.access_time,
              label: 'السبت - الأربعاء',
              value: '9:00 ص - 11:00 م'),
          _InfoItem(
              icon: Icons.access_time,
              label: 'الخميس - الجمعة',
              value: '9:00 ص - 1:00 ص'),
        ]),
        const SizedBox(height: 16),
        _InfoSection(title: 'الموقع', items: [
          _InfoItem(
              icon: Icons.location_on_outlined,
              label: 'العنوان',
              value: 'الرياض، حي النخيل، شارع الأمير فيصل'),
        ]),
        const SizedBox(height: 16),
        // Branches Section (Phase 68)
        if (info != null &&
            info.branches != null &&
            info.branches.isNotEmpty) ...[
          _InfoSection(
            title: 'فروعنا (${info.branches.length})',
            items: info.branches.map<Widget>((branch) {
              return ListTile(
                leading: const Icon(Icons.location_on,
                    color: AppTheme.primaryLight, size: 20),
                title: Text(branch['name'] ?? 'فرع إضافي',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        fontFamily: 'Cairo')),
                subtitle: Text(branch['branch_address'] ?? '',
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
                trailing: const Icon(Icons.directions_outlined,
                    size: 18, color: AppTheme.accentColor),
                dense: true,
                onTap: () {}, // Open in Maps
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
        // Map placeholder
        Container(
          height: 160,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F4FD),
            borderRadius: AppTheme.radiusMd,
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map_outlined,
                    size: 48, color: AppTheme.primaryLight),
                SizedBox(height: 8),
                Text('عرض الخريطة',
                    style: TextStyle(
                        color: AppTheme.primaryLight,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> items;
  const _InfoSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTheme.headingSm),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppTheme.radiusMd,
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoItem(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryLight, size: 20),
      title: Text(label, style: AppTheme.bodySm),
      subtitle: Text(value,
          style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppTheme.textPrimary)),
      dense: true,
    );
  }
}

// ─── Sticky Tab Delegate ───────────────────────────────────
class _StickyTabBar extends SliverPersistentHeaderDelegate {
  final TabController controller;
  const _StickyTabBar(this.controller);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: controller,
        labelColor: AppTheme.primaryLight,
        unselectedLabelColor: AppTheme.textMuted,
        indicatorColor: AppTheme.primaryLight,
        indicatorWeight: 3,
        labelStyle: const TextStyle(
            fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 14),
        tabs: const [
          Tab(text: 'القائمة'),
          Tab(text: 'التقييمات'),
          Tab(text: 'المعلومات'),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 48;
  @override
  double get minExtent => 48;
  @override
  bool shouldRebuild(_) => false;
}

// ─── Attribute Selection Sheet ──────────────────────────────
void _showAttributeSelection(BuildContext context, WidgetRef ref, Map item) {
  final attributes = Map<String, dynamic>.from(item['attributes'] ?? {});
  final selected = <String, String>{};

  // Initialize with first values
  attributes.forEach((key, values) {
    if (values is List && values.isNotEmpty) {
      selected[key] = values[0].toString();
    }
  });

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
    builder: (context) => StatefulBuilder(
      builder: (context, setModalState) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),
            Text(item['name'] ?? '', style: AppTheme.headingMd),
            const SizedBox(height: 8),
            Text('اختر خيارات المنتج للمتابعة', style: AppTheme.bodyMd),
            const Divider(height: 32),
            ...attributes.entries.map((entry) {
              final key = entry.key;
              final values =
                  List<String>.from(entry.value is List ? entry.value : []);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(key,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: values.map((val) {
                      final isSelected = selected[key] == val;
                      return ChoiceChip(
                        label: Text(val),
                        selected: isSelected,
                        onSelected: (s) =>
                            setModalState(() => selected[key] = val),
                        selectedColor: AppTheme.primaryLight.withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppTheme.primaryLight
                              : AppTheme.textPrimary,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }).toList(),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  ref
                      .read(cartProvider.notifier)
                      .addToCart(item['id'], selectedAttributes: selected);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content:
                          Text('تمت إضافة "${item['name']}" بخياراتك للسلة')));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('تأكيد الإضافة',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
