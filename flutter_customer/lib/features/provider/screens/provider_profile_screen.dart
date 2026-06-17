import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../reviews/providers/review_provider.dart';

class ProviderProfileScreen extends ConsumerStatefulWidget {
  final String providerId;
  const ProviderProfileScreen({super.key, required this.providerId});
  @override
  ConsumerState<ProviderProfileScreen> createState() =>
      _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends ConsumerState<ProviderProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    Future.microtask(() => ref
        .read(reviewProvider.notifier)
        .loadProviderReviews(widget.providerId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── صورة الغلاف + الأزرار ────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: const Color(0xFF1A3C5E),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(fit: StackFit.expand, children: [
                CachedNetworkImage(
                  imageUrl: 'https://via.placeholder.com/400x220',
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) =>
                      Container(color: const Color(0xFF1A3C5E)),
                ),
                const DecoratedBox(
                    decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black54]),
                )),
              ]),
            ),
            actions: [
              IconButton(
                icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.white),
                onPressed: () => setState(() => _isFavorite = !_isFavorite),
              ),
              IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () {}),
            ],
          ),

          // ─── معلومات المزود ───────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      // الشعار
                      CircleAvatar(
                          radius: 32,
                          backgroundColor: const Color(0xFFD6EAF8),
                          child: const Icon(Icons.store,
                              color: Color(0xFF2980B9), size: 32)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            const Text('مطعم البيت الأصيل',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            Row(children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 16),
                              const Text(' 4.7 ',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              const Text('(142 تقييم)',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 13)),
                            ]),
                          ])),
                    ]),

                    const SizedBox(height: 12),

                    // الحالة والمسافة
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: const Color(0xFFD5F5E3),
                            borderRadius: BorderRadius.circular(20)),
                        child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.circle,
                                  color: Color(0xFF27AE60), size: 8),
                              SizedBox(width: 4),
                              Text('مفتوح الآن',
                                  style: TextStyle(
                                      color: Color(0xFF27AE60),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                            ]),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.location_on,
                          color: Colors.grey, size: 16),
                      const Text('1.2 كم',
                          style: TextStyle(color: Colors.grey, fontSize: 13)),
                      const SizedBox(width: 12),
                      const Icon(Icons.access_time,
                          color: Colors.grey, size: 16),
                      const Text('9ص - 11م',
                          style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ]),

                    const SizedBox(height: 12),
                    const Text(
                        'نقدم أشهى الأكلات الشعبية السعودية بمكونات طازجة يومياً. خدمة توصيل سريع لجميع أحياء المدينة.',
                        style: TextStyle(color: Colors.black87, height: 1.5)),

                    const SizedBox(height: 16),

                    // أزرار التواصل
                    Row(children: [
                      Expanded(
                          child: _ContactBtn(
                              icon: Icons.chat_bubble,
                              label: 'رسالة',
                              color: const Color(0xFF2980B9),
                              onTap: () => context.push('/chat/123',
                                  extra: 'مطعم البيت الأصيل'))),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _ContactBtn(
                              icon: Icons.phone,
                              label: 'اتصال',
                              color: const Color(0xFF27AE60),
                              onTap: () =>
                                  launchUrl(Uri.parse('tel:+966501234567')))),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _ContactBtn(
                              icon: Icons.chat,
                              label: 'واتساب',
                              color: const Color(0xFF25D366),
                              onTap: () => launchUrl(
                                  Uri.parse('https://wa.me/966501234567')))),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _ContactBtn(
                              icon: Icons.map,
                              label: 'خريطة',
                              color: const Color(0xFFE74C3C),
                              onTap: () => launchUrl(Uri.parse(
                                  'https://maps.google.com/?q=24.7136,46.6753')))),
                    ]),
                  ]),
            ),
          ),

          // ─── التبويبات ────────────────────────────────
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabDelegate(TabBar(
              controller: _tabs,
              labelColor: const Color(0xFF2980B9),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF2980B9),
              tabs: const [
                Tab(text: 'المنتجات'),
                Tab(text: 'الصور'),
                Tab(text: 'التقييمات')
              ],
            )),
          ),

          // ─── محتوى التبويبات ──────────────────────────
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabs,
              children: [
                // المنتجات
                GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.8),
                  itemCount: 8,
                  itemBuilder: (_, i) => _ProductCard(
                      name: 'منتج ${i + 1}', price: '${(i + 1) * 15} ج.س'),
                ),
                // الصور
                GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4),
                  itemCount: 9,
                  itemBuilder: (_, i) => Container(
                      color: Colors.grey[300],
                      child: Center(
                          child: Icon(Icons.image, color: Colors.grey[500]))),
                ),
                // التقييمات
                ref.watch(reviewProvider).isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ref.watch(reviewProvider).reviews.isEmpty
                        ? const Center(child: Text('لا توجد تقييمات بعد'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: ref.watch(reviewProvider).reviews.length,
                            itemBuilder: (_, i) {
                              final r = ref.watch(reviewProvider).reviews[i];
                              return _ReviewCard(
                                name: r.userName,
                                rating: r.rating.toInt(),
                                comment: r.comment,
                                date: r.createdAt,
                              );
                            },
                          ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ContactBtn(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.3))),
          child: Column(children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
        ),
      );
}

class _ProductCard extends StatelessWidget {
  final String name, price;
  const _ProductCard({required this.name, required this.price});
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12))),
                  child: const Center(
                      child:
                          Icon(Icons.fastfood, size: 48, color: Colors.grey)))),
          Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(price,
                        style: const TextStyle(
                            color: Color(0xFF27AE60),
                            fontWeight: FontWeight.bold)),
                  ])),
        ]),
      );
}

class _ReviewCard extends StatelessWidget {
  final String name, comment;
  final int rating;
  final DateTime date;

  const _ReviewCard(
      {required this.name,
      required this.rating,
      required this.comment,
      required this.date});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(
                radius: 18, child: Text(name.isNotEmpty ? name[0] : '?')),
            const SizedBox(width: 8),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: TextStyle(color: Colors.grey[400], fontSize: 10),
                ),
              ],
            )),
            Row(
                children: List.generate(
                    5,
                    (i) => Icon(Icons.star,
                        size: 14,
                        color: i < rating ? Colors.amber : Colors.grey[300]))),
          ]),
          const SizedBox(height: 8),
          Text(comment,
              style: const TextStyle(color: Colors.black87, height: 1.4)),
        ]),
      );
}

class _TabDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _TabDelegate(this.tabBar);
  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;
  @override
  Widget build(context, _, __) => Container(color: Colors.white, child: tabBar);
  @override
  bool shouldRebuild(_) => false;
}
