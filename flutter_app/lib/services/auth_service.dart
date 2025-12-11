import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../config/constants.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  // Register new user
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    required String category,
    String? subcategory,
    required String securityQuestion,
    required String securityAnswer,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/register',
        body: {
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'category': category,
          'subcategory': subcategory,
          'securityQuestion': securityQuestion,
          'securityAnswer': securityAnswer,
        },
        includeAuth: false,
      );

      if (response['success']) {
        // Save token and user data
        await _saveAuthData(response['token'], response['user']);
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/login',
        body: {
          'email': email,
          'password': password,
        },
        includeAuth: false,
      );

      if (response['success']) {
        // Save token and user data
        await _saveAuthData(response['token'], response['user']);
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    try {
      final response = await _apiService.get('/auth/me');

      if (response['success']) {
        return UserModel.fromJson(response['user']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update profile
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
    String? category,
    String? subcategory,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (phone != null) body['phone'] = phone;
      if (category != null) body['category'] = category;
      if (subcategory != null) body['subcategory'] = subcategory;

      final response = await _apiService.put('/auth/update-profile', body: body);

      if (response['success']) {
        // Update stored user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.userKey, json.encode(response['user']));
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Change password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _apiService.put(
        '/auth/change-password',
        body: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Upload profile photo
  Future<Map<String, dynamic>> uploadProfilePhoto(String filePath) async {
    try {
      final response = await _apiService.uploadFile(
        '/auth/upload-photo',
        {},
        {'photo': filePath},
      );

      if (response['success']) {
        // Update stored user data
        final user = await getStoredUser();
        if (user != null) {
          final updatedUser = UserModel(
            id: user.id,
            name: user.name,
            email: user.email,
            phone: user.phone,
            category: user.category,
            subcategory: user.subcategory,
            role: user.role,
            profilePhoto: response['photoUrl'],
            permissions: user.permissions,
            createdAt: user.createdAt,
          );
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(AppConstants.userKey, json.encode(updatedUser.toJson()));
        }
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
    _apiService.clearToken();
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    return token != null && token.isNotEmpty;
  }

  // Get stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  // Get stored user
  Future<UserModel?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(AppConstants.userKey);
    if (userJson != null) {
      return UserModel.fromJson(json.decode(userJson));
    }
    return null;
  }

  // Get security question for password reset
  Future<Map<String, dynamic>> getSecurityQuestion(String email) async {
    try {
      final response = await _apiService.post(
        '/auth/forgot-password',
        body: {'email': email},
        includeAuth: false,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Reset password with security answer
  Future<void> resetPassword(String email, String securityAnswer, String newPassword) async {
    try {
      await _apiService.post(
        '/auth/verify-security',
        body: {
          'email': email,
          'securityAnswer': securityAnswer,
          'newPassword': newPassword,
        },
        includeAuth: false,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Save auth data
  Future<void> _saveAuthData(String token, Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
    await prefs.setString(AppConstants.userKey, json.encode(userData));
    _apiService.setToken(token);
  }
}
