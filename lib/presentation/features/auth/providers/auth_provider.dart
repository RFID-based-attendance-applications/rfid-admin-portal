import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../core/services/api_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../providers/app_provider.dart'; // Import app_providers

// Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final sharedPreferences = ref.watch(sharedPreferencesProvider);

  return AuthNotifier(apiService, sharedPreferences);
});

class AuthState {
  final bool isLoading;
  final String? token;
  final Map<String, dynamic>? user;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.token,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    String? token,
    Map<String, dynamic>? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      token: token ?? this.token,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }

  bool get isAuthenticated => token != null && token!.isNotEmpty;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;
  final SharedPreferences _sharedPreferences;

  AuthNotifier(this._apiService, this._sharedPreferences)
      : super(const AuthState()) {
    _loadStoredAuth();
  }

  Future<void> _loadStoredAuth() async {
    try {
      final token = _sharedPreferences.getString(AppConstants.tokenKey);
      final userData = _sharedPreferences.getString(AppConstants.userDataKey);

      if (token != null && token.isNotEmpty && userData != null) {
        state = state.copyWith(
          token: token,
          user: json.decode(userData),
        );
      }
    } catch (e) {
      await _clearStoredAuth();
    }
  }

  Future<void> _clearStoredAuth() async {
    await _sharedPreferences.remove(AppConstants.tokenKey);
    await _sharedPreferences.remove(AppConstants.userDataKey);
  }

  Future<void> _saveAuthData(String token, Map<String, dynamic> user) async {
    await _sharedPreferences.setString(AppConstants.tokenKey, token);
    await _sharedPreferences.setString(
        AppConstants.userDataKey, json.encode(user));
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.login(username, password);

      await _saveAuthData(response['token'], response['user']);

      state = state.copyWith(
        isLoading: false,
        token: response['token'],
        user: response['user'],
        error: null,
      );
    } catch (e) {
      await _clearStoredAuth();
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        token: null,
        user: null,
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (e) {
      // Ignore logout errors
    } finally {
      await _clearStoredAuth();
      state = const AuthState();
    }
  }

  // Clear error manually
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }
}
