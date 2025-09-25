import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/user/providers/user_provider.dart';
import '../../core/models/user.dart';

class UserActionMenu extends ConsumerWidget {
  final User user;
  final int index;

  const UserActionMenu({super.key, required this.user, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'update') {
          _showUpdateDialog(context, ref, user, index);
        } else if (value == 'delete') {
          _confirmDelete(context, ref, index);
        }
      },
      icon: const Icon(Icons.more_vert, color: Colors.grey),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'update',
          child: Row(
            children: [
              Icon(Icons.edit, color: Colors.blue),
              SizedBox(width: 10),
              Text('Ubah', style: TextStyle(color: Colors.blue)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 10),
              Text('Hapus', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  void _showUpdateDialog(
      BuildContext context, WidgetRef ref, User user, int index) {
    final usernameController = TextEditingController(text: user.username);
    final passwordController = TextEditingController(text: user.password);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              if (usernameController.text.isNotEmpty &&
                  passwordController.text.isNotEmpty) {
                ref.read(userProvider.notifier).updateUser(
                      index,
                      User(
                        id: user.id,
                        username: usernameController.text,
                        password: passwordController.text,
                      ),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus User?'),
        content: const Text('Apakah Anda yakin ingin menghapus user ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              ref.read(userProvider.notifier).deleteUser(index);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
