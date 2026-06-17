// provider_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/provider_login_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/products/screens/add_product_screen.dart';
import '../../features/stats/screens/stats_screen.dart';
import '../../features/orders/screens/orders_screen.dart';
import '../../features/orders/screens/order_details_screen.dart';
import '../../features/orders/providers/orders_provider.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/profile_edit_screen.dart';
import '../../features/stats/screens/earnings_screen.dart';
import '../../features/products/screens/products_management_screen.dart';
import '../../features/profile/screens/my_qr_code_screen.dart';
import '../../features/profile/screens/my_qr_code_screen.dart';
import '../../features/profile/screens/my_qr_code_screen.dart';
import '../../features/tendering/screens/tendering_feed_screen.dart';
import '../../features/messages/screens/conversations_screen.dart';
import '../../features/messages/screens/chat_screen.dart';
import '../providers/auth_provider.dart';

final providerRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: Listenable.merge([
       // Re-run redirect logic whenever login state changes
    ]),
    redirect: (context, state) {
      final isLoggedIn = ref.read(authProvider).isLoggedIn;
      final isLoggingIn = state.matchedLocation === '/login';

      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/login',     builder: (_, __) => const ProviderLoginScreen()),
      GoRoute(path: '/dashboard', builder: (_, __) => const ProviderDashboardScreen()),
      GoRoute(path: '/profile',   builder: (_, __) => const ProviderProfileScreen()),
      GoRoute(path: '/products/add', builder: (_, __) => const AddProductScreen()),
      GoRoute(path: '/products',  builder: (_, __) => const ProductsManagementScreen()),
      GoRoute(path: '/stats',     builder: (_, __) => const ProviderStatsScreen()),
      GoRoute(path: '/earnings',  builder: (_, __) => const EarningsScreen()),
      GoRoute(path: '/profile/edit', builder: (_, __) => const ProfileEditScreen()),
      GoRoute(path: '/orders',    builder: (_, __) => const ProviderOrdersScreen()),
      GoRoute(
        path: '/orders/:id',
        builder: (context, state) => ProviderOrderDetailsScreen(
          order: state.extra as ProviderOrder,
        ),
      ),
      GoRoute(path: '/provider/my-qr', builder: (_, __) => const MyQrCodeScreen()),
      GoRoute(path: '/tendering/feed', builder: (_, __) => const TenderingFeedScreen()),
      GoRoute(path: '/conversations', builder: (_, __) => const ConversationsScreen()),
      GoRoute(
        path: '/chat/:id',
        builder: (context, state) => ChatScreen(
          conversationId: state.pathParameters['id']!,
          userName: state.extra as String? ?? 'عميل',
        ),
      ),
    ],
  );
});

