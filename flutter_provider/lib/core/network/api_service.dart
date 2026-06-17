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

        // FIX: Handle 409 Conflict (Race Condition / Item Already Taken)
        if (error.response?.statusCode == 409) {
          final msg = error.response?.data['message'] ?? 'عذراً، هذا الطلب تم قبوله أو حجزه من قبل مزود آخر';
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

  // ─── Authentication ──────────────────────────────────
  Future<void> logout() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'access_token');
  }

  Future<Map> login(Map data) => _post('/auth/provider/login', data);

  // ─── Orders ──────────────────────────────────────────
  Future<Map> getProviderOrders({String? status, String? search}) {
    final params = <String, dynamic>{};
    if (status != null) params['status'] = status;
    if (search != null) params['search'] = search;
    return _get('/orders/provider/orders', params);
  }

  Future<Map> updateOrderStatus(String id, String status) =>
      _patch('/orders/$id/status', {'status': status});
  Future<Map> getOrderDetails(String id) => _get('/orders/$id');

  // ─── Products ────────────────────────────────────────
  Future<Map> createProduct(FormData data) => _postForm('/products', data);
  Future<Map> updateProduct(String id, dynamic data) {
    if (data is FormData) return _patchForm('/products/$id', data);
    return _patch('/products/$id', data);
  }

  Future<Map> deleteProduct(String id) => _delete('/products/$id');

  // ─── Utils ──────────────────────────────────────────
  Future<Map> translate(String text, {String targetLang = 'en'}) =>
      _post('/utils/translate', {'text': text, 'targetLang': targetLang});

  // ─── Provider Profile & Stats ────────────────────────
  Future<Map> getProviderProfile() => _get('/providers/me/profile');
  Future<Map> getProviderStats() => _get('/providers/me/analytics');
  Future<Map> getProviderTransactions() =>
      _get('/providers/me/wallet/transactions');

  // ─── Tendering ───────────────────────────────────────
  Future<Map> getPublicRequests({int? categoryId}) => _get(
      '/tendering/public-feed',
      categoryId != null ? {'category_id': categoryId} : null);
  Future<Map> submitBid(Map d) => _post('/tendering/bids/submit', d);

  // ─── Notifications ───────────────────────────────────
  Future<Map> getNotifications({int limit = 20, int page = 1}) =>
      _get('/providers/me/notifications', {'limit': limit, 'page': page});
  Future<Map> markNotificationRead(String id) =>
      _patch('/providers/me/notifications/$id', {});

  // ─── Helpers ─────────────────────────────────────────
  // FIX MEDIUM-T3: throw Exception (not String) so callers can catch typed errors
  Future<Map> _get(String path, [Map? params]) async {
    try {
      final res = await _dio.get(path,
          queryParameters: params?.cast<String, dynamic>());
      return res.data as Map;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message);
    }
  }

  Future<Map> _post(String path, Map data) async {
    try {
      final res = await _dio.post(path, data: data);
      return res.data as Map;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message);
    }
  }

  Future<Map> _patch(String path, Map data) async {
    try {
      final res = await _dio.patch(path, data: data);
      return res.data as Map;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message);
    }
  }

  Future<Map> _delete(String path) async {
    try {
      final res = await _dio.delete(path);
      return res.data as Map;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message);
    }
  }

  Future<Map> _postForm(String path, FormData data) async {
    try {
      final res = await _dio.post(path, data: data);
      return res.data as Map;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message);
    }
  }

  Future<Map> _patchForm(String path, FormData data) async {
    try {
      final res = await _dio.patch(path, data: data);
      return res.data as Map;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message);
    }
  }
}
