import 'dart:math';

class User {
  final int id;
  final String username;
  final String password;

  User({
    required this.id,
    required this.username,
    required this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final idValue = json['id'];
    final int id = idValue is int
        ? idValue
        : (idValue is String ? int.tryParse(idValue) : null) ?? 0;

    final username =
        json['username'] is String ? json['username'] as String : '';

    final password =
        json['password'] is String ? json['password'] as String : '';

    // Hanya log id dan username (jangan log password!)
    print('✅ Parsed user: id=$id, username="$username"');

    return User(
      id: id,
      username: username,
      password: password,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
    };
  }

  User copyWith({
    int? id,
    String? username,
    String? password,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }
}
