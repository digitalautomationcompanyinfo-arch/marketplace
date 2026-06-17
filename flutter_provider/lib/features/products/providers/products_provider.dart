import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_service.dart';

class ProviderProduct {
  final String id;
  final String name, description, price, mainImage;
  final bool isAvailable;
  final String? categoryId;
  final String? barcode;
  final Map<String, dynamic> attributes;

  ProviderProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.mainImage,
    required this.isAvailable,
    this.categoryId,
    this.barcode,
    required this.attributes,
  });

  factory ProviderProduct.fromJson(Map j) => ProviderProduct(
        id: j['id'] as String,
        name: j['name'] as String,
        description: j['description'] as String? ?? '',
        price: j['price'] as String,
        mainImage: j['main_image'] as String? ?? '',
        isAvailable: j['is_available'] as bool? ?? true,
        categoryId: j['category_id'] as String?,
        barcode: j['barcode'] as String?,
        attributes: j['attributes'] is Map
            ? Map<String, dynamic>.from(j['attributes'])
            : {},
      );
}

class ProductsState {
  final List<ProviderProduct> products;
  final bool isLoading;
  final String? error;

  ProductsState({this.products = const [], this.isLoading = false, this.error});

  ProductsState copyWith(
          {List<ProviderProduct>? products, bool? isLoading, String? error}) =>
      ProductsState(
        products: products ?? this.products,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class ProductsNotifier extends StateNotifier<ProductsState> {
  ProductsNotifier() : super(ProductsState()) {
    loadProducts();
  }

  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true);
    try {
      final res = await ApiService.instance.getMyProducts();
      final list = (res['data'] as List)
          .map((i) => ProviderProduct.fromJson(i as Map))
          .toList();
      state = state.copyWith(products: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> toggleAvailability(String productId, bool current) async {
    try {
      await ApiService.instance
          .updateProduct(productId, {'is_available': !current});
      await loadProducts();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await ApiService.instance.deleteProduct(productId);
      await loadProducts();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final productsProvider = StateNotifierProvider<ProductsNotifier, ProductsState>(
    (ref) => ProductsNotifier());
