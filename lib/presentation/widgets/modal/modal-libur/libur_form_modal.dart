import 'package:flutter/material.dart';
import '../../../../data/models/libur.dart';

class LiburFormModal extends StatefulWidget {
  final Libur? libur;
  final Function(Libur) onSave;

  const LiburFormModal({
    super.key,
    this.libur,
    required this.onSave,
  });

  @override
  State<LiburFormModal> createState() => _LiburFormModalState();
}

class _LiburFormModalState extends State<LiburFormModal> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.libur != null) {
      _selectedDate = widget.libur!.tanggal;
    }
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _save() {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      final libur = Libur(
        id: widget.libur?.id ?? DateTime.now().millisecondsSinceEpoch,
        tanggal: _selectedDate!,
      );
      widget.onSave(libur);
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
              Row(
                children: [
                  Icon(
                    widget.libur == null ? Icons.date_range : Icons.edit,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.libur == null ? 'Tambah Libur' : 'Edit Libur',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      readOnly:
                          true, // Hanya baca, karena akan diubah oleh date picker
                      decoration: InputDecoration(
                        labelText: 'Tanggal Libur *',
                        border: const OutlineInputBorder(),
                        hintText: 'Pilih tanggal',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: _selectDate,
                        ),
                      ),
                      controller: TextEditingController(
                          text: _selectedDate != null
                              ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
                              : ''),
                      validator: (value) {
                        if (_selectedDate == null) {
                          return 'Tanggal libur harus dipilih';
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
                        backgroundColor: Theme.of(context).colorScheme.primary,
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
    );
  }
}
