import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart';
import '../../../providers/app_provider.dart'; // PASTIKAN: app_providers.dart
import '../../auth/providers/auth_provider.dart'; // PASTIKAN: auth_provider.dart

final dashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final authState = ref.watch(authProvider);

  // ✅ DEVELOPMENT: Comment auth check untuk bypass
  // if (!authState.isAuthenticated) {
  //   throw Exception('Not authenticated');
  // }

  try {
    // Fetch dashboard statistics
    final siswaResponse = await apiService.getSiswa();
    final attendanceResponse = await apiService.getAttendance();
    final usersResponse = await apiService.getUsers();

    final totalSiswa = (siswaResponse as List).length;
    final totalUsers = (usersResponse as List).length;

    // Calculate today's attendance
    final today = DateTime.now();
    final todayAttendances = (attendanceResponse as List).where((attendance) {
      final attendanceDate = DateTime.parse(attendance['createdAt']);
      return attendanceDate.year == today.year &&
          attendanceDate.month == today.month &&
          attendanceDate.day == today.day;
    }).toList();

    final hadirHariIni =
        todayAttendances.where((a) => a['status'] == 'Hadir').length;
    final terlambatHariIni =
        todayAttendances.where((a) => a['status'] == 'Terlambat').length;
    final tidakHadirHariIni = totalSiswa - hadirHariIni - terlambatHariIni;

    return {
      'totalSiswa': totalSiswa,
      'hadirHariIni': hadirHariIni,
      'terlambatHariIni': terlambatHariIni,
      'tidakHadirHariIni': tidakHadirHariIni,
      'totalUsers': totalUsers,
      'recentActivities': todayAttendances.take(10).toList(),
    };
  } catch (e) {
    // Return default data jika API error
    return {
      'totalSiswa': 0,
      'hadirHariIni': 0,
      'terlambatHariIni': 0,
      'tidakHadirHariIni': 0,
      'totalUsers': 0,
      'recentActivities': [],
    };
  }
});
