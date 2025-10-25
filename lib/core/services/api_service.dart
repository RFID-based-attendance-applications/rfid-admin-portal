import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import '../constants/app_constants.dart';
import '../exceptions/api_exceptions.dart';

class ApiService {
  final http.Client _client = http.Client();
  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;
  ApiService._internal();

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);

    final headers = {
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<dynamic> _handleRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse(endpoint);

      if (requiresAuth && !headers.containsKey('Authorization')) {
        throw ApiException(
            message: 'Unauthorized - Please login again', statusCode: 401);
      }

      final request = http.Request(method, uri);
      request.headers.addAll(headers);

      if (body != null &&
          (method == 'POST' ||
              method == 'PUT' ||
              method == 'PATCH' ||
              method == 'DELETE')) {
        request.body = jsonEncode(body);
      }

      final response = await _client.send(request).timeout(
            const Duration(seconds: 30),
          );

      final responseBody = await response.stream.bytesToString();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseBody.isEmpty) return {'success': true};
        return jsonDecode(responseBody);
      } else {
        final errorData =
            responseBody.isNotEmpty ? jsonDecode(responseBody) : {};
        final errorMessage = errorData['message'] is String
            ? errorData['message'] as String
            : 'Server error';

        throw ApiException(
          message: errorMessage,
          statusCode: response.statusCode,
          errorData: errorData,
        );
      }
    } on http.ClientException catch (e) {
      throw ApiException(message: 'Network error: ${e.message}', statusCode: 0);
    } on FormatException catch (e) {
      throw ApiException(
          message: 'Data format error: ${e.message}', statusCode: 0);
    } catch (e) {
      throw ApiException(message: 'Unexpected error: $e', statusCode: 0);
    }
  }

  // Auth Methods
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await _handleRequest(
      'POST',
      AppConstants.loginEndpoint,
      body: {'username': username, 'password': password},
      requiresAuth: false,
    );

    print('🔐 Login API Response: $response');
    print('🔐 Response type: ${response.runtimeType}');

    if (response is! Map<String, dynamic>) {
      throw ApiException(
          message: 'Invalid response format from server', statusCode: 0);
    }

    final token = response['access_token'];
    if (token == null) {
      throw ApiException(
          message: 'Login successful but missing access_token', statusCode: 0);
    }

    // 🔁 Decode token untuk dapatkan user info
    final payload = Jwt.parseJwt(token);
    final user = {
      'id': payload['sub'],
      'username': payload['username'],
      'role': 'admin', // atau default role
    };

    print('🔑 Token received: $token');
    print('👤 User decoded from token: $user');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token.toString());
    await prefs.setString(AppConstants.userDataKey, jsonEncode(user));

    return {
      'access_token': token,
      'user': user,
    };
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userDataKey);
  }

  // User Management
  Future<List<dynamic>> getUsers() async {
    final response = await _handleRequest('GET', AppConstants.usersEndpoint);

    print('Users API Response: $response');
    print('Response type: ${response.runtimeType}');

    if (response is Map<String, dynamic>) {
      // Cek berbagai kemungkinan struktur response
      if (response['data'] is List) {
        return response['data'] as List<dynamic>;
      } else if (response['users'] is List) {
        return response['users'] as List<dynamic>;
      } else if (response['items'] is List) {
        return response['items'] as List<dynamic>;
      } else {
        print('Unexpected response structure: $response');
        return [];
      }
    } else if (response is List) {
      return response;
    } else {
      print('Unexpected response type: ${response.runtimeType}');
      return [];
    }
  }

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    final response = await _handleRequest(
      'POST',
      AppConstants.usersEndpoint,
      body: userData,
    );

    // Debug response
    print('Create User Response: $response');
    print('Response type: ${response.runtimeType}');

    if (response is Map<String, dynamic>) {
      return response;
    } else {
      throw ApiException(
          message:
              'Invalid response format: expected Map but got ${response.runtimeType}',
          statusCode: 0);
    }
  }

  // Siswa Management
  Future<List<dynamic>> getSiswa() async {
    final response = await _handleRequest('GET', AppConstants.siswaEndpoint);

    if (response is Map<String, dynamic> && response['data'] is List) {
      return response['data'] as List<dynamic>;
    } else if (response is List) {
      return response;
    } else if (response is Map<String, dynamic>) {
      return [];
    } else {
      return [];
    }
  }

  Future<Map<String, dynamic>> createSiswa(
      Map<String, dynamic> siswaData) async {
    final response = await _handleRequest(
      'POST',
      AppConstants.siswaEndpoint,
      body: siswaData,
    );

    if (response is Map<String, dynamic>) {
      return response;
    } else {
      throw ApiException(message: 'Invalid response format', statusCode: 0);
    }
  }

  // Siswa Management - Update juga jika perlu
  Future<Map<String, dynamic>> updateSiswa(
      int id, Map<String, dynamic> siswaData) async {
    final response = await _handleRequest(
      'PUT',
      AppConstants.siswaByIdEndpoint(id), // Sudah int
      body: siswaData,
    );

    if (response is Map<String, dynamic>) {
      return response;
    } else {
      throw ApiException(message: 'Invalid response format', statusCode: 0);
    }
  }

  Future<Map<String, dynamic>> createSiswaMultipart({
    required Map<String, String> fields,
    required File? imageFile,
  }) async {
    final headers = await _getHeaders();
    final request =
        http.MultipartRequest('POST', Uri.parse(AppConstants.siswaEndpoint));
    request.headers.addAll(headers);

    // Tambahkan field text
    fields.forEach((key, value) {
      request.fields[key] = value;
    });

    // Tambahkan file jika ada
    if (imageFile != null) {
      final fileStream = imageFile.readAsBytesSync();
      final fileName = imageFile.path.split('/').last; // Ambil nama file
      final mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';
      final multipartFile = http.MultipartFile.fromBytes(
        'image',
        fileStream,
        filename: fileName,
        contentType: MediaType.parse(mimeType),
      );
      request.files.add(multipartFile);
    }

    final response = await request.send().timeout(const Duration(seconds: 60));
    final responseBody = await response.stream.bytesToString();

    print('📡 Backend response body:');
    print(responseBody);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(responseBody);
    } else {
      final errorData = jsonDecode(responseBody);
      throw ApiException(
        message: errorData['message'] ?? 'Upload failed',
        statusCode: response.statusCode,
      );
    }
  }

