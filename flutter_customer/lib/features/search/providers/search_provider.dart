import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';

final searchProvider =
    StateNotifierProvider<SearchNotifier, AsyncValue<List<dynamic>>>((ref) {
  return SearchNotifier();
});

class SearchNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  SearchNotifier() : super(const AsyncValue.data([]));

  Future<void> search({
    required String query,
    String? categoryId,
    double? ratingMin,
    double? radius,
    double? lat,
    double? lng,
  }) async {
    state = const AsyncValue.loading();
    try {
      final filters = <String, dynamic>{};
      if (categoryId != null) filters['category_id'] = categoryId;
      if (ratingMin != null) filters['rating_min'] = ratingMin;
      if (radius != null) filters['radius'] = radius;
      if (lat != null) filters['lat'] = lat;
      if (lng != null) filters['lng'] = lng;

      final res =
          await ApiService.instance.searchProviders(query, filters: filters);
      final list = (res['data'] as List<dynamic>?) ??
          (res['data']?['providers'] as List<dynamic>?) ??
          [];
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
