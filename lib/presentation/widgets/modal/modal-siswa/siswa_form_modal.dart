// lib/presentation/features/siswa/widgets/siswa_form_modal.dart
import 'package:flutter/material.dart';
import '../../../../data/models/siswa.dart';

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
  final _nisController = TextEditingController();
  final _nameController = TextEditingController();
  final _kelasController = TextEditingController();
  final _phoneController = TextEditingController();
  final _waliController = TextEditingController();

  final List<String> _availableClasses = [
    'X IPA 1',
    'X IPA 2',
    'XI IPA 1',
    'XI IPA 2',
    'XII IPA 1',
    'XII IPA 2'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.siswa != null) {
      _nisController.text = widget.siswa!.nis;
      _nameController.text = widget.siswa!.name;
      _kelasController.text = widget.siswa!.kelas;
      _phoneController.text = widget.siswa!.phone;
      _waliController.text = widget.siswa!.wali;
    }
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

  void _save() {
    if (_formKey.currentState!.validate()) {
      final siswa = Siswa(
        id: widget.siswa?.id ?? DateTime.now().millisecondsSinceEpoch,
        nis: _nisController.text,
        name: _nameController.text,
        kelas: _kelasController.text,
        image: widget.siswa?.image ?? '',
        phone: _phoneController.text,
        wali: _waliController.text,
        createdAt: widget.siswa?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      widget.onSave(siswa);
      Navigator.of(context).pop();
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.siswa == null ? 'Tambah Siswa' : 'Edit Siswa',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _nisController,
                            decoration: const InputDecoration(
                              labelText: 'NIS',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'NIS harus diisi';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Nama Lengkap',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nama harus diisi';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _kelasController.text.isEmpty
                                ? null
                                : _kelasController.text,
                            items: _availableClasses.map((kelas) {
                              return DropdownMenuItem(
                                value: kelas,
                                child: Text(kelas),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _kelasController.text = value!;
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'Kelas',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Kelas harus dipilih';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              labelText: 'No. HP',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'No. HP harus diisi';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _waliController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Wali & No. HP Wali',
                        border: OutlineInputBorder(),
                        hintText: 'Contoh: Budi Santoso - 081234567890',
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Data wali harus diisi';
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
