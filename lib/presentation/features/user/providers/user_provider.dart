import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart';
import '../../../../data/models/user.dart';
import '../../../providers/app_provider.dart';

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
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.getUsers();
      final users =
          (response as List).map((data) => User.fromJson(data)).toList();

      state = state.copyWith(
        isLoading: false,
        users: users,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> createUser(User user) async {
    try {
      await _apiService.createUser(user.toJson());
      await loadUsers();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> updateUser(User user) async {
    try {
      await _apiService.updateUser(user.id, user.toJson());
      await loadUsers();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _apiService.deleteUser(id);
      await loadUsers();
    } catch (e) {
      state = state.copyWith(error: e.toString());
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
