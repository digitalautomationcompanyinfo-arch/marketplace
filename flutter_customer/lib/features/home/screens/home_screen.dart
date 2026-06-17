import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/home_provider.dart';
import '../widgets/category_chip.dart';
import '../widgets/provider_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(homeProvider.notifier).loadHomeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/tendering/post'),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
        label: const Text('طلب سريع',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(homeProvider.notifier).loadHomeData(),
        child: CustomScrollView(
          slivers: [
            // ─── Header ──────────────────────────────────────
            SliverAppBar(
              floating: true,
              backgroundColor: AppTheme.primaryColor,
              expandedHeight: 140,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1A3C5E), Color(0xFF2980B9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 50, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset('assets/images/logo_icons.png',
                                height: 32),
                            const SizedBox(width: 8),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('كيف نخدمك',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                Text('How Can We Serve You',
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 9)),
                              ],
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.notifications_outlined,
                                  color: Colors.white),
                              onPressed: () => context.push('/notifications'),
                            ),
                            GestureDetector(
                              onTap: () => context.go('/profile'),
                              child: const CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.white24,
                                  child: Icon(Icons.person,
                                      color: Colors.white, size: 20)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'حبابك 10، داير شنو الليلة؟',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => context.go('/search'),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(color: Colors.black12, blurRadius: 4)
                              ],
                            ),
                            child: const Row(
                              children: [
                                SizedBox(width: 12),
                                Icon(Icons.search, color: Colors.grey),
                                SizedBox(width: 8),
                                Text('ابحث هنا...',
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12)),
                        child: IconButton(
                          icon: const Icon(Icons.mic, color: Color(0xFF2980B9)),
                          onPressed: () => _showVoiceSearch(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ─── Service Visual Hub ──────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('خدماتنا الشاملة',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: [
                        _ServiceItem(
                            icon: Icons.home_repair_service,
                            label: 'صيانة',
                            color: Colors.orange,
                            onTap: () {}),
                        _ServiceItem(
                            icon: Icons.electric_car,
                            label: 'توصيل',
                            color: Colors.blue,
                            onTap: () {}),
                        _ServiceItem(
                            icon: Icons.shopping_basket,
                            label: 'سوبر ماركت',
                            color: Colors.green,
                            onTap: () {}),
                        _ServiceItem(
                            icon: Icons.medical_services,
                            label: 'صحة',
                            color: Colors.red,
                            onTap: () {}),
                        _ServiceItem(
                            icon: Icons.restaurant,
                            label: 'مطاعم',
                            color: Colors.deepOrange,
                            onTap: () {}),
                        _ServiceItem(
                            icon: Icons.cleaning_services,
                            label: 'نظافة',
                            color: Colors.cyan,
                            onTap: () {}),
                        _ServiceItem(
                            icon: Icons.build,
                            label: 'بناء',
                            color: Colors.brown,
                            onTap: () {}),
                        _ServiceItem(
                            icon: Icons.more_horiz,
                            label: 'المزيد',
                            color: Colors.grey,
                            onTap: () {}),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ─── Tendering Section ─────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: InkWell(
                  onTap: () => context.push('/tendering/post'),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFF2980B9), Color(0xFF3498DB)]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.blue.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4))
                      ],
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('طلب عرض سعر مخصص',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                            SizedBox(height: 4),
                            Text('اطلب عروضاً من كافة المزودين في السودان',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                          ],
                        )),
                        Icon(Icons.gavel, color: Colors.white, size: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ─── الأقرب إليك ───────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: Color(0xFF2980B9), size: 18),
                    const SizedBox(width: 4),
                    const Text('مزودون بالقرب منك',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),

            homeState.isLoadingProviders
                ? SliverList(
                    delegate: SliverChildBuilderDelegate(
                        (_, __) => _buildProviderShimmer(),
                        childCount: 5))
                : homeState.nearbyProviders.isEmpty
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Icon(Icons.location_off_outlined,
                                  size: 64, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              const Text(
                                  'لا يوجد مزودون متاحون حالياً بالقرب منك',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500)),
                              TextButton(
                                onPressed: () => ref
                                    .read(homeProvider.notifier)
                                    .loadHomeData(),
                                child: const Text('تحديث الموقع'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) => ProviderCard(
                            provider: homeState.nearbyProviders[i],
                            onTap: () => context.push(
                                '/provider/${homeState.nearbyProviders[i].uuid}'),
                          ),
                          childCount: homeState.nearbyProviders.length,
                        ),
                      ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
    );
  }

  void _showVoiceSearch() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        height: 300,
        child: Column(
          children: [
            const Text('نسمعك الآن...',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text('قل مثلاً: "داير كهربائي في الخرطوم"',
                style: TextStyle(color: Colors.grey)),
            const Spacer(),
            const Icon(Icons.mic, size: 80, color: Color(0xFF2980B9)),
            const Spacer(),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 100,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _ServiceItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ServiceItem(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
