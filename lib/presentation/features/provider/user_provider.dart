import 'package:admin_absensi_hasbi/core/exceptions/api_exceptions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../../../data/models/user.dart';
import '../../providers/app_provider.dart';

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return UserNotifier(apiService);
});

class UserState {
  final bool isLoading;
  final List<User> users;
  final String? error;

  const UserState({
    this.isLoading = false,
    this.users = const [],
    this.error,
  });

  UserState copyWith({
    bool? isLoading,
    List<User>? users,
    String? error,
  }) {
    return UserState(
      isLoading: isLoading ?? this.isLoading,
      users: users ?? this.users,
      error: error ?? this.error,
    );
  }
}

class UserNotifier extends StateNotifier<UserState> {
  final ApiService _apiService;

  UserNotifier(this._apiService) : super(const UserState());

  Future<void> loadUsers() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _apiService.getUsers();

      if (response is List) {
        final List<User> users = [];
        for (final userData in response) {
          if (userData is Map<String, dynamic>) {
            try {
              final user = User.fromJson(userData);
              users.add(user);
            } catch (e) {
              print('Failed to parse user data: $userData | Error: $e');
              // Skip user yang tidak valid
            }
          } else {
            print(
                'Unexpected user data type: $userData (type: ${userData.runtimeType})');
          }
        }

        state = state.copyWith(users: users, isLoading: false);
      } else {
        throw ApiException(
          message: 'Invalid response format from server: expected List',
          statusCode: 0,
        );
      }
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message, isLoading: false);
    } catch (e) {
      state =
          state.copyWith(error: 'Failed to load users: $e', isLoading: false);
    }
  }

  Future<void> createUser(User user) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final userData = {
        'username': user.username,
        'password': user.password,
      };

      final response = await _apiService.createUser(userData);

      // Reload users setelah create berhasil
      await loadUsers();
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message, isLoading: false);
      rethrow;
    } catch (e) {
      state =
          state.copyWith(error: 'Failed to create user: $e', isLoading: false);
      rethrow;
    }
  }

  // Clear error
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }
}
