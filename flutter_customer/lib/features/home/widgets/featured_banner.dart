// featured_banner.dart - Horizontal banner carousel widget
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class PromoBannerCarousel extends StatefulWidget {
  const PromoBannerCarousel({super.key});
  @override
  State<PromoBannerCarousel> createState() => _PromoBannerCarouselState();
}

class _PromoBannerCarouselState extends State<PromoBannerCarousel> {
  int _current = 0;
  final PageController _ctrl = PageController(viewportFraction: 0.92);

  final _banners = const [
    {
      'title': 'خصم 30% على المطاعم',
      'sub': 'عروض حصرية لوقت محدود',
      'emoji': '🍔',
      'color1': 0xFF1A3C5E,
      'color2': 0xFF2980B9
    },
    {
      'title': 'توصيل مجاني',
      'sub': 'على أول 3 طلبات لك',
      'emoji': '🚚',
      'color1': 0xFF1E8449,
      'color2': 0xFF27AE60
    },
    {
      'title': 'احجز خدمتك الآن',
      'sub': 'آلاف مزودي الخدمة في انتظارك',
      'emoji': '⭐',
      'color1': 0xFF7D3C98,
      'color2': 0xFF8E44AD
    },
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        height: 140,
        child: PageView.builder(
          controller: _ctrl,
          onPageChanged: (i) => setState(() => _current = i),
          itemCount: _banners.length,
          itemBuilder: (_, i) {
            final b = _banners[i];
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(b['color1'] as int),
                    Color(b['color2'] as int)
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: AppTheme.radiusLg,
                boxShadow: AppTheme.shadowMd,
              ),
              child: InkWell(
                onTap: () => context.push('/search'),
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(children: [
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                          Text(b['title'] as String,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  fontFamily: 'Cairo')),
                          const SizedBox(height: 6),
                          Text(b['sub'] as String,
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 13,
                                  fontFamily: 'Cairo')),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20)),
                            child: const Text('استكشف الآن',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    fontFamily: 'Cairo')),
                          ),
                        ])),
                    Text(b['emoji'] as String,
                        style: const TextStyle(fontSize: 56)),
                  ]),
                ),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 10),
      Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _current == i ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _current == i
                    ? AppTheme.primaryLight
                    : AppTheme.borderColor,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          )),
    ]);
  }
}
