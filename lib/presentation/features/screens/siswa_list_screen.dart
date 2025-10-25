// lib/presentation/features/siswa/screens/siswa_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/shared/admin_layout.dart';
import '../../../data/models/siswa.dart';
import '../provider/siswa_provider.dart';
import '../../widgets/modal/modal-siswa/siswa_form_modal.dart';
import '../../widgets/modal/modal-siswa/import_excel_modal.dart';
import '../../widgets/modal/modal-siswa/rfid_modal.dart';

class SiswaListScreen extends ConsumerStatefulWidget {
  const SiswaListScreen({super.key});

  @override
  ConsumerState<SiswaListScreen> createState() => _SiswaListScreenState();
}

class _SiswaListScreenState extends ConsumerState<SiswaListScreen> {
  String _searchQuery = '';
  String _selectedClass = 'Semua Kelas';

  final List<String> _classes = [
    'Semua Kelas',
    'X IPA 1',
    'X IPA 2',
    'XI IPA 1',
    'XI IPA 2',
    'XII IPA 1',
    'XII IPA 2',
  ];

  @override
  void initState() {
    super.initState();
    // Load data saat screen pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(siswaProvider.notifier).loadSiswa();
    });
  }

  List<Siswa> get _filteredSiswa {
    final siswaState = ref.watch(siswaProvider);
    return siswaState.siswaList.where((siswa) {
      final matchesSearch =
          siswa.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              siswa.nis.contains(_searchQuery);
      final matchesClass =
          _selectedClass == 'Semua Kelas' || siswa.kelas == _selectedClass;
      return matchesSearch && matchesClass;
    }).toList();
  }

  Map<String, int> get _classStatistics {
    final siswaState = ref.watch(siswaProvider);
    final statistics = <String, int>{};

    for (final siswa in siswaState.siswaList) {
      statistics[siswa.kelas] = (statistics[siswa.kelas] ?? 0) + 1;
    }

    return statistics;
  }

  void _showSiswaFormModal([Siswa? siswa]) {
    showDialog(
      context: context,
      builder: (context) => SiswaFormModal(
        siswa: siswa,
        onSave: (newSiswa) async {
          try {
            if (siswa == null) {
              await ref.read(siswaProvider.notifier).createSiswa(newSiswa);
            } else {
              await ref.read(siswaProvider.notifier).updateSiswa(newSiswa);
            }

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Siswa ${siswa == null ? 'ditambahkan' : 'diupdate'} berhasil'),
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

  void _showImportExcelModal() {
    showDialog(
      context: context,
      builder: (context) => ImportExcelModal(
        onImport: (importedSiswaList) async {
          try {
            // Simulate import process
            for (final siswa in importedSiswaList) {
              await ref.read(siswaProvider.notifier).createSiswa(siswa);
            }

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data siswa berhasil diimport'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error import: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showRFIDModal(Siswa siswa) {
    showDialog(
      context: context,
      builder: (context) => RFIDModal(
        siswa: siswa,
        onSave: (rfidTag) async {
          try {
            await ref
                .read(siswaProvider.notifier)
                .registerRFID(siswa.id, rfidTag);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('RFID berhasil didaftarkan untuk ${siswa.name}'),
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

  void _deleteSiswa(Siswa siswa) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Siswa'),
        content:
            Text('Yakin ingin menghapus siswa ${siswa.name} (${siswa.nis})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ref.read(siswaProvider.notifier).deleteSiswa(siswa.id);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Siswa berhasil dihapus'),
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
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final siswaState = ref.watch(siswaProvider);
    final siswaNotifier = ref.read(siswaProvider.notifier);
    final filteredSiswa = _filteredSiswa;

    return AdminLayout(
      title: 'Manajemen Data Siswa',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Header dengan Actions
            Row(
              children: [
                Text(
                  'Data Siswa',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const Spacer(),
                if (siswaState.isImporting)
                  const CircularProgressIndicator()
                else
                  OutlinedButton.icon(
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Import Excel'),
                    onPressed: _showImportExcelModal,
                  ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Siswa'),
                  onPressed: () => _showSiswaFormModal(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Error Handling
            if (siswaState.error != null)
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
                    Expanded(child: Text(siswaState.error!)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => siswaNotifier.clearError(),
                    ),
                  ],
                ),
              ),

            // Filter Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Search
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Cari NIS atau Nama',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Class Filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedClass,
                        items: _classes.map((classItem) {
                          return DropdownMenuItem(
                            value: classItem,
                            child: Text(classItem),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedClass = value!;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Filter Kelas',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Statistics
            _buildStatistics(),

            const SizedBox(height: 24),

            // Siswa List
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                flex: 1,
                                child: Text('NIS',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            Expanded(
                                flex: 2,
                                child: Text('Nama',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            Expanded(
                                flex: 1,
                                child: Text('Kelas',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            Expanded(
                                flex: 2,
                                child: Text('No. HP',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            Expanded(
                                flex: 2,
                                child: Text('Wali',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            Expanded(
                                flex: 1,
                                child: Text('RFID',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            Expanded(
                                flex: 1,
                                child: Text('Aksi',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Table Body
                      Expanded(
                        child: siswaState.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : filteredSiswa.isEmpty
                                ? const Center(
                                    child: Text('Tidak ada data siswa'))
                                : ListView.builder(
                                    itemCount: filteredSiswa.length,
                                    itemBuilder: (context, index) {
                                      final siswa = filteredSiswa[index];
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
                                                flex: 1,
                                                child: Text(siswa.nis)),
                                            Expanded(
                                                flex: 2,
                                                child: Text(siswa.name)),
                                            Expanded(
                                                flex: 1,
                                                child: Text(siswa.kelas)),
                                            Expanded(
                                                flex: 2,
                                                child: Text(siswa.phone)),
                                            Expanded(
                                                flex: 2,
                                                child: Text(siswa.wali)),
                                            Expanded(
                                              flex: 1,
                                              child: Text(siswa.rfidTag ?? '-'),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Row(
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.credit_card,
                                                        size: 18),
                                                    onPressed: () =>
                                                        _showRFIDModal(siswa),
                                                    tooltip: 'Daftar RFID',
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.edit,
                                                        size: 18),
                                                    onPressed: () =>
                                                        _showSiswaFormModal(
                                                            siswa),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.delete,
                                                        size: 18,
                                                        color: Colors.red),
                                                    onPressed: () =>
                                                        _deleteSiswa(siswa),
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

  Widget _buildStatistics() {
    final statistics = _classStatistics;
    final totalSiswa = ref.watch(siswaProvider).siswaList.length;

    // Menghitung jumlah siswa per tingkat kelas
    int jumlahXIpa = 0;
    int jumlahXIpa1 = statistics['X IPA 1'] ?? 0;
    int jumlahXIpa2 = statistics['X IPA 2'] ?? 0;
    jumlahXIpa = jumlahXIpa1 + jumlahXIpa2;

    int jumlahXIIpa = 0;
    int jumlahXIIpa1 = statistics['XI IPA 1'] ?? 0;
    int jumlahXIIpa2 = statistics['XI IPA 2'] ?? 0;
    jumlahXIIpa = jumlahXIIpa1 + jumlahXIIpa2;

    int jumlahXIIIpa = 0;
    int jumlahXIIIpa1 = statistics['XII IPA 1'] ?? 0;
    int jumlahXIIIpa2 = statistics['XII IPA 2'] ?? 0;
    jumlahXIIIpa = jumlahXIIIpa1 + jumlahXIIIpa2;

    return Row(
      children: [
        _SiswaStatCard(
          title: 'Total Siswa',
          value: totalSiswa.toString(),
          color: Colors.blue,
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}

class _SiswaStatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _SiswaStatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
