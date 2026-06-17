// onboarding_screen.dart - Beautiful onboarding flow
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _current = 0;

  final _pages = [
    {
      'emoji': '🏪',
      'title': 'اكتشف الخدمات',
      'desc': 'آلاف مزودي الخدمات في مكان واحد، من مطاعم ومحلات وخدمات منزلية'
    },
    {
      'emoji': '⚡',
      'title': 'طلب بضغطة واحدة',
      'desc': 'اطلب خدمتك المفضلة بسهولة وتتبع حالة طلبك في الوقت الفعلي'
    },
    {
      'emoji': '💬',
      'title': 'تواصل مباشر',
      'desc': 'تحدث مباشرة مع مزود الخدمة وقيّم تجربتك لمساعدة الآخرين'
    },
  ];

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Expanded(
          child: PageView.builder(
            controller: _pageCtrl,
            onPageChanged: (i) => setState(() => _current = i),
            itemCount: _pages.length,
            itemBuilder: (_, i) => _OnboardPage(page: _pages[i]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                  _pages.length,
                  (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _current == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _current == i
                              ? AppTheme.primaryLight
                              : AppTheme.borderColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                if (_current < _pages.length - 1) {
                  _pageCtrl.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut);
                } else {
                  context.go('/auth/login');
                }
              },
              child:
                  Text(_current < _pages.length - 1 ? 'التالي' : 'ابدأ الآن'),
            ),
            if (_current < _pages.length - 1) ...[
              const SizedBox(height: 12),
              TextButton(
                  onPressed: () => context.go('/auth/login'),
                  child: const Text('تخطي')),
            ],
          ]),
        ),
      ]),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  final Map page;
  const _OnboardPage({required this.page});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFFE8F4FD), Color(0xFFD5EEF9)]),
              borderRadius: AppTheme.radiusXl),
          child: Center(
              child:
                  Text(page['emoji']!, style: const TextStyle(fontSize: 72))),
        ),
        const SizedBox(height: 48),
        Text(page['title']!,
            style: AppTheme.headingXl, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        Text(page['desc']!,
            style: AppTheme.bodyLg
                .copyWith(color: AppTheme.textSecondary, height: 1.6),
            textAlign: TextAlign.center),
      ]),
    );
  }
}
