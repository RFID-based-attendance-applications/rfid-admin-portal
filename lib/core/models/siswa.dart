class Siswa {
  final int id;
  final String nis;
  final String name;
  final String kelas;
  final String image;
  final String phone;
  final String wali;
  final DateTime createdAt;
  final DateTime updatedAt;

  Siswa({
    required this.id,
    required this.nis,
    required this.name,
    required this.kelas,
    required this.image,
    required this.phone,
    required this.wali,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Siswa.fromJson(Map<String, dynamic> json) {
    return Siswa(
      id: json['id'],
      nis: json['nis'],
      name: json['name'],
      kelas: json['kelas'],
      image: json['image'],
      phone: json['phone'],
      wali: json['wali'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
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
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
