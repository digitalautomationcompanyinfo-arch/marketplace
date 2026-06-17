import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';

// ─── Models ───────────────────────────────────────────────
class Category {
  final int id;
  final String name, icon, color;
  final int providersCount;

  Category(
      {required this.id,
      required this.name,
      required this.icon,
      required this.color,
      required this.providersCount});

  factory Category.fromJson(Map j) => Category(
        id: j['id'] as int,
        name: j['name'] as String,
        icon: j['icon'] as String? ?? '🏪',
        color: j['color'] as String? ?? '#2980B9',
        providersCount: j['providers_count'] as int? ?? 0,
      );
}

class Provider {
  final String uuid, businessName, categoryName, regionName;
  final String? logoUrl, phone;
  final double ratingAvg;
  final int ratingCount;
  final bool isFeatured, isVerified;
  final double? distanceMeters;

  Provider({
    required this.uuid,
    required this.businessName,
    required this.categoryName,
    required this.regionName,
    this.logoUrl,
    this.phone,
    required this.ratingAvg,
    required this.ratingCount,
    required this.isFeatured,
    required this.isVerified,
    this.distanceMeters,
  });

  factory Provider.fromJson(Map j) => Provider(
        uuid: j['uuid'] as String,
        businessName: j['business_name'] as String,
        categoryName: j['category_name'] as String? ?? '',
        regionName: j['region_name'] as String? ?? '',
        logoUrl: j['logo_url'] as String?,
        phone: j['phone'] as String?,
        ratingAvg: (j['rating_avg'] as num?)?.toDouble() ?? 0.0,
        ratingCount: j['rating_count'] as int? ?? 0,
        isFeatured: j['is_featured'] as bool? ?? false,
        isVerified: j['is_verified'] as bool? ?? false,
        distanceMeters: (j['distance_meters'] as num?)?.toDouble(),
      );

  String get distanceText {
    if (distanceMeters == null) return '';
    if (distanceMeters! < 1000) return '${distanceMeters!.toInt()}م';
    return '${(distanceMeters! / 1000).toStringAsFixed(1)} كم';
  }
}

// ─── Home State ───────────────────────────────────────────
class HomeState {
  final List<Category> categories;
  final List<Provider> nearbyProviders;
  final List<Provider> featuredProviders;
  final List<Provider> trendingProviders;
  final bool isLoadingCategories;
  final bool isLoadingProviders;
  final String? error;

  const HomeState({
    this.categories = const [],
    this.nearbyProviders = const [],
    this.featuredProviders = const [],
    this.trendingProviders = const [],
    this.isLoadingCategories = false,
    this.isLoadingProviders = false,
    this.error,
  });

  HomeState copyWith({
    List<Category>? categories,
    List<Provider>? nearbyProviders,
    List<Provider>? featuredProviders,
    List<Provider>? trendingProviders,
    bool? isLoadingCategories,
    bool? isLoadingProviders,
    String? error,
  }) =>
      HomeState(
        categories: categories ?? this.categories,
        nearbyProviders: nearbyProviders ?? this.nearbyProviders,
        featuredProviders: featuredProviders ?? this.featuredProviders,
        trendingProviders: trendingProviders ?? this.trendingProviders,
        isLoadingCategories: isLoadingCategories ?? this.isLoadingCategories,
        isLoadingProviders: isLoadingProviders ?? this.isLoadingProviders,
        error: error,
      );
}

// ─── Home Notifier ────────────────────────────────────────
class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(const HomeState());
  double _lat = 15.5007; // Default Khartoum
  double _lng = 32.5599;

  void setLocation(double lat, double lng) {
    _lat = lat;
    _lng = lng;
  }

  Future<void> loadHomeData() async {
    state = state.copyWith(isLoadingCategories: true, isLoadingProviders: true);

    try {
      // تحميل الفئات والمزودين بالتوازي
      final results = await Future.wait([
        ApiService.instance.getCategories(),
        ApiService.instance
            .getProviders(params: {'sort': 'featured', 'limit': '10'}),
        ApiService.instance.getNearby(lat: _lat, lng: _lng),
        ApiService.instance.getTrendingProviders(),
      ]);

      final cats = (results[0]['data'] as List? ?? [])
          .map((c) => Category.fromJson(c as Map))
          .toList();

      // FIX MEDIUM: Removed redundant .where(is_featured) filter — API already filters by sort=featured
      final featured = (results[1]['data']?['providers'] as List? ?? [])
          .map((p) => Provider.fromJson(p as Map))
          .toList();

      final nearby = (results[2]['data'] as List? ?? [])
          .map((p) => Provider.fromJson(p as Map))
          .toList();

      final trending = (results[3]['data'] as List? ?? [])
          .map((p) => Provider.fromJson(p as Map))
          .toList();

      state = state.copyWith(
        categories: cats,
        featuredProviders: featured,
        nearbyProviders: nearby,
        trendingProviders: trending,
        isLoadingCategories: false,
        isLoadingProviders: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingCategories: false,
        isLoadingProviders: false,
        error: e.toString(),
      );
    }
  }
}

// ─── Providers ────────────────────────────────────────────
final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>(
  (ref) => HomeNotifier(),
);
