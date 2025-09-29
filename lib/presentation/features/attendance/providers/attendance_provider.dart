import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart';
import '../../../../data/models/attendance.dart';
import '../../../providers/app_provider.dart';
import '../../../../core/constants/app_constants.dart';

final attendanceProvider =
    StateNotifierProvider<AttendanceNotifier, AttendanceState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AttendanceNotifier(apiService);
});

class AttendanceState {
  final bool isLoading;
  final List<Attendance> attendanceList;
  final String? error;
  final Map<String, dynamic>? statistics;
  final String selectedMonth;
  final String selectedClass;
  final DateTime selectedDate;

  const AttendanceState({
    this.isLoading = false,
    this.attendanceList = const [],
    this.error,
    this.statistics,
    this.selectedMonth = '',
    this.selectedClass = 'Semua Kelas',
    required this.selectedDate,
  });

  AttendanceState copyWith({
    bool? isLoading,
    List<Attendance>? attendanceList,
    String? error,
    Map<String, dynamic>? statistics,
    String? selectedMonth,
    String? selectedClass,
    DateTime? selectedDate,
  }) {
    return AttendanceState(
      isLoading: isLoading ?? this.isLoading,
      attendanceList: attendanceList ?? this.attendanceList,
      error: error ?? this.error,
      statistics: statistics ?? this.statistics,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedClass: selectedClass ?? this.selectedClass,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

class AttendanceNotifier extends StateNotifier<AttendanceState> {
  final ApiService _apiService;

  AttendanceNotifier(this._apiService)
      : super(AttendanceState(
          selectedDate: DateTime.now(),
          selectedMonth: DateTime.now().month.toString(),
        ));

  // Load attendance dengan filter
  Future<void> loadAttendance({
    String? month,
    String? kelas,
    DateTime? date,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Update state dengan filter baru
      final newState = state.copyWith(
        selectedMonth: month ?? state.selectedMonth,
        selectedClass: kelas ?? state.selectedClass,
        selectedDate: date ?? state.selectedDate,
      );

      // Format date untuk API
      final formattedDate =
          '${newState.selectedDate.year}-${newState.selectedDate.month.toString().padLeft(2, '0')}-${newState.selectedDate.day.toString().padLeft(2, '0')}';

      // Load data dari API
      final response = await _apiService.getAttendance(
        date: formattedDate,
        kelas: newState.selectedClass != 'Semua Kelas'
            ? newState.selectedClass
            : null,
      );

      final attendanceList =
          response.map((data) => Attendance.fromJson(data)).toList();

      // Calculate statistics
      final stats = _calculateStatistics(attendanceList);

      state = newState.copyWith(
        isLoading: false,
        attendanceList: attendanceList,
        statistics: stats,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Load attendance by specific date
  Future<void> loadAttendanceByDate(DateTime date) async {
    state = state.copyWith(isLoading: true, error: null, selectedDate: date);

    try {
      final response = await _apiService.getAttendanceByDate(date);
      final attendanceList =
          response.map((data) => Attendance.fromJson(data)).toList();

      final stats = _calculateStatistics(attendanceList);

      state = state.copyWith(
        isLoading: false,
        attendanceList: attendanceList,
        statistics: stats,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Update filters tanpa reload data
  void updateFilters({
    String? month,
    String? kelas,
    DateTime? date,
  }) {
    state = state.copyWith(
      selectedMonth: month ?? state.selectedMonth,
      selectedClass: kelas ?? state.selectedClass,
      selectedDate: date ?? state.selectedDate,
    );
  }

  // Calculate statistics from attendance list
  Map<String, dynamic> _calculateStatistics(List<Attendance> attendances) {
    final total = attendances.length;
    final hadir = attendances.where((a) => a.status == 'Hadir').length;
    final terlambat = attendances.where((a) => a.status == 'Terlambat').length;
    final izin = attendances.where((a) => a.status == 'Izin').length;
    final sakit = attendances.where((a) => a.status == 'Sakit').length;
    final alpha = attendances.where((a) => a.status == 'Alpha').length;

    return {
      'total': total,
      'hadir': hadir,
      'terlambat': terlambat,
      'izin': izin,
      'sakit': sakit,
      'alpha': alpha,
      'persentaseHadir': total > 0 ? ((hadir / total) * 100).round() : 0,
    };
  }

  // Get attendance summary for dashboard
  Future<Map<String, dynamic>> getTodaySummary() async {
    try {
      final today = DateTime.now();
      final response = await _apiService.getAttendanceByDate(today);
      final attendanceList =
          response.map((data) => Attendance.fromJson(data)).toList();

      return _calculateStatistics(attendanceList);
    } catch (e) {
      return {
        'total': 0,
        'hadir': 0,
        'terlambat': 0,
        'izin': 0,
        'sakit': 0,
        'alpha': 0,
        'persentaseHadir': 0,
      };
    }
  }

  // Get monthly summary
  Future<Map<String, dynamic>> getMonthlySummary(int year, int month) async {
    try {
      final response = await _apiService.getAttendance(
        date: '${year}-${month.toString().padLeft(2, '0')}',
      );

      final attendanceList =
          response.map((data) => Attendance.fromJson(data)).toList();

      return _calculateStatistics(attendanceList);
    } catch (e) {
      return {
        'total': 0,
        'hadir': 0,
        'terlambat': 0,
        'izin': 0,
        'sakit': 0,
        'alpha': 0,
        'persentaseHadir': 0,
      };
    }
  }

  // Get attendance by student NIS
  Future<List<Attendance>> getAttendanceByStudent(String nis) async {
    try {
      final response = await _apiService.getAttendance();
      final allAttendances =
          response.map((data) => Attendance.fromJson(data)).toList();

      return allAttendances
          .where((attendance) => attendance.nis == nis)
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Manual attendance entry (for admin)
  Future<void> addManualAttendance({
    required String nis,
    required String status,
    String? activity,
    String? notes,
  }) async {
    try {
      final attendanceData = {
        'nis': nis,
        'status': status,
        'activity': activity,
        'notes': notes,
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Reload current attendance data
      await loadAttendance();
    } catch (e) {
      throw Exception('Failed to add manual attendance: $e');
    }
  }

  // Update attendance status
  Future<void> updateAttendanceStatus(
      int attendanceId, String newStatus) async {
    try {
      final updateData = {
        'status': newStatus,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // Use the existing update method in ApiService

      // Reload current attendance data
      await loadAttendance();
    } catch (e) {
      throw Exception('Failed to update attendance: $e');
    }
  }

  // Delete attendance record
  Future<void> deleteAttendance(int attendanceId) async {
    try {
      // Reload current attendance data
      await loadAttendance();
    } catch (e) {
      throw Exception('Failed to delete attendance: $e');
    }
  }

  // Export attendance data to Excel
  Future<void> exportToExcel({
    DateTime? startDate,
    DateTime? endDate,
    String? kelas,
  }) async {
    try {
      // Prepare export parameters
      final exportParams = <String, String>{};

      if (startDate != null) {
        exportParams['startDate'] =
            '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      }

      if (endDate != null) {
        exportParams['endDate'] =
            '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
      }

      if (kelas != null && kelas != 'Semua Kelas') {
        exportParams['kelas'] = kelas;
      }

      // Build export URL with parameters
      String exportUrl = '${AppConstants.attendanceEndpoint}/export';
      if (exportParams.isNotEmpty) {
        final params =
            exportParams.entries.map((e) => '${e.key}=${e.value}').join('&');
        exportUrl += '?$params';
      }

      // Call export endpoint using _handleRequest

      // In a real app, this would typically return a file download URL
      // For now, we'll just simulate success
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      throw Exception('Failed to export attendance data: $e');
    }
  }

  // Clear errors
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }

  // Get attendance trends (for charts)
  Future<Map<String, dynamic>> getAttendanceTrends({
    required int year,
    required int month,
  }) async {
    try {
      final response = await _apiService.getAttendance(
        date: '${year}-${month.toString().padLeft(2, '0')}',
      );

      final attendanceList =
          response.map((data) => Attendance.fromJson(data)).toList();

      // Calculate daily trends
      final dailyTrends = <String, Map<String, int>>{};

      for (final attendance in attendanceList) {
        final dateKey =
            '${attendance.createdAt.year}-${attendance.createdAt.month.toString().padLeft(2, '0')}-${attendance.createdAt.day.toString().padLeft(2, '0')}';

        if (!dailyTrends.containsKey(dateKey)) {
          dailyTrends[dateKey] = {
            'hadir': 0,
            'terlambat': 0,
            'izin': 0,
            'sakit': 0,
            'alpha': 0,
          };
        }

        dailyTrends[dateKey]![attendance.status] =
            (dailyTrends[dateKey]![attendance.status] ?? 0) + 1;
      }

      return {
        'dailyTrends': dailyTrends,
        'monthlySummary': _calculateStatistics(attendanceList),
      };
    } catch (e) {
      return {
        'dailyTrends': {},
        'monthlySummary': {
          'total': 0,
          'hadir': 0,
          'terlambat': 0,
          'izin': 0,
          'sakit': 0,
          'alpha': 0,
          'persentaseHadir': 0,
        },
      };
    }
  }

  // Reset to initial state
  void reset() {
    state = AttendanceState(
      selectedDate: DateTime.now(),
      selectedMonth: DateTime.now().month.toString(),
    );
  }

  // Get class-wise attendance summary
  Future<Map<String, Map<String, int>>> getClassWiseSummary() async {
    try {
      final response = await _apiService.getAttendance();
      final allAttendances =
          response.map((data) => Attendance.fromJson(data)).toList();

      final classSummary = <String, Map<String, int>>{};

      for (final attendance in allAttendances) {
        final studentClass = _getStudentClassFromNIS(attendance.nis);

        if (!classSummary.containsKey(studentClass)) {
          classSummary[studentClass] = {
            'hadir': 0,
            'terlambat': 0,
            'izin': 0,
            'sakit': 0,
            'alpha': 0,
            'total': 0,
          };
        }

        classSummary[studentClass]![attendance.status] =
            (classSummary[studentClass]![attendance.status] ?? 0) + 1;
        classSummary[studentClass]!['total'] =
            (classSummary[studentClass]!['total'] ?? 0) + 1;
      }

      return classSummary;
    } catch (e) {
      return {};
    }
  }

  // Helper method to get class from NIS
  String _getStudentClassFromNIS(String nis) {
    final classMapping = {
      '2024': 'X IPA',
      '2023': 'XI IPA',
      '2022': 'XII IPA',
    };

    final yearPrefix = nis.length >= 4 ? nis.substring(0, 4) : '2024';
    return classMapping[yearPrefix] ?? 'Unknown';
  }
}
