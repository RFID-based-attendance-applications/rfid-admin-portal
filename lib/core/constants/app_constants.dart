class AppConstants {
  static const String baseUrl = 'http://localhost:3000/api';
  // auth
  static const String loginEndpoint = '$baseUrl/auth/signin';
  // users
  static const String usersEndpoint = '$baseUrl/users';
  // siswa
  static const String siswaEndpoint = '$baseUrl/siswa';
  static const String importSiswaEndpoint = '$baseUrl/siswa/import';
  // attendance
  static const String attendanceEndpoint = '$baseUrl/attendance';
  // permission
  static const String permissionEndpoint = '$baseUrl/permission';
  // whatsapp
  static const String whatsappEndpoint = '$baseUrl/whatsapp/qr';
}
