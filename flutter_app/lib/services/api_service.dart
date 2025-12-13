import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;

  // Initialize token from storage
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConstants.tokenKey);
  }

  // Set token
  void setToken(String token) {
    _token = token;
  }

  // Clear token
  void clearToken() {
    _token = null;
  }

  // Get headers
  Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (includeAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  // Handle response
  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = json.decode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      throw ApiException(
        message: body['message'] ?? 'An error occurred',
        statusCode: response.statusCode,
      );
    }
  }

  // GET request
  Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? queryParams}) async {
    try {
      var uri = Uri.parse('${AppConstants.baseUrl}$endpoint');
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http.get(uri, headers: _getHeaders());
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // POST request
  Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? body, bool includeAuth = true}) async {
    try {
      final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');
      final response = await http.post(
        uri,
        headers: _getHeaders(includeAuth: includeAuth),
        body: json.encode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // PUT request
  Future<Map<String, dynamic>> put(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');
      final response = await http.put(
        uri,
        headers: _getHeaders(),
        body: json.encode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');
      final response = await http.delete(uri, headers: _getHeaders());
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // Multipart request for file uploads
  Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    Map<String, String> fields,
    Map<String, String> files,
  ) async {
    try {
      final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      if (_token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }

      // Add fields
      request.fields.addAll(fields);

      // Add files
      for (var entry in files.entries) {
        request.files.add(await http.MultipartFile.fromPath(entry.key, entry.value));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // Multipart request with mixed data types
  Future<Map<String, dynamic>> postMultipart(String endpoint, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      if (_token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }

      // Process data
      for (var entry in data.entries) {
        if (entry.value == null) {
          continue;
        } else if (entry.value is String || entry.value is int || entry.value is double || entry.value is bool) {
          request.fields[entry.key] = entry.value.toString();
        } else if (entry.value.runtimeType.toString().contains('File')) {
          // Handle File objects
          request.files.add(await http.MultipartFile.fromPath(entry.key, entry.value.path));
        } else {
          // Convert other types to string
          request.fields[entry.key] = entry.value.toString();
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException({required this.message, required this.statusCode});

  @override
  String toString() => message;
}
