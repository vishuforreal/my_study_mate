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

  Future<Map<String, dynamic>> toggleStudentBlock(String studentId) async {
    try {
      final response = await _apiService.put('/admin/students/$studentId/block');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateStudentPermissions(String studentId, Map<String, dynamic> permissions) async {
    try {
      final response = await _apiService.put('/admin/students/$studentId/permissions', body: {
        'permissions': permissions,
      });
      return response;
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

  Future<List<UserModel>> getAdmins() async {
    try {
      final response = await _apiService.get('/admin/admins');
      if (response['success']) {
        final List admins = response['admins'];
        return admins.map((admin) => UserModel.fromJson(admin)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

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

  Future<void> updateAdmin(String adminId, String name, String email) async {
    try {
      await _apiService.put('/admin/admins/$adminId', body: {
        'name': name,
        'email': email,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAdmin(String adminId) async {
    try {
      await _apiService.delete('/admin/admins/$adminId');
    } catch (e) {
      rethrow;
    }
  }

  // ============ CONTENT UPLOAD ============

  Future<void> uploadNote(Map<String, dynamic> noteData) async {
    try {
      await _apiService.postMultipart('/admin/notes', noteData);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> uploadBook(Map<String, dynamic> bookData) async {
    try {
      await _apiService.postMultipart('/admin/books', bookData);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> uploadTest(Map<String, dynamic> testData) async {
    try {
      await _apiService.post('/admin/tests', body: testData);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> uploadPPT(Map<String, dynamic> pptData) async {
    try {
      await _apiService.postMultipart('/admin/ppts', pptData);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> uploadProject(Map<String, dynamic> projectData) async {
    try {
      await _apiService.postMultipart('/admin/projects', projectData);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> uploadAssignment(Map<String, dynamic> assignmentData) async {
    try {
      await _apiService.postMultipart('/admin/assignments', assignmentData);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> uploadSimpleNote(Map<String, dynamic> noteData) async {
    try {
      await _apiService.post('/admin/notes/simple', body: noteData);
    } catch (e) {
      rethrow;
    }
  }
}