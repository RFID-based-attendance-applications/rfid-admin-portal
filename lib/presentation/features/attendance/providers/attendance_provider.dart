import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/attendance.dart';

final attendanceProvider =
    StateNotifierProvider<AttendanceProvider, List<Attendance>>((ref) {
  return AttendanceProvider();
});

class AttendanceProvider extends StateNotifier<List<Attendance>> {
  AttendanceProvider()
      : super([
          Attendance(
            id: 1,
            nis: "1001",
            activity: "Upacara Bendera",
            status: "hadir",
            createdAt: DateTime(2025, 9, 1, 7, 30),
            updatedAt: DateTime(2025, 9, 1, 7, 30),
          ),
          Attendance(
            id: 2,
            nis: "1002",
            activity: "Pelajaran Matematika",
            status: "izin",
            createdAt: DateTime(2025, 9, 1, 8, 0),
            updatedAt: DateTime(2025, 9, 1, 8, 0),
          ),
          Attendance(
            id: 3,
            nis: "1003",
            activity: "Praktikum IPA",
            status: "sakit",
            createdAt: DateTime(2025, 9, 1, 9, 0),
            updatedAt: DateTime(2025, 9, 1, 9, 0),
          ),
          Attendance(
            id: 4,
            nis: "1004",
            activity: null,
            status: "alpha",
            createdAt: DateTime(2025, 9, 1, 7, 30),
            updatedAt: DateTime(2025, 9, 1, 7, 30),
          ),
        ]);

  void addAttendance(Attendance attendance) {
    state = [...state, attendance];
  }

  void updateAttendance(int index, Attendance updatedAttendance) {
    state = [
      ...state.take(index),
      updatedAttendance,
      ...state.skip(index + 1),
    ];
  }

  void deleteAttendance(int index) {
    state = [...state..removeAt(index)];
  }
}
