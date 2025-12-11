import 'package:flutter/material.dart';

class AppConstants {
  // API Configuration
  static const String baseUrl = 'https://mystudymate-production-2878.up.railway.app/api';
  // Replace YOUR_RAILWAY_APP_NAME with your actual Railway app name
  // For local testing: 'http://localhost:5000/api'
  
  static const String authEndpoint = '$baseUrl/auth';
  static const String studentEndpoint = '$baseUrl/student';
  static const String adminEndpoint = '$baseUrl/admin';

  // App Info
  static const String appName = 'My Study Mate';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';

  // Categories
  static const List<String> categories = ['College', 'School', 'Competitive'];

  // Courses
  static const List<String> courses = [
    'BCA',
    'BBA',
    'MBA',
    'MCA',
    'B.Tech',
    'M.Tech',
    'Class 10',
    'Class 11',
    'Class 12',
    'SSC',
    'UPSC',
    'Other'
  ];

  // Subjects (Sample - can be expanded)
  static const List<String> subjects = [
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'Computer Science',
    'English',
    'Hindi',
    'History',
    'Geography',
    'Economics',
    'Business Studies',
    'Accountancy',
    'Other'
  ];

  // Difficulty Levels
  static const List<String> difficultyLevels = ['Easy', 'Medium', 'Hard'];

  // Project Categories
  static const List<String> projectCategories = [
    'Web Development',
    'Mobile App',
    'Desktop App',
    'Data Science',
    'Machine Learning',
    'Other'
  ];

  // App Colors
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color secondaryColor = Color(0xFF4CAF50);
  static const Color accentColor = Color(0xFFFF6B6B);
  static const Color darkPrimary = Color(0xFF5A52D5);
  
  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF5F7FA);
  static const Color lightSurface = Colors.white;
  static const Color lightText = Color(0xFF2D3436);
  static const Color lightTextSecondary = Color(0xFF636E72);
  
  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF1A1A2E);
  static const Color darkSurface = Color(0xFF16213E);
  static const Color darkText = Color(0xFFECECEC);
  static const Color darkTextSecondary = Color(0xFFB2B2B2);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF5A52D5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // File Size Limits
  static const int maxFileSize = 50 * 1024 * 1024; // 50MB

  // Pagination
  static const int itemsPerPage = 20;
}
