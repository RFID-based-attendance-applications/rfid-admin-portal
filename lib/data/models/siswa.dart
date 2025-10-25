// lib/data/models/siswa.dart

import 'dart:io';

class Siswa {
  final int id;
  final String nis;
  final String name;
  final String kelas;
  final String image; // URL atau path string dari server
  final String phone;
  final String wali;
  final String? rfidTag; // Tambahkan field ini, opsional karena bisa null
  final DateTime createdAt;
  final DateTime updatedAt;

  // Untuk keperluan form (hanya saat create/edit)
  final File? imageFile;

  Siswa({
    required this.id,
    required this.nis,
    required this.name,
    required this.kelas,
    required this.image,
    required this.phone,
    required this.wali,
    this.rfidTag, // Tambahkan ini
    required this.createdAt,
    required this.updatedAt,
    this.imageFile, // opsional, hanya untuk form
  });

  factory Siswa.fromJson(Map<String, dynamic> json) {
    return Siswa(
      id: json['id'] ?? 0,
      nis: json['nis'] ?? '',
      name: json['name'] ?? '',
      kelas: json['kelas'] ?? '',
      image: json['image'] ?? '',
      phone: json['phone'] ?? '',
      wali: json['wali'] ?? '',
      rfidTag: json['rfidTag'] as String?, // Ambil dari JSON
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nis': nis,
      'name': name,
      'kelas': kelas,
      'image': image,
      'phone': phone,
      'wali': wali,
      'rfidTag': rfidTag, // Sertakan dalam JSON
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Siswa copyWith({
    int? id,
    String? nis,
    String? name,
    String? kelas,
    String? image,
    String? phone,
    String? wali,
    String? rfidTag,
    DateTime? createdAt,
    DateTime? updatedAt,
    File? imageFile,
  }) {
    return Siswa(
      id: id ?? this.id,
      nis: nis ?? this.nis,
      name: name ?? this.name,
      kelas: kelas ?? this.kelas,
      image: image ?? this.image,
      phone: phone ?? this.phone,
      wali: wali ?? this.wali,
      rfidTag: rfidTag ?? this.rfidTag, // Gunakan nilai baru jika disediakan
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageFile: imageFile ?? this.imageFile,
    );
  }
}
