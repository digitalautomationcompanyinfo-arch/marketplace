import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../network/api_service.dart';

class AuthState {
  final bool isLoggedIn;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? provider;

  const AuthState({
    this.isLoggedIn = false,
    this.isLoading = false,
    this.error,
    this.provider,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? provider,
  }) =>
      AuthState(
        isLoggedIn: isLoggedIn ?? this.isLoggedIn,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        provider: provider ?? this.provider,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'access_token');
    if (token != null) {
      state = state.copyWith(isLoggedIn: true);
    }
  }

  Future<void> login(String phone, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await ApiService.instance.login({
        'identifier': phone,
        'password': password,
      });

      if (res['success'] == true) {
        final data = res['data'] as Map;
        final token = data['accessToken'] as String;

        const storage = FlutterSecureStorage();
        await storage.write(key: 'access_token', value: token);

        state = state.copyWith(
            isLoggedIn: true,
            isLoading: false,
            provider: Map<String, dynamic>.from(data['user']));
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'access_token');
    state = const AuthState();
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());
