import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';

class Review {
  final int id;
  final double rating;
  final String comment, userName, userImage;
  final List<String> images;
  final DateTime createdAt;

  Review(
      {required this.id,
      required this.rating,
      required this.comment,
      required this.userName,
      required this.userImage,
      required this.images,
      required this.createdAt});

  factory Review.fromJson(Map j) => Review(
        id: j['id'] as int,
        rating: double.parse(j['rating'].toString()),
        comment: j['comment'] as String? ?? '',
        userName: j['full_name'] as String? ?? 'مستخدم',
        userImage: j['profile_image'] as String? ?? '',
        images: List<String>.from(j['images'] ?? []),
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}

class ReviewState {
  final List<Review> reviews;
  final bool isLoading;
  final String? error;

  ReviewState({this.reviews = const [], this.isLoading = false, this.error});

  ReviewState copyWith(
          {List<Review>? reviews, bool? isLoading, String? error}) =>
      ReviewState(
        reviews: reviews ?? this.reviews,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class ReviewNotifier extends StateNotifier<ReviewState> {
  ReviewNotifier() : super(ReviewState());

  Future<void> loadProviderReviews(String providerUuid) async {
    state = state.copyWith(isLoading: true);
    try {
      final res = await ApiService.instance.getProviderReviews(providerUuid);
      final list =
          (res['data'] as List).map((r) => Review.fromJson(r as Map)).toList();
      state = state.copyWith(reviews: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadProductReviews(String productUuid) async {
    state = state.copyWith(isLoading: true);
    try {
      final res = await ApiService.instance.getProductReviews(productUuid);
      final list =
          (res['data'] as List).map((r) => Review.fromJson(r as Map)).toList();
      state = state.copyWith(reviews: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addReview(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true);
    try {
      await ApiService.instance.addReview(data);
      if (data['product_uuid'] != null) {
        await loadProductReviews(data['product_uuid']);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}

final reviewProvider = StateNotifierProvider<ReviewNotifier, ReviewState>(
    (ref) => ReviewNotifier());
