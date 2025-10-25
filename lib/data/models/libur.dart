class Libur {
  final int id;
  final DateTime tanggal;

  Libur({
    required this.id,
    required this.tanggal,
  });

  factory Libur.fromJson(Map<String, dynamic> json) {
    final idValue = json['id'];
    final int id = idValue is int
        ? idValue
        : (idValue is String ? int.tryParse(idValue) : null) ?? 0;

    DateTime parsedTanggal = DateTime.now();

    final tanggalValue = json['tanggal'];

    if (tanggalValue is String) {
      try {
        parsedTanggal = DateTime.parse(tanggalValue);
      } catch (e) {
        print('Failed to parse tanggal string: $tanggalValue, error: $e');
      }
    } else if (tanggalValue is Map<String, dynamic>) {
      // Handle { "date": "YYYY-MM-DD" } or { "$date": "ISO_STRING" }
      final dateStr =
          tanggalValue['date'] as String? ?? tanggalValue['\$date'] as String?;
      if (dateStr != null) {
        try {
          parsedTanggal = DateTime.parse(dateStr);
        } catch (e) {
          print('Failed to parse date from map: $dateStr, error: $e');
        }
      }
    } else if (tanggalValue == null) {
      // Jika null, gunakan today
      parsedTanggal = DateTime.now();
    } else {
      // Jika tipe lain, log dan gunakan default
      print(
          'Unknown tanggal type: ${tanggalValue.runtimeType} -> $tanggalValue');
      parsedTanggal = DateTime.now();
    }

    return Libur(
      id: id,
      tanggal: parsedTanggal,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tanggal': tanggal, // Format ISO: YYYY-MM-DDTHH:MM:SS.mmmZ
    };
  }

  Libur copyWith({
    int? id,
    DateTime? tanggal,
  }) {
    return Libur(
      id: id ?? this.id,
      tanggal: tanggal ?? this.tanggal,
    );
  }
}
