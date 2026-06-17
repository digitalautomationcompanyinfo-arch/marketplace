import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/verify_otp_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/search/screens/search_screen.dart';
import '../../features/provider/screens/provider_profile_screen.dart';
import '../../features/messages/screens/conversations_screen.dart';
import '../../features/messages/screens/chat_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/wallet_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/cart/screens/cart_screen.dart';
import '../../features/orders/screens/orders_screen.dart';
import '../../features/orders/screens/order_details_screen.dart';
import '../../features/orders/screens/checkout_screen.dart';
import '../../features/support/screens/support_chat_screen.dart';
import '../../features/tendering/screens/post_request_screen.dart';
import '../../features/tendering/screens/my_requests_screen.dart';
import '../providers/auth_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggedIn = authState.isLoggedIn;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');
      final isSplash = state.matchedLocation == '/splash';

      if (isSplash) return null;
      if (!isLoggedIn && !isAuthRoute) return '/auth/login';
      if (isLoggedIn && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      // Splash & Onboarding
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(
          path: '/onboarding', builder: (_, __) => const OnboardingScreen()),

      // Auth
      GoRoute(path: '/auth/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
          path: '/auth/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(
        path: '/auth/verify-otp',
        builder: (context, state) => VerifyOtpScreen(
          identifier: state.extra as String,
        ),
      ),

      // Main App - Shell Route (Bottom Navigation)
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
          GoRoute(
              path: '/messages',
              builder: (_, __) => const ConversationsScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),

      // Provider Profile
      GoRoute(
        path: '/provider/:id',
        builder: (context, state) => ProviderProfileScreen(
          providerId: state.pathParameters['id']!,
        ),
      ),

      // Chat
      GoRoute(
        path: '/chat/:conversationId',
        builder: (context, state) => ChatScreen(
          conversationId: state.pathParameters['conversationId']!,
          providerName: state.extra as String? ?? '',
        ),
      ),

      // Notifications
      GoRoute(
          path: '/notifications',
          builder: (_, __) => const NotificationsScreen()),

      // Wallet
      GoRoute(path: '/wallet', builder: (_, __) => const WalletScreen()),

      // Cart
      GoRoute(path: '/cart', builder: (_, __) => const CartScreen()),

      // Checkout
      GoRoute(path: '/checkout', builder: (_, __) => const CheckoutScreen()),

      // Orders
      GoRoute(
        path: '/orders',
        builder: (_, __) => const OrdersScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) => OrderDetailsScreen(
              orderId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
      // Tendering
      GoRoute(
          path: '/tendering/post',
          builder: (_, __) => const PostRequestScreen()),
      GoRoute(
          path: '/tendering/my-requests',
          builder: (_, __) => const MyRequestsScreen()),

      // Support (Phase 62)
      GoRoute(path: '/support', builder: (_, __) => const SupportChatScreen()),
    ],
  );
});

// Bottom Navigation Shell
class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _routes = ['/home', '/search', '/messages', '/profile'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
          context.go(_routes[index]);
        },
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'الرئيسية'),
          NavigationDestination(
              icon: Icon(Icons.search_outlined),
              selectedIcon: Icon(Icons.search),
              label: 'البحث'),
          NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline),
              selectedIcon: Icon(Icons.chat_bubble),
              label: 'الرسائل'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'الملف'),
        ],
      ),
    );
  }
}
