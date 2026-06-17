import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../../home/providers/home_provider.dart';

class ProviderDetailState {
  final Provider? provider;
  final List<dynamic> products;
  final List<dynamic> reviews;
  final bool isLoading;
  final String? error;

  ProviderDetailState({
    this.provider,
    this.products = const [],
    this.reviews = const [],
    this.isLoading = true,
    this.error,
  });

  ProviderDetailState copyWith({
    Provider? provider,
    List<dynamic>? products,
    List<dynamic>? reviews,
    bool? isLoading,
    String? error,
  }) {
    return ProviderDetailState(
      provider: provider ?? this.provider,
      products: products ?? this.products,
      reviews: reviews ?? this.reviews,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ProviderDetailNotifier extends StateNotifier<ProviderDetailState> {
  final String providerId;

  ProviderDetailNotifier(this.providerId) : super(ProviderDetailState()) {
    loadData();
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true);
    try {
      final results = await Future.wait([
        ApiService.instance.getProvider(providerId),
        ApiService.instance.getProviderProducts(providerId),
        ApiService.instance.getProviderReviews(providerId),
      ]);

      final providerData = results[0]['data'] as Map;
      final productsData = results[1]['data'] as List? ?? [];
      final reviewsData = results[2]['data'] as List? ?? [];

      state = state.copyWith(
        provider: Provider.fromJson(providerData),
        products: productsData,
        reviews: reviewsData,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final providerDetailProvider = StateNotifierProvider.family<
    ProviderDetailNotifier, ProviderDetailState, String>(
  (ref, providerId) => ProviderDetailNotifier(providerId),
);
