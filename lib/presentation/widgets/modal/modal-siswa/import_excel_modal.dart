import 'package:flutter/material.dart';
import '../../../../data/models/siswa.dart';

class ImportExcelModal extends StatefulWidget {
  final Function(List<Siswa>) onImport;

  const ImportExcelModal({super.key, required this.onImport});

  @override
  State<ImportExcelModal> createState() => _ImportExcelModalState();
}

class _ImportExcelModalState extends State<ImportExcelModal> {
  List<Siswa> _importedSiswa = [];
  bool _isLoading = false;

  void _simulateExcelImport() {
    setState(() {
      _isLoading = true;
    });

    // Simulate file processing
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _importedSiswa = [
          Siswa(
            id: 1001,
            nis: '2024101',
            name: 'John Doe',
            kelas: 'X IPA 1',
            image: '',
            phone: '081234567801',
            wali: 'Michael Doe - 081234567802',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Siswa(
            id: 1002,
            nis: '2024102',
            name: 'Jane Smith',
            kelas: 'X IPA 1',
            image: '',
            phone: '081234567803',
            wali: 'Robert Smith - 081234567804',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Siswa(
            id: 1003,
            nis: '2024103',
            name: 'Bob Johnson',
            kelas: 'X IPA 2',
            image: '',
            phone: '081234567805',
            wali: 'Alice Johnson - 081234567806',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        _isLoading = false;
      });
    });
  }

  void _importData() {
    widget.onImport(_importedSiswa);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Import Data dari Excel',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                'Upload file Excel dengan format: NIS, Nama, Kelas, No. HP, Wali',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              if (_isLoading) ...[
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Memproses file Excel...'),
                    ],
                  ),
                ),
              ] else if (_importedSiswa.isEmpty) ...[
                // Upload Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.grey, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.cloud_upload,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Drag & drop file Excel di sini',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'atau',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Pilih File Excel'),
                        onPressed: _simulateExcelImport,
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Preview Section
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Preview Data (${_importedSiswa.length} siswa)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _importedSiswa.length,
                          itemBuilder: (context, index) {
                            final siswa = _importedSiswa[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  child: Text(
                                    (index + 1).toString(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(siswa.name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('NIS: ${siswa.nis}'),
                                    Text('Kelas: ${siswa.kelas}'),
                                    Text('HP: ${siswa.phone}'),
                                  ],
                                ),
                                trailing: Text(siswa.wali.split(' - ').first),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Batal'),
                    ),
                  ),
                  if (_importedSiswa.isNotEmpty) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _importData,
                        child: const Text('Import Data'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
