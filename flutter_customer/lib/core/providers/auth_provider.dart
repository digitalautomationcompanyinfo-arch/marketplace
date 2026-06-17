import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/services/api_service.dart';

// ─── حالة المصادقة ────────────────────────────────────────
class AuthState {
  final bool isLoggedIn;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? user;
  final String? accessToken;

  const AuthState({
    this.isLoggedIn = false,
    this.isLoading = false,
    this.error,
    this.user,
    this.accessToken,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? user,
    String? accessToken,
  }) =>
      AuthState(
        isLoggedIn: isLoggedIn ?? this.isLoggedIn,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        user: user ?? this.user,
        accessToken: accessToken ?? this.accessToken,
      );
}

// ─── Auth Notifier ────────────────────────────────────────
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _loadFromStorage();
  }

  // FIX MEDIUM-F3: Validate JWT expiry before restoring session
  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      final payload = json.decode(
              utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))))
          as Map<String, dynamic>;
      final exp = payload['exp'] as int?;
      if (exp == null) return true;
      return DateTime.fromMillisecondsSinceEpoch(exp * 1000)
          .isBefore(DateTime.now());
    } catch (_) {
      return true;
    }
  }

  // تحميل التوكن المحفوظ عند فتح التطبيق
  Future<void> _loadFromStorage() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'access_token');
    final name = await storage.read(key: 'user_name');
    // FIX MEDIUM-F3: Only restore session if token is still valid (not expired)
    if (token != null && !_isTokenExpired(token)) {
      state = state.copyWith(
        isLoggedIn: true,
        accessToken: token,
        user: {'full_name': name ?? ''},
      );
    } else if (token != null) {
      // Token expired — clear storage to avoid confusion
      const s = FlutterSecureStorage();
      await s.delete(key: 'access_token');
      await s.delete(key: 'refresh_token');
    }
  }

  // تسجيل الدخول
  Future<void> login(String identifier, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await ApiService.instance.login({
        'identifier': identifier,
        'password': password,
      });

      if (res['success'] == true) {
        final data = res['data'] as Map;
        final token = data['accessToken'] as String;
        final user = Map<String, dynamic>.from(data['user'] as Map);

        const storage = FlutterSecureStorage();
        await storage.write(key: 'access_token', value: token);
        await storage.write(
            key: 'refresh_token', value: data['refreshToken'] as String);
        await storage.write(
            key: 'user_name', value: user['full_name'] as String? ?? '');

        state = state.copyWith(
            isLoggedIn: true, isLoading: false, accessToken: token, user: user);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // التسجيل
  Future<void> register(String fullName, String phone, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await ApiService.instance.register({
        'full_name': fullName,
        'phone': phone,
        'password': password,
        'method': 'whatsapp', // الافتراضي واتساب لسهولة الوصول في السودان
      });

      if (res['success'] == true) {
        final data = res['data'] as Map;
        final token = data['accessToken'] as String;

        const storage = FlutterSecureStorage();
        await storage.write(key: 'access_token', value: token);

        state = state.copyWith(
          isLoggedIn: true,
          isLoading: false,
          accessToken: token,
          user: Map<String, dynamic>.from(data['user'] as Map),
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // إعادة إرسال الرمز
  Future<bool> resendOtp(String identifier, String method) async {
    try {
      await ApiService.instance.resendOTP(identifier, method: method);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // تحديث بيانات الملف الشخصي (للحصول على الرصيد الجديد مثلاً)
  Future<void> refreshProfile() async {
    try {
      final res = await ApiService.instance.getMyProfile();
      if (res['success'] == true) {
        state =
            state.copyWith(user: Map<String, dynamic>.from(res['data'] as Map));
      }
    } catch (_) {}
  }

  // تسجيل الخروج
  Future<void> logout() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');
    await storage.delete(key: 'user_name');
    state = const AuthState();
  }

  void clearError() => state = state.copyWith(error: null);
}

// ─── Providers ────────────────────────────────────────────
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);

final authStateProvider = Provider<AuthState>((ref) => ref.watch(authProvider));
