import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_services.dart';
import '../models/user.dart';
import '../constants/app_constants.dart';

final authServiceProvider = Provider<ApiService>((ref) => ApiService());

final authProvider = StateNotifierProvider<AuthStateNotifier, User?>((ref) {
  return AuthStateNotifier(ref.read(authServiceProvider));
});

class AuthStateNotifier extends StateNotifier<User?> {
  // final ApiService _apiService;

  // AuthStateNotifier(this._apiService) : super(null);

  // Future<void> login(String username, String password) async {
  //   try {
  //     final response =
  //         await _apiService.post(AppConstants.loginEndpoint, body: {
  //       'username': username,
  //       'password': password,
  //     });

  //     final userData = response['data'];
  //     final user = User.fromJson(userData);
  //     state = user;

  //     // Simpan token ke local storage (opsional, bisa pakai shared_preferences)
  //     // Untuk demo, kita asumsikan token otomatis disimpan di backend via cookie
  //   } catch (e) {
  //     throw e;
  //   }

  //sementara
  final ApiService _apiService;

  AuthStateNotifier(this._apiService) : super(null);

  Future<void> login(String username, String password) async {
    state = User(
      id: '1',
      username: 'admin',
      password: 'pass',
      // Bisa diisi URL gambar nanti
    );
  }

  void logout() {
    state = null;
  }
}
