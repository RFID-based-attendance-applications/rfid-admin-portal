class AppRoutes {
  // Static Paths
  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String attendance = '/attendance';
  static const String siswa = '/siswa';
  static const String users = '/users';
  static const String libur = '/libur';

  // Dynamic Route Helpers
  static String siswaDetail(String id) => '/siswa/$id';
  static String siswaEdit(String id) => '/siswa/$id/edit';
  static String attendanceByDate(String date) => '/attendance/$date';
  static String liburEdit(String id) => '/libur/$id/edit';

  // Named Routes (untuk GoRouter)
  static const String namedSplash = 'splash';
  static const String namedLogin = 'login';
  static const String namedDashboard = 'dashboard';
  static const String namedSiswa = 'siswa';
  static const String namedAttendance = 'attendance';
  static const String namedUsers = 'users';
  static const String namedLibur = 'libur';
}
