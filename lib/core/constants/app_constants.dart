class AppConstants {
  static const String appName = 'RFID Admin Portal';

  // API Configuration
  static const String baseUrl = 'http://localhost:3000/api';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // API Endpoints
  static const String loginEndpoint = '$baseUrl/auth/signin';
  static const String logoutEndpoint = '$baseUrl/auth/signout';
  static const String refreshTokenEndpoint = '$baseUrl/auth/refresh';

  // Users Management
  static const String usersEndpoint = '$baseUrl/users';
  static String userByIdEndpoint(String id) => '$usersEndpoint/$id';

  // Siswa Management
  static const String siswaEndpoint = '$baseUrl/siswa';
  static const String importSiswaEndpoint = '$baseUrl/siswa/import';
  static String siswaByIdEndpoint(String id) => '$siswaEndpoint/$id';

  // Attendance
  static const String attendanceEndpoint = '$baseUrl/attendance';
  static String attendanceByDateEndpoint(DateTime date) {
    final formattedDate =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return '$attendanceEndpoint/$formattedDate';
  }

  // Permissions
  static const String permissionEndpoint = '$baseUrl/permission';

  // WhatsApp Integration
  static const String whatsappEndpoint = '$baseUrl/whatsapp/qr';
  static const String whatsappStatusEndpoint = '$baseUrl/whatsapp/status';
  static const String sendMessageEndpoint = '$baseUrl/whatsapp/send';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'app_theme';

  // Pagination
  static const int defaultPageSize = 20;

  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
}
