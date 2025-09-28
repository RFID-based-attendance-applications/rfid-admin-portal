import 'dart:convert';
import 'package:http/http.dart' as http;
import '../exceptions/api_exceptions.dart';

class ApiService {
  final http.Client _client = http.Client();

  Future<Map<String, dynamic>> _request(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse(endpoint);
    final request = http.Request(method, uri);

    if (headers != null) {
      request.headers.addAll(headers);
    }

    if (body != null &&
        (method == 'POST' || method == 'PUT' || method == 'PATCH')) {
      request.body = jsonEncode(body);
      request.headers['Content-Type'] = 'application/json';
    }

    final response = await _client.send(request);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseBody = await response.stream.bytesToString();
      return jsonDecode(responseBody);
    } else {
      final responseBody = await response.stream.bytesToString();
      throw ApiException(
        message: responseBody.isEmpty
            ? 'Unknown error'
            : jsonDecode(responseBody)['message'] ?? 'Server error',
        statusCode: response.statusCode,
      );
    }
  }

  Future<Map<String, dynamic>> post(String endpoint,
          {Map<String, dynamic>? body}) =>
      _request('POST', endpoint, body: body);

  Future<Map<String, dynamic>> get(String endpoint) =>
      _request('GET', endpoint);

  Future<Map<String, dynamic>> put(String endpoint,
          {Map<String, dynamic>? body}) =>
      _request('PUT', endpoint, body: body);

  Future<Map<String, dynamic>> delete(String endpoint) =>
      _request('DELETE', endpoint);

  // Untuk upload file (import siswa)
  Future<Map<String, dynamic>> uploadFile(
      String endpoint, List<int> fileBytes, String filename) async {
    final request = http.MultipartRequest('POST', Uri.parse(endpoint))
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: filename,
      ));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(responseBody);
    } else {
      throw ApiException(
        message: jsonDecode(responseBody)['message'] ?? 'Upload failed',
        statusCode: response.statusCode,
      );
    }
  }
}
