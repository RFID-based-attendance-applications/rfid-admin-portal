// Di lib/presentation/widgets/modal/modal-siswa/siswa_form_modal.dart

import 'dart:convert'; // Tambahkan ini jika belum
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // Pastikan ini digunakan
import 'package:admin_absensi_hasbi/data/models/siswa.dart'; // Pastikan path benar

class SiswaFormModal extends StatefulWidget {
  final Siswa? siswa;
  final Function(Siswa) onSave;

  const SiswaFormModal({
    super.key,
    this.siswa,
    required this.onSave,
  });

  @override
  State<SiswaFormModal> createState() => _SiswaFormModalState();
}

class _SiswaFormModalState extends State<SiswaFormModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nisController;
  late final TextEditingController _nameController;
  late final TextEditingController _kelasController;
  late final TextEditingController _phoneController;
  late final TextEditingController _waliController;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _nisController = TextEditingController(text: widget.siswa?.nis ?? '');
    _nameController = TextEditingController(text: widget.siswa?.name ?? '');
    _kelasController = TextEditingController(text: widget.siswa?.kelas ?? '');
    _phoneController = TextEditingController(text: widget.siswa?.phone ?? '');
    _waliController = TextEditingController(text: widget.siswa?.wali ?? '');
    _selectedImage = widget.siswa
        ?.imageFile; // Jika sedang edit, mungkin ingin set image sebelumnya? Tapi karena File, mungkin tidak praktis. Biarkan kosong dulu.
  }

  @override
  void dispose() {
    _nisController.dispose();
    _nameController.dispose();
    _kelasController.dispose();
    _phoneController.dispose();
    _waliController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedImage = File(result.files.single.path!);
      });
    }
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Buat objek Siswa tanpa mengisi image dengan base64, karena nanti dikirim via multipart
        // Ambil image dari data lama jika sedang edit, atau kosongkan jika tambah baru
        final siswa = Siswa(
          id: widget.siswa?.id ?? DateTime.now().millisecondsSinceEpoch,
          nis: _nisController.text.trim(),
          name: _nameController.text.trim(),
          kelas: _kelasController.text.trim(),
          image:
              widget.siswa?.image ?? '', // Ambil dari data lama atau kosongkan
          phone: _phoneController.text.trim(),
          wali: _waliController.text.trim(),
          createdAt: widget.siswa?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
          imageFile:
              _selectedImage, // File untuk dikirim ke server via multipart
        );

        // ✅ Tambahkan print untuk melihat objek Siswa sebelum dikirim (opsional, untuk debug)
        print('📌 Siswa object being saved (for multipart):');
        print({
          'id': siswa.id,
          'nis': siswa.nis,
          'name': siswa.name,
          'kelas': siswa.kelas,
          'image': siswa.image, // Harusnya kosong atau dari data lama
          'phone': siswa.phone,
          'wali': siswa.wali,
          'imageFile': siswa.imageFile != null
              ? 'File selected'
              : 'No file', // Tidak bisa print object File
        });

        // Kirim ke onSave (yang akan memanggil notifier untuk multipart)
        widget.onSave(siswa);
        Navigator.of(context).pop();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Siswa ${widget.siswa == null ? 'ditambahkan' : 'diupdate'} berhasil'),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      widget.siswa == null ? Icons.person_add : Icons.edit,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.siswa == null ? 'Tambah Siswa' : 'Edit Siswa',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // ... (TextFormField NIS, Name, Kelas, Phone, Wali)
                      TextFormField(
                        controller: _nisController,
                        decoration: const InputDecoration(
                          labelText: 'NIS *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.numbers),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'NIS harus diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Lengkap *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama harus diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _kelasController,
                        decoration: const InputDecoration(
                          labelText: 'Kelas *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.school),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Kelas harus diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'No. HP *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'No. HP harus diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _waliController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Wali & No. HP Wali *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.family_restroom),
                          hintText: 'Contoh: Budi Santoso - 081234567890',
                        ),
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Data wali harus diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Upload Gambar
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Foto Siswa',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (_selectedImage != null)
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: FileImage(_selectedImage!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              else if (widget.siswa != null &&
                                  widget.siswa!.image.isNotEmpty)
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(widget.siswa!.image),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.image,
                                      color: Colors.grey),
                                ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextButton.icon(
                                    onPressed: _pickImage,
                                    icon: const Icon(Icons.photo_library),
                                    label: const Text('Pilih dari File'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
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
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey,
                          side: const BorderSide(color: Colors.grey),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Simpan'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
