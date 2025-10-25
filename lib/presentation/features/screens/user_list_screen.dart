import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/shared/admin_layout.dart';
import '../../../data/models/user.dart';
import '../provider/user_provider.dart';
import '../../widgets/modal/modal-user/user_form_modal.dart';

class UserListScreen extends ConsumerStatefulWidget {
  const UserListScreen({super.key});

  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> {
  @override
  void initState() {
    super.initState();
    // Load data saat screen pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userProvider.notifier).loadUsers();
    });
  }

  void _showUserFormModal([User? user]) {
    showDialog(
      context: context,
      builder: (context) => UserFormModal(
        user: user,
        onSave: (newUser) async {
          try {
            if (user == null) {
              await ref.read(userProvider.notifier).createUser(newUser);
            } else {}

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'User ${user == null ? 'ditambahkan' : 'diupdate'} berhasil'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final userNotifier = ref.read(userProvider.notifier);

    return AdminLayout(
      title: 'Manage User',
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
                if (userState.isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah User'),
                    onPressed: () => _showUserFormModal(),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Error Handling
            if (userState.error != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(child: Text(userState.error!)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => userNotifier.clearError(),
                    ),
                  ],
                ),
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Table Body
                      Expanded(
                        child: userState.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : userState.users.isEmpty
                                ? const Center(
                                    child: Text('Tidak ada data user'))
                                : ListView.builder(
                                    itemCount: userState.users.length,
                                    itemBuilder: (context, index) {
                                      final user = userState.users[index];
                                      return Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 16),
                                        decoration: BoxDecoration(
                                          color: index.isEven
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .surface
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .surfaceVariant
                                                  .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.person,
                                                      size: 16,
                                                      color: Colors.grey),
                                                  const SizedBox(width: 8),
                                                  Text(user.username),
                                                ],
                                              ),
                                            ),
                                            const Expanded(
                                              flex: 2,
                                              child: Row(
                                                children: [
                                                  Icon(Icons.lock,
                                                      size: 16,
                                                      color: Colors.grey),
                                                  SizedBox(width: 8),
                                                  Text('****'),
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
