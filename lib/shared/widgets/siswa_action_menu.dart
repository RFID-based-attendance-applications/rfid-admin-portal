import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/siswa.dart';
import '../../features/siswa/providers/siswa_provider.dart';

class SiswaActionMenu extends ConsumerWidget {
  final Siswa siswa;
  final int index;

  const SiswaActionMenu({super.key, required this.siswa, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'update') {
          _showUpdateDialog(context, ref, siswa, index);
        } else if (value == 'delete') {
          _confirmDelete(context, ref, index);
        }
      },
      icon: const Icon(Icons.more_vert, color: Colors.grey),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'update',
          child: Row(
            children: [
              const Icon(Icons.edit, color: Colors.blue),
              const SizedBox(width: 10),
              Text('Ubah', style: TextStyle(color: Colors.blue)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              const Icon(Icons.delete, color: Colors.red),
              const SizedBox(width: 10),
              Text('Hapus', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  void _showUpdateDialog(
      BuildContext context, WidgetRef ref, Siswa siswa, int index) {
    final nisController = TextEditingController(text: siswa.nis);
    final nameController = TextEditingController(text: siswa.name);
    final kelasController = TextEditingController(text: siswa.kelas);
    final phoneController = TextEditingController(text: siswa.phone);
    final waliController = TextEditingController(text: siswa.wali);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Siswa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nisController,
              decoration: const InputDecoration(labelText: 'NIS'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nama Lengkap'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: kelasController,
              decoration: const InputDecoration(labelText: 'Kelas'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Nomor Telepon'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: waliController,
              decoration: const InputDecoration(labelText: 'Nama Wali'),
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
              if (nisController.text.isNotEmpty &&
                  nameController.text.isNotEmpty &&
                  kelasController.text.isNotEmpty &&
                  phoneController.text.isNotEmpty &&
                  waliController.text.isNotEmpty) {
                ref.read(siswaProvider.notifier).updateSiswa(
                      index,
                      Siswa(
                        id: siswa.id,
                        nis: nisController.text,
                        name: nameController.text,
                        kelas: kelasController.text,
                        image: siswa.image,
                        phone: phoneController.text,
                        wali: waliController.text,
                        createdAt: siswa.createdAt,
                        updatedAt: DateTime.now(),
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
        title: const Text('Hapus Siswa?'),
        content: const Text('Apakah Anda yakin ingin menghapus siswa ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              ref.read(siswaProvider.notifier).deleteSiswa(index);
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
