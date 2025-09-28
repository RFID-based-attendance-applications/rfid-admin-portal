import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/user.dart';

final userProvider = StateNotifierProvider<UserProvider, List<User>>((ref) {
  return UserProvider();
});

class UserProvider extends StateNotifier<List<User>> {
  UserProvider()
      : super([
          User(id: '1', username: 'admin', password: '12345'),
          User(id: '2', username: 'guru1', password: 'guru123'),
          User(id: '3', username: 'guru2', password: 'guru456'),
        ]);

  void addUser(User user) {
    state = [...state, user];
  }

  void updateUser(int index, User updatedUser) {
    state = [
      ...state.take(index),
      updatedUser,
      ...state.skip(index + 1),
    ];
  }

  void deleteUser(int index) {
    state = [...state..removeAt(index)];
  }
}
