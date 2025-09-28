// lib/presentation/providers/app_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Theme Provider
final themeProvider = StateProvider<bool>((ref) => true);

// Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
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

  bool get isAuthenticated => token != null;
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      state = state.copyWith(
        isLoading: false,
        token: 'mock_jwt_token',
        user: {'name': 'Admin', 'email': email},
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Login failed: $e',
      );
    }
  }

  void logout() {
    state = const AuthState();
  }
}
