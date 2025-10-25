import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk RawKeyboardListener
import '../../../../data/models/siswa.dart';

class RFIDModal extends StatefulWidget {
  final Siswa siswa;
  final Function(String) onSave;

  const RFIDModal({
    super.key,
    required this.siswa,
    required this.onSave,
  });

  @override
  State<RFIDModal> createState() => _RFIDModalState();
}

class _RFIDModalState extends State<RFIDModal> {
  String _rfidStatus = 'Menunggu scan RFID...';
  bool _isScanning = false;
  String? _scannedRFID;
  String _currentInput = ''; // Menyimpan input sementara
  Timer?
      _inputTimer; // Timer untuk reset input jika tidak ada input baru dalam waktu tertentu

  @override
  void initState() {
    super.initState();
    // Fokus ke dialog agar bisa terima keystroke
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  Future<void> _startRFIDScan() async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      _rfidStatus = 'Siapkan kartu RFID...';
      _currentInput = '';
      _scannedRFID = null;
    });

    // Reset timer jika ada
    _inputTimer?.cancel();

    // Mulai listen keystroke
    RawKeyboard.instance.addListener(_handleKeyEvent);

    setState(() {
      _rfidStatus = 'Tunggu scan kartu...';
    });
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (!_isScanning) return;

    // Hanya tangkap karakter ASCII (digit)
    if (event is RawKeyDownEvent) {
      final logicalKey = event.logicalKey;
      final physicalKey = event.physicalKey;

      // Cek apakah key adalah angka (0-9)
      if (logicalKey == LogicalKeyboardKey.digit0 ||
          logicalKey == LogicalKeyboardKey.digit1 ||
          logicalKey == LogicalKeyboardKey.digit2 ||
          logicalKey == LogicalKeyboardKey.digit3 ||
          logicalKey == LogicalKeyboardKey.digit4 ||
          logicalKey == LogicalKeyboardKey.digit5 ||
          logicalKey == LogicalKeyboardKey.digit6 ||
          logicalKey == LogicalKeyboardKey.digit7 ||
          logicalKey == LogicalKeyboardKey.digit8 ||
          logicalKey == LogicalKeyboardKey.digit9) {
        final digit = logicalKey.keyLabel;
        _currentInput += digit;

        print('💡 Input: $_currentInput');

        // Jika sudah 10 digit, proses
        if (_currentInput.length == 10) {
          if (RegExp(r'^\d{10}$').hasMatch(_currentInput)) {
            setState(() {
              _scannedRFID = _currentInput;
              _rfidStatus = 'Kartu RFID terdeteksi!';
              _isScanning = false;
            });

            // Hentikan listener
            RawKeyboard.instance.removeListener(_handleKeyEvent);

            // Reset input
            _currentInput = '';

            // Jangan lupa stop timer jika ada
            _inputTimer?.cancel();
          }
        } else if (_currentInput.length > 10) {
          // Jika lebih dari 10, reset
          _currentInput = '';
        }

        // Set timer untuk reset input jika tidak ada input baru dalam 1 detik
        _inputTimer?.cancel();
        _inputTimer = Timer(const Duration(seconds: 1), () {
          if (_isScanning &&
              _currentInput.isNotEmpty &&
              _currentInput.length < 10) {
            setState(() {
              _rfidStatus = 'Data tidak lengkap. Scan ulang.';
              _currentInput = '';
            });
          }
        });
      } else if (logicalKey == LogicalKeyboardKey.enter ||
          logicalKey == LogicalKeyboardKey.tab ||
          logicalKey == LogicalKeyboardKey.space) {
        // Jika user tekan Enter/Tab/Space, reset input
        _currentInput = '';
      }
    }
  }

  void _stopListening() {
    RawKeyboard.instance.removeListener(_handleKeyEvent);
    _inputTimer?.cancel();
  }

  @override
  void dispose() {
    _stopListening();
    super.dispose();
  }

  void _saveRFID() {
    if (_scannedRFID != null) {
      widget.onSave(_scannedRFID!);
      Navigator.of(context).pop();
    }
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isScanning) ...[
                      Icon(Icons.bluetooth_searching,
                          size: 48, color: Colors.blue),
                      const SizedBox(height: 16),
                    ] else if (_scannedRFID != null) ...[
                      Icon(Icons.check_circle, size: 48, color: Colors.green),
                      const SizedBox(height: 16),
                    ] else ...[
                      Icon(Icons.credit_card, size: 48, color: Colors.grey),
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
                      onPressed: () {
                        _stopListening();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (_scannedRFID == null) ...[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isScanning ? null : _startRFIDScan,
                        child: _isScanning
                            ? SizedBox(
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
