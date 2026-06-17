// api_service.dart - خدمة الـ API المركزية لـ Flutter
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static ApiService? _instance;
  late final Dio _dio;

  ApiService._() {
    _dio = Dio(BaseOptions(
      baseUrl: dotenv.env['API_URL'] ?? 'https://api.marketplace.com/api/v1',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    // إرفاق التوكن تلقائياً
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        const storage = FlutterSecureStorage();
        final token = await storage.read(key: 'access_token');
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
      onError: (error, handler) async {
        // FIX Phase 16: Networking Resilience (Scientific Standard)
        // Retry logic for transient errors (ConnectTimeout, 503, 504)
        final isTransientError = 
            error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.sendTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            [503, 504, 408].contains(error.response?.statusCode);

        final retryCount = error.requestOptions.extra['retry_count'] ?? 0;

        if (isTransientError && retryCount < 3) {
          error.requestOptions.extra['retry_count'] = retryCount + 1;
          
          // Exponential Backoff: Wait longer between each retry (2s, 4s, 8s)
          final delayInSeconds = (retryCount + 1) * 2;
          await Future.delayed(Duration(seconds: delayInSeconds));
          
          final retryRes = await _dio.fetch(error.requestOptions);
          return handler.resolve(retryRes);
        }

        if (error.response?.statusCode == 401) {
          const storage = FlutterSecureStorage();
          final refreshToken = await storage.read(key: 'refresh_token');
          if (refreshToken != null) {
            try {
              final refreshRes = await Dio().post(
                '${dotenv.env['API_URL'] ?? 'https://api.marketplace.com/api/v1'}/auth/refresh',
                data: {'refreshToken': refreshToken},
              );
              final newToken =
                  refreshRes.data['data']['accessToken'] as String?;
              final newRefresh =
                  refreshRes.data['data']['refreshToken'] as String?;
              if (newToken != null) {
                await storage.write(key: 'access_token', value: newToken);
                if (newRefresh != null)
                  await storage.write(key: 'refresh_token', value: newRefresh);
                error.requestOptions.headers['Authorization'] =
                    'Bearer $newToken';
                final retryRes = await _dio.fetch(error.requestOptions);
                return handler.resolve(retryRes);
              }
            } catch (_) {
              await storage.deleteAll();
            }
          }
        }
        
        // FIX: Handle 409 Conflict (Race Condition / Resource Locked)
        if (error.response?.statusCode == 409) {
          final msg = error.response?.data['message'] ?? 'عذراً، هذا المورد تم حجزه أو استخدامه للتو';
          return handler.next(DioException(
            requestOptions: error.requestOptions,
            response: error.response,
            type: DioExceptionType.badResponse,
            message: msg,
          ));
        }

        handler.next(error);
      },
    ));
  }

  static ApiService get instance => _instance ??= ApiService._();

  // ─── Auth ────────────────────────────────────────────
  Future<Map> register(Map data) => post('/auth/register', data);
  Future<Map> login(Map data) => post('/auth/login', data);
  Future<Map> verifyOTP(Map data) => post('/auth/verify-otp', data);
  Future<Map> resendOTP(String identifier, {String method = 'sms'}) =>
      post('/auth/resend-otp', {'identifier': identifier, 'method': method});
  Future<Map> refreshToken(String r) =>
      post('/auth/refresh', {'refreshToken': r});

  // ─── Providers ───────────────────────────────────────
  Future<Map> getProviders({Map? params}) => get('/providers', params);
  Future<Map> getNearby(
          {required double lat, required double lng, int radius = 20}) =>
      get('/providers/nearby', {'lat': lat, 'lng': lng, 'radius': radius});
  Future<Map> getProvider(String uuid) => get('/providers/$uuid');

  // ─── Search ──────────────────────────────────────────
  Future<Map> search(String q, {Map? filters}) {
    if (filters?['lat'] != null && filters?['lng'] != null) {
      return get('/providers/nearby', {'q': q, ...?filters});
    }
    return get('/providers', {'q': q, ...?filters});
  }

  Future<Map> autocomplete(String q) =>
      get('/search/autocomplete', {'q': q, 'limit': 5});
  Future<Map> getTrendingProviders({String? stateId}) => get(
      '/search/trending/providers',
      stateId != null ? {'state_id': stateId} : null);

  // ─── Products ────────────────────────────────────────
  Future<Map> getProviderProducts(String id) => get('/products/provider/$id');
  Future<Map> lookupBarcode(String code) => get('/products/barcode/$code');
  Future<Map> getMyProducts({Map? params}) => get('/products', params);
  Future<Map> createProduct(FormData data) => postForm('/products', data);

  // ─── Messages ────────────────────────────────────────
  Future<Map> getConversations() => get('/messages/user/conversations');
  Future<Map> getOrCreateConversation(String providerUuid) =>
      post('/messages/user/conversations', {'provider_uuid': providerUuid});
  Future<Map> getMessages(String convId, {String? before}) => get(
      '/messages/user/conversations/$convId/messages',
      before != null ? {'before': before} : null);

  // ─── Subscriptions ───────────────────────────────────
  Future<Map> getPlans() => get('/subscriptions/plans');
  Future<Map> createPaymentIntent(Map data) =>
      post('/subscriptions/intent', data);
  Future<Map> confirmSubscription(Map data) =>
      post('/subscriptions/confirm', data);

  // ─── Reviews ─────────────────────────────────────────
  Future<Map> addReview(Map data) => post('/reviews', data);

  // ─── User ────────────────────────────────────────────
  Future<Map> getProfile() => get('/users/profile');
  Future<Map> getFavorites() => get('/users/favorites');
  Future<Map> toggleFavorite(String uuid) =>
      post('/users/favorites/toggle', {'provider_uuid': uuid});
  Future<Map> updateFCMToken(String t) =>
      post('/users/fcm-token', {'token': t});

  // ─── Wallet & Points ─────────────────────────────────
  Future<Map> getWalletData() => get('/users/wallet');
  Future<Map> convertPoints(int p) =>
      post('/users/wallet/convert', {'points': p});

  // ─── Cart ────────────────────────────────────────────
  Future<Map> getCart() => get('/cart');
  Future<Map> addToCart(Map data) => post('/cart', data);
  Future<Map> updateCartItem(String i, int q) =>
      patch('/cart/$i', {'quantity': q});
  Future<Map> removeFromCart(String i) => delete('/cart/$i');
  Future<Map> clearCart() => delete('/cart');

  // ─── Orders ──────────────────────────────────────────
  Future<Map> createOrder(Map data) => post('/orders', data);
  Future<Map> getMyOrders() => get('/orders/my/orders');
  Future<Map> getProviderOrders() => get('/orders/provider/orders');
  Future<Map> getOrderDetails(String id) => get('/orders/$id');
  Future<Map> updateOrderStatus(String id, String status) =>
      patch('/orders/$id/status', {'status': status});

  // ─── Tendering ───────────────────────────────────────
  Future<Map> createServiceRequest(Map d) => post('/tendering/requests', d);
  Future<Map> getMyServiceRequests() => get('/tendering/requests/my');
  Future<Map> getRequestBids(String id) => get('/tendering/requests/$id/bids');
  Future<Map> acceptBid(String bidId) =>
      post('/tendering/requests/accept-bid', {'bid_id': bidId});

  // ─── Notifications ───────────────────────────────────
  Future<Map> getNotifications({int limit = 20, int page = 1}) =>
      get('/users/notifications', {'limit': limit, 'page': page});
  Future<Map> markNotificationRead(String id) =>
      patch('/users/notifications/$id', {});

  // ─── Wallet & Payments ──────────────────────────────────
  Future<Map> getWalletTransactions() => get('/wallet/transactions');
  Future<Map> initTopup(double amount) =>
      post('/wallet/topup/init', {'amount': amount});
  Future<Map> verifyTopup(String transactionId, double amount) => post(
      '/wallet/topup/verify',
      {'transaction_id': transactionId, 'amount': amount});

  // ─── Reviews ────────────────────────────────────────────
  Future<Map> getProviderReviews(String providerUuid) =>
      get('/reviews/provider/$providerUuid');
  Future<Map> getProductReviews(String productUuid) =>
      get('/reviews/product/$productUuid');

  // ─── AI Support ─────────────────────────────────────────
  Future<Map> sendSupportMessage(String text, List history) =>
      post('/ai/support', {'message': text, 'history': history});

  Future<Map> getCategories() => get('/categories');

  // ─── helpers ─────────────────────────────────────────
  Future<Map> get(String path, [Map? params]) async {
    final res = await _dio.get(path,
        queryParameters: params?.map((k, v) => MapEntry(k.toString(), v)));
    return res.data as Map;
  }

  Future<Map> post(String path, Map data) async {
    final res = await _dio.post(path, data: data);
    return res.data as Map;
  }

  Future<Map> patch(String path, Map data) async {
    final res = await _dio.patch(path, data: data);
    return res.data as Map;
  }

  Future<Map> delete(String path) async {
    final res = await _dio.delete(path);
    return res.data as Map;
  }

  Future<Map> postForm(String path, FormData data) async {
    final res = await _dio.post(path, data: data);
    return res.data as Map;
  }
}
