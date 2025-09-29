import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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

  Future<Map<String, dynamic>> _handleRequest(
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
          (method == 'POST' || method == 'PUT' || method == 'PATCH')) {
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
        throw ApiException(
          message: errorData['message'] ?? 'Server error',
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

    // Save token
    if (response['token'] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.tokenKey, response['token']);
      await prefs.setString(
          AppConstants.userDataKey, jsonEncode(response['user']));
    }

    return response;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userDataKey);
  }

  // User Management
  Future<List<dynamic>> getUsers() async {
    final response = await _handleRequest('GET', AppConstants.usersEndpoint);
    return response['data'] ?? [];
  }

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    return await _handleRequest(
      'POST',
      AppConstants.usersEndpoint,
      body: userData,
    );
  }

  Future<Map<String, dynamic>> updateUser(
      String id, Map<String, dynamic> userData) async {
    return await _handleRequest(
      'PUT',
      AppConstants.userByIdEndpoint(id),
      body: userData,
    );
  }

  Future<void> deleteUser(String id) async {
    await _handleRequest('DELETE', AppConstants.userByIdEndpoint(id));
  }

  // Siswa Management
  Future<List<dynamic>> getSiswa() async {
    final response = await _handleRequest('GET', AppConstants.siswaEndpoint);
    return response['data'] ?? [];
  }

  Future<Map<String, dynamic>> createSiswa(
      Map<String, dynamic> siswaData) async {
    return await _handleRequest(
      'POST',
      AppConstants.siswaEndpoint,
      body: siswaData,
    );
  }

  Future<Map<String, dynamic>> updateSiswa(
      String id, Map<String, dynamic> siswaData) async {
    return await _handleRequest(
      'PUT',
      AppConstants.siswaByIdEndpoint(id),
      body: siswaData,
    );
  }

  Future<void> deleteSiswa(String id) async {
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
        return jsonDecode(responseBody);
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
    return response['data'] ?? [];
  }

  Future<List<dynamic>> getAttendanceByDate(DateTime date) async {
    final response = await _handleRequest(
      'GET',
      AppConstants.attendanceByDateEndpoint(date),
    );
    return response['data'] ?? [];
  }

  // RFID Management
  Future<Map<String, dynamic>> registerRFID(
      String siswaId, String rfidTag) async {
    return await _handleRequest(
      'POST',
      '${AppConstants.siswaEndpoint}/$siswaId/rfid',
      body: {'rfid_tag': rfidTag},
    );
  }
}
