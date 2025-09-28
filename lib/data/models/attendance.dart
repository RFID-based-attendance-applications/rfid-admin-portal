// lib/data/models/attendance.dart
class Attendance {
  final int id;
  final String nis;
  final String? activity;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Attendance({
    required this.id,
    required this.nis,
    this.activity,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      nis: json['nis'],
      activity: json['activity'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nis': nis,
      'activity': activity,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
