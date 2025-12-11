import '../models/user_model.dart';
import '../models/content_models.dart';
import 'api_service.dart';

class AdminService {
  final ApiService _apiService = ApiService();

  // ============ STUDENT MANAGEMENT ============

  Future<List<UserModel>> getStudents() async {
    try {
      final response = await _apiService.get('/admin/students');
      if (response['success']) {
        final List students = response['students'];
        return students.map((student) => UserModel.fromJson(student)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleStudentBlock(String studentId) async {
    try {
      await _apiService.put('/admin/students/$studentId/block');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateStudentPermissions(String studentId, Map<String, dynamic> permissions) async {
    try {
      await _apiService.put('/admin/students/$studentId/permissions', body: {
        'permissions': permissions,
      });
    } catch (e) {
      rethrow;
    }
  }

  // ============ CONTENT MANAGEMENT ============

  Future<List<NoteModel>> getAllNotes() async {
    try {
      final response = await _apiService.get('/admin/notes');
      if (response['success']) {
        final List notes = response['notes'];
        return notes.map((note) => NoteModel.fromJson(note)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      await _apiService.delete('/admin/notes/$noteId');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<TestModel>> getAllTests() async {
    try {
      final response = await _apiService.get('/admin/tests');
      if (response['success']) {
        final List tests = response['tests'];
        return tests.map((test) => TestModel.fromJson(test)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTest(String testId) async {
    try {
      await _apiService.delete('/admin/tests/$testId');
    } catch (e) {
      rethrow;
    }
  }

  // ============ ANALYTICS ============

  Future<Map<String, dynamic>> getAnalytics() async {
    try {
      final response = await _apiService.get('/admin/analytics');
      if (response['success']) {
        return response['analytics'];
      }
      return {};
    } catch (e) {
      rethrow;
    }
  }

  // ============ SUPER ADMIN ============

  Future<void> createAdmin(String name, String email, String password) async {
    try {
      await _apiService.post('/admin/create-admin', body: {
        'name': name,
        'email': email,
        'password': password,
      });
    } catch (e) {
      rethrow;
    }
  }
}