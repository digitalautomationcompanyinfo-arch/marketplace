import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';

  final String id, productId, providerId;
  final int quantity;
  final String name, price, mainImage, providerName;
  final Map<String, dynamic> selectedAttributes;

  CartItem({
    required this.id, required this.productId, required this.providerId, required this.quantity,
    required this.name, required this.price, required this.mainImage,
    required this.providerName, this.selectedAttributes = const {},
  });

  factory CartItem.fromJson(Map j) => CartItem(
    id:           j['id'] as String,
    productId:    j['product_id'] as String,
    providerId:   j['provider_id'] as String? ?? '1',
    quantity:     j['quantity'] as int,
    name:         j['name'] as String,
    price:        j['price'] as String,
    mainImage:    j['main_image'] as String? ?? '',
    providerName: j['provider_name'] as String? ?? '',
    selectedAttributes: j['selected_attributes'] is Map ? Map<String, dynamic>.from(j['selected_attributes']) : {},
  );

  double get totalPrice => double.tryParse(price) ?? 0.0 * quantity;
}

class CartState {
  final List<CartItem> items;
  final bool isLoading;
  final String? error;

  CartState({this.items = const [], this.isLoading = false, this.error});

  double get totalAmount => items.fold(0, (sum, item) => sum + (double.tryParse(item.price) ?? 0.0) * item.quantity);

  CartState copyWith({List<CartItem>? items, bool? isLoading, String? error}) => CartState(
    items:     items     ?? this.items,
    isLoading: isLoading ?? this.isLoading,
    error:     error,
  );
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(CartState());

  Future<void> loadCart() async {
    state = state.copyWith(isLoading: true);
    try {
      final res = await ApiService.instance.getCart();
      final list = (res['data'] as List).map((i) => CartItem.fromJson(i as Map)).toList();
      state = state.copyWith(items: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addToCart(String productId, {int quantity = 1, Map<String, dynamic>? selectedAttributes}) async {
    try {
      await ApiService.instance.addToCart({
        'product_id': productId,
        'quantity': quantity,
        'selected_attributes': selectedAttributes ?? {},
      });
      await loadCart();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    try {
      await ApiService.instance.updateCartItem(itemId, quantity);
      await loadCart();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> removeItem(String itemId) async {
    try {
      await ApiService.instance.removeFromCart(itemId);
      await loadCart();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> clearCart() async {
    try {
      await ApiService.instance.clearCart();
      state = state.copyWith(items: []);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) => CartNotifier());

