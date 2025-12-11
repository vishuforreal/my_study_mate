import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isStudent => _user?.isStudent ?? false;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isSuperAdmin => _user?.isSuperAdmin ?? false;

  // Initialize - check if user is logged in
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        _user = await _authService.getStoredUser();
        // Optionally fetch fresh user data
        final freshUser = await _authService.getCurrentUser();
        if (freshUser != null) {
          _user = freshUser;
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    required String category,
    String? subcategory,
    required String securityQuestion,
    required String securityAnswer,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        category: category,
        subcategory: subcategory,
        securityQuestion: securityQuestion,
        securityAnswer: securityAnswer,
      );

      if (response['success']) {
        _user = UserModel.fromJson(response['user']);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _error = response['message'];
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );

      if (response['success']) {
        _user = UserModel.fromJson(response['user']);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _error = response['message'];
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update profile
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? category,
    String? subcategory,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.updateProfile(
        name: name,
        phone: phone,
        category: category,
        subcategory: subcategory,
      );

      if (response['success']) {
        _user = UserModel.fromJson(response['user']);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _error = response['message'];
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      _isLoading = false;
      notifyListeners();
      return response['success'];
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Upload profile photo
  Future<bool> uploadProfilePhoto(String filePath) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.uploadProfilePhoto(filePath);

      if (response['success']) {
        // Refresh user data
        _user = await _authService.getStoredUser();
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _error = response['message'];
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _error = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
