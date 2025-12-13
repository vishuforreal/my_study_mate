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
      await _apiService.post('/admin/notes', body: noteData);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> uploadBook(Map<String, dynamic> bookData) async {
    try {
      await _apiService.post('/admin/books', body: bookData);
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
      await _apiService.post('/admin/ppts', body: pptData);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> uploadProject(Map<String, dynamic> projectData) async {
    try {
      await _apiService.post('/admin/projects', body: projectData);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> uploadAssignment(Map<String, dynamic> assignmentData) async {
    try {
      await _apiService.post('/admin/assignments', body: assignmentData);
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

  Future<void> deleteUnit(String subjectName, int unitNumber) async {
    try {
      await _apiService.delete('/admin/notes/unit/$subjectName/$unitNumber');
    } catch (e) {
      rethrow;
    }
  }

  // ============ BOOKS MANAGEMENT ============

  Future<void> deleteBook(String bookId) async {
    try {
      await _apiService.delete('/admin/books/$bookId');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteBookUnit(String subjectName, int unitNumber) async {
    try {
      await _apiService.delete('/admin/books/unit/$subjectName/$unitNumber');
    } catch (e) {
      rethrow;
    }
  }

  // ============ PPTs MANAGEMENT ============

  Future<void> deletePPT(String pptId) async {
    try {
      await _apiService.delete('/admin/ppts/$pptId');
    } catch (e) {
      rethrow;
    }
  }

  // ============ PROJECTS MANAGEMENT ============

  Future<List<Map<String, dynamic>>> getProjectsByCategory(String category) async {
    try {
      final response = await _apiService.get('/admin/projects/category/$category');
      if (response['success']) {
        return List<Map<String, dynamic>>.from(response['projects']);
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      await _apiService.delete('/admin/projects/$projectId');
    } catch (e) {
      rethrow;
    }
  }

  // ============ ASSIGNMENTS MANAGEMENT ============

  Future<void> deleteAssignment(String assignmentId) async {
    try {
      await _apiService.delete('/admin/assignments/$assignmentId');
    } catch (e) {
      rethrow;
    }
  }
}