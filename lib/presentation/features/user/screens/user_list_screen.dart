// lib/presentation/features/user/screens/user_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../widgets/shared/admin_layout.dart';
import '../../../../data/models/user.dart';

class UserListScreen extends ConsumerStatefulWidget {
  const UserListScreen({super.key});

  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> {
  final List<User> _users = [
    User(id: '1', username: 'admin', password: 'password'),
    User(id: '2', username: 'operator', password: 'operator123'),
  ];

  void _showUserFormModal([User? user]) {
    showDialog(
      context: context,
      builder: (context) => UserFormModal(
        user: user,
        onSave: (newUser) {
          if (user == null) {
            // Add new user
            setState(() {
              _users.add(newUser);
            });
          } else {
            // Update existing user
            setState(() {
              final index = _users.indexWhere((u) => u.id == user.id);
              if (index != -1) {
                _users[index] = newUser;
              }
            });
          }
        },
      ),
    );
  }

  void _deleteUser(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus User'),
        content: Text('Yakin ingin menghapus user ${user.username}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _users.removeWhere((u) => u.id == user.id);
              });
              Navigator.of(context).pop();
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Manajemen User Admin',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Header dengan tombol tambah
            Row(
              children: [
                Text(
                  'Daftar User Admin',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const Spacer(),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah User'),
                  onPressed: () => _showUserFormModal(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Table
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Table Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceVariant
                              .withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Username',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Password',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                'Aksi',
                                style: TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Table Body
                      Expanded(
                        child: ListView.builder(
                          itemCount: _users.length,
                          itemBuilder: (context, index) {
                            final user = _users[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: index.isEven
                                    ? Theme.of(context).colorScheme.surface
                                    : Theme.of(context)
                                        .colorScheme
                                        .surfaceVariant
                                        .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(user.username),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text('*' * user.password.length),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          icon:
                                              const Icon(Icons.edit, size: 18),
                                          onPressed: () =>
                                              _showUserFormModal(user),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              size: 18, color: Colors.red),
                                          onPressed: () => _deleteUser(user),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserFormModal extends StatefulWidget {
  final User? user;
  final Function(User) onSave;

  const UserFormModal({
    super.key,
    this.user,
    required this.onSave,
  });

  @override
  State<UserFormModal> createState() => _UserFormModalState();
}

class _UserFormModalState extends State<UserFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _usernameController.text = widget.user!.username;
      _passwordController.text = widget.user!.password;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final user = User(
        id: widget.user?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        username: _usernameController.text,
        password: _passwordController.text,
      );
      widget.onSave(user);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.user == null ? 'Tambah User' : 'Edit User',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Username harus diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password harus diisi';
                        }
                        if (value.length < 6) {
                          return 'Password minimal 6 karakter';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      child: const Text('Simpan'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