// Method untuk update siswa dengan multipart (file + data)
  Future<Map<String, dynamic>> updateSiswaMultipart({
    required int id,
    required Map<String, String> fields,
    required File? imageFile,
  }) async {
    final headers = await _getHeaders();
    final request = http.MultipartRequest(
        'PUT', Uri.parse(AppConstants.siswaByIdEndpoint(id)));
    request.headers.addAll(headers);

    // Tambahkan field text
    fields.forEach((key, value) {
      request.fields[key] = value;
    });

    // Tambahkan file jika ada
    if (imageFile != null) {
      final fileStream = imageFile.readAsBytesSync();
      final fileName = imageFile.path.split('/').last; // Ambil nama file
      request.files.add(http.MultipartFile.fromBytes(
        'image', // Nama field file yang diharapkan backend
        fileStream,
        filename: fileName,
      ));
    }

    final response = await request.send().timeout(const Duration(seconds: 60));
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(responseBody);
    } else {
      final errorData = jsonDecode(responseBody);
      throw ApiException(
        message: errorData['message'] ?? 'Upload failed',
        statusCode: response.statusCode,
      );
    }
  }

  Future<void> deleteSiswa(int id) async {
    // Ubah ke int
    await _handleRequest('DELETE', AppConstants.siswaByIdEndpoint(id));
  }

  Future<Map<String, dynamic>> importSiswa(
      List<int> fileBytes, String filename) async {
    try {
      final headers = await _getHeaders();
      final request = http.MultipartRequest(
          'POST', Uri.parse(AppConstants.importSiswaEndpoint));

      request.headers.addAll(headers);
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: filename,
      ));

      final response =
          await request.send().timeout(const Duration(seconds: 60));
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(responseBody) as Map<String, dynamic>;
      } else {
        final errorData = jsonDecode(responseBody);
        throw ApiException(
          message: errorData['message'] ?? 'Upload failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ApiException(message: 'Upload error: $e', statusCode: 0);
    }
  }

  // Attendance Management
  Future<List<dynamic>> getAttendance({String? date, String? kelas}) async {
    String endpoint = AppConstants.attendanceEndpoint;
    final params = <String>[];

    if (date != null) params.add('date=$date');
    if (kelas != null && kelas != 'Semua Kelas') params.add('kelas=$kelas');

    if (params.isNotEmpty) {
      endpoint += '?${params.join('&')}';
    }

    final response = await _handleRequest('GET', endpoint);

    if (response is Map<String, dynamic> && response['data'] is List) {
      return response['data'] as List<dynamic>;
    } else if (response is List) {
      return response;
    } else if (response is Map<String, dynamic>) {
      return [];
    } else {
      return [];
    }
  }

  Future<List<dynamic>> getAttendanceByDate(DateTime date) async {
    final response = await _handleRequest(
      'GET',
      AppConstants.attendanceByDateEndpoint(date),
    );

    if (response is Map<String, dynamic> && response['data'] is List) {
      return response['data'] as List<dynamic>;
    } else if (response is List) {
      return response;
    } else if (response is Map<String, dynamic>) {
      return [];
    } else {
      return [];
    }
  }

  // Libur Management
  Future<List<dynamic>> getLibur() async {
    final response = await _handleRequest('GET', AppConstants.liburEndpoint);

    if (response is Map<String, dynamic>) {
      if (response['data'] is List) {
        return response['data'] as List<dynamic>;
      } else if (response['items'] is List) {
        return response['items'] as List<dynamic>;
      } else {
        print('Unexpected response structure: $response');
        return [];
      }
    } else if (response is List) {
      return response;
    } else {
      print('Unexpected response type: ${response.runtimeType}');
      return [];
    }
  }

  Future<Map<String, dynamic>> createLibur(
      Map<String, dynamic> liburData) async {
    final response = await _handleRequest(
      'POST',
      AppConstants.liburEndpoint,
      body: liburData,
    );

    if (response is Map<String, dynamic>) {
      return response;
    } else {
      throw ApiException(message: 'Invalid response format', statusCode: 0);
    }
  }

  Future<void> deleteLibur(int id) async {
    await _handleRequest(
      'DELETE',
      AppConstants.liburByIdEndpoint(id),
      body: {},
    );
  }

  // RFID Management
  Future<Map<String, dynamic>> registerRFID(int siswaId, String rfidTag) async {
    // Ambil data siswa terlebih dahulu (opsional)
    final siswaData =
        await _handleRequest('GET', AppConstants.siswaByIdEndpoint(siswaId));

    if (siswaData is Map<String, dynamic>) {
      // Siapkan data update
      final updatedData = {
        ...siswaData, // Salin semua field
        'qr_payload': rfidTag, // Tambahkan field rfid_tag
      };

      // Kirim PUT ke endpoint update
      final response = await _handleRequest(
        'PUT',
        AppConstants.siswaByIdEndpoint(siswaId),
        body: updatedData,
      );

      if (response is Map<String, dynamic>) {
        return response;
      } else {
        throw ApiException(message: 'Invalid response format', statusCode: 0);
      }
    } else {
      throw ApiException(
          message: 'Failed to fetch student data', statusCode: 0);
    }
  }
}
