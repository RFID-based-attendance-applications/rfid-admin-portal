// lib/presentation/features/siswa/screens/siswa_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../widgets/shared/admin_layout.dart';
import '../../../../data/models/siswa.dart';
import '../../../widgets/modal/modal-siswa/siswa_form_modal.dart';
import '../../../widgets/modal/modal-siswa/import_excel_modal.dart';
import '../../../widgets/modal/modal-siswa/rfid_modal.dart';

class SiswaListScreen extends ConsumerStatefulWidget {
  const SiswaListScreen({super.key});

  @override
  ConsumerState<SiswaListScreen> createState() => _SiswaListScreenState();
}

class _SiswaListScreenState extends ConsumerState<SiswaListScreen> {
  final List<Siswa> _siswaList = [
    Siswa(
      id: 1,
      nis: '2024001',
      name: 'Ahmad Rizki',
      kelas: 'X IPA 1',
      image: '',
      phone: '081234567890',
      wali: 'Budi Santoso - 081234567891',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Siswa(
      id: 2,
      nis: '2024002',
      name: 'Siti Nurhaliza',
      kelas: 'X IPA 1',
      image: '',
      phone: '081234567892',
      wali: 'Ahmad Yani - 081234567893',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    // Add more sample data...
  ];

  String _searchQuery = '';
  String _selectedClass = 'Semua Kelas';

  List<String> get _classes => [
        'Semua Kelas',
        'X IPA 1',
        'X IPA 2',
        'XI IPA 1',
        'XI IPA 2',
        'XII IPA 1',
        'XII IPA 2',
      ];

  List<Siswa> get _filteredSiswa {
    return _siswaList.where((siswa) {
      final matchesSearch =
          siswa.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              siswa.nis.contains(_searchQuery);
      final matchesClass =
          _selectedClass == 'Semua Kelas' || siswa.kelas == _selectedClass;
      return matchesSearch && matchesClass;
    }).toList();
  }

  void _showSiswaFormModal([Siswa? siswa]) {
    showDialog(
      context: context,
      builder: (context) => SiswaFormModal(
        siswa: siswa,
        onSave: (newSiswa) {
          if (siswa == null) {
            // Add new siswa
            setState(() {
              _siswaList.add(newSiswa);
            });
          } else {
            // Update existing siswa
            setState(() {
              final index = _siswaList.indexWhere((s) => s.id == siswa.id);
              if (index != -1) {
                _siswaList[index] = newSiswa;
              }
            });
          }
        },
      ),
    );
  }

  void _showImportExcelModal() {
    showDialog(
      context: context,
      builder: (context) => ImportExcelModal(
        onImport: (importedSiswaList) {
          setState(() {
            _siswaList.addAll(importedSiswaList);
          });
        },
      ),
    );
  }

  void _showRFIDModal(Siswa siswa) {
    showDialog(
      context: context,
      builder: (context) => RFIDModal(siswa: siswa),
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
            onPressed: () {
              setState(() {
                _siswaList.removeWhere((s) => s.id == siswa.id);
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
                // Import Excel Button
                OutlinedButton.icon(
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Import Excel'),
                  onPressed: _showImportExcelModal,
                ),
                const SizedBox(width: 16),
                // Add Siswa Button
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Siswa'),
                  onPressed: () => _showSiswaFormModal(),
                ),
              ],
            ),
            const SizedBox(height: 24),

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
            const Row(
              children: [
                Expanded(
                    child: _SiswaStatCard(
                        title: 'Total Siswa',
                        value: '250',
                        color: Colors.blue)),
                SizedBox(width: 16),
                Expanded(
                    child: _SiswaStatCard(
                        title: 'X IPA', value: '80', color: Colors.green)),
                SizedBox(width: 16),
                Expanded(
                    child: _SiswaStatCard(
                        title: 'XI IPA', value: '85', color: Colors.orange)),
                SizedBox(width: 16),
                Expanded(
                    child: _SiswaStatCard(
                        title: 'XII IPA', value: '85', color: Colors.purple)),
              ],
            ),
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
                        child: _filteredSiswa.isEmpty
                            ? const Center(child: Text('Tidak ada data siswa'))
                            : ListView.builder(
                                itemCount: _filteredSiswa.length,
                                itemBuilder: (context, index) {
                                  final siswa = _filteredSiswa[index];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
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
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                            flex: 1, child: Text(siswa.nis)),
                                        Expanded(
                                            flex: 2, child: Text(siswa.name)),
                                        Expanded(
                                            flex: 1, child: Text(siswa.kelas)),
                                        Expanded(
                                            flex: 2, child: Text(siswa.phone)),
                                        Expanded(
                                            flex: 2, child: Text(siswa.wali)),
                                        Expanded(
                                          flex: 1,
                                          child: IconButton(
                                            icon: const Icon(Icons.credit_card,
                                                size: 18),
                                            onPressed: () =>
                                                _showRFIDModal(siswa),
                                            tooltip: 'Daftar RFID',
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit,
                                                    size: 18),
                                                onPressed: () =>
                                                    _showSiswaFormModal(siswa),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete,
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
    return Card(
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
    );
  }
}
