import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/shared/admin_layout.dart';
import '../../../data/models/libur.dart'; // Sesuaikan path
import '../provider/libur_provider.dart'; // Sesuaikan path
import '../../widgets/modal/modal-libur/libur_form_modal.dart'; // Sesuaikan path

class LiburScreen extends ConsumerStatefulWidget {
  const LiburScreen({super.key});

  @override
  ConsumerState<LiburScreen> createState() => _LiburScreenState();
}

class _LiburScreenState extends ConsumerState<LiburScreen> {
  @override
  void initState() {
    super.initState();
    // Load data saat screen pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(liburProvider.notifier).loadLibur();
    });
  }

  void _showLiburFormModal([Libur? libur]) {
    showDialog(
      context: context,
      builder: (context) => LiburFormModal(
        libur: libur,
        onSave: (newLibur) async {
          try {
            if (libur == null) {
              await ref.read(liburProvider.notifier).createLibur(newLibur);
            }

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Libur ${libur == null ? 'ditambahkan' : 'diupdate'} berhasil'),
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

  void _deleteLibur(Libur libur) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Libur'),
        content: Text(
          'Yakin ingin menghapus tanggal libur ${libur.tanggal.toIso8601String().split('T')[0]}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ref.read(liburProvider.notifier).deleteLibur(libur.id);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Libur berhasil dihapus'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final liburState = ref.watch(liburProvider);
    final liburNotifier = ref.read(liburProvider.notifier);

    return AdminLayout(
      title: 'Manage Libur',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Header dengan tombol tambah
            Row(
              children: [
                Text(
                  'Daftar Hari Libur',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const Spacer(),
                if (liburState.isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Libur'),
                    onPressed: () => _showLiburFormModal(),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Error Handling
            if (liburState.error != null)
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
                    Expanded(child: Text(liburState.error!)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => liburNotifier.clearError(),
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
                              flex: 3,
                              child: Text(
                                'Tanggal Libur',
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
                        child: liburState.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : liburState.liburList.isEmpty
                                ? const Center(
                                    child: Text('Tidak ada data libur'))
                                : ListView.builder(
                                    itemCount: liburState.liburList.length,
                                    itemBuilder: (context, index) {
                                      final libur = liburState.liburList[index];
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
                                              flex: 3,
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                      Icons.calendar_today,
                                                      size: 16,
                                                      color: Colors.grey),
                                                  const SizedBox(width: 8),
                                                  Text(libur.tanggal
                                                      .toIso8601String()
                                                      .split('T')[0]),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.delete,
                                                        size: 18,
                                                        color: Colors.red),
                                                    onPressed: () =>
                                                        _deleteLibur(libur),
                                                    tooltip: 'Hapus Libur',
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
