// lib/presentation/features/siswa/widgets/rfid_modal.dart
import 'package:flutter/material.dart';
import '../../../../data/models/siswa.dart';

class RFIDModal extends StatefulWidget {
  final Siswa siswa;

  const RFIDModal({super.key, required this.siswa});

  @override
  State<RFIDModal> createState() => _RFIDModalState();
}

class _RFIDModalState extends State<RFIDModal> {
  String _rfidStatus = 'Menunggu scan RFID...';
  bool _isScanning = false;
  String? _scannedRFID;

  void _startRFIDScan() {
    setState(() {
      _isScanning = true;
      _rfidStatus = 'Silakan tempelkan kartu RFID ke reader...';
    });

    // Simulate RFID scanning process
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isScanning = false;
        _scannedRFID =
            'RFID_${widget.siswa.nis}_${DateTime.now().millisecondsSinceEpoch}';
        _rfidStatus = 'RFID berhasil didaftarkan!';
      });
    });
  }

  void _saveRFID() {
    // In real app, save RFID to database
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('RFID berhasil didaftarkan untuk ${widget.siswa.name}'),
        backgroundColor: Colors.green,
      ),
    );
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
                'Daftar RFID untuk ${widget.siswa.name}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text('NIS: ${widget.siswa.nis}'),
              Text('Kelas: ${widget.siswa.kelas}'),
              const SizedBox(height: 24),

              // RFID Status
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isScanning
                      ? Colors.blue.withOpacity(0.1)
                      : _scannedRFID != null
                          ? Colors.green.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isScanning
                        ? Colors.blue
                        : _scannedRFID != null
                            ? Colors.green
                            : Colors.grey,
                  ),
                ),
                child: Column(
                  children: [
                    if (_isScanning) ...[
                      const Icon(Icons.bluetooth_searching,
                          size: 48, color: Colors.blue),
                      const SizedBox(height: 16),
                    ] else if (_scannedRFID != null) ...[
                      const Icon(Icons.check_circle,
                          size: 48, color: Colors.green),
                      const SizedBox(height: 16),
                    ] else ...[
                      const Icon(Icons.credit_card,
                          size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                    ],
                    Text(
                      _rfidStatus,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _isScanning
                            ? Colors.blue
                            : _scannedRFID != null
                                ? Colors.green
                                : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_scannedRFID != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'ID: $_scannedRFID',
                        style: const TextStyle(fontFamily: 'Monospace'),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (_scannedRFID == null) ...[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isScanning ? null : _startRFIDScan,
                        child: _isScanning
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Scan RFID'),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveRFID,
                        child: const Text('Simpan RFID'),
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
