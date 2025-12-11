import '../models/content_models.dart';
import 'api_service.dart';

class ContentService {
  final ApiService _apiService = ApiService();

  // ============ NOTES ============

  Future<List<NoteModel>> getNotes({
    String? category,
    String? course,
    String? subject,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (category != null) queryParams['category'] = category;
      if (course != null) queryParams['course'] = course;
      if (subject != null) queryParams['subject'] = subject;

      final response = await _apiService.get('/student/notes', queryParams: queryParams);

      if (response['success']) {
        final List notes = response['notes'];
        return notes.map((note) => NoteModel.fromJson(note)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  // ============ BOOKS ============

  Future<List<BookModel>> getBooks({
    String? category,
    String? course,
    String? subject,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (category != null) queryParams['category'] = category;
      if (course != null) queryParams['course'] = course;
      if (subject != null) queryParams['subject'] = subject;

      final response = await _apiService.get('/student/books', queryParams: queryParams);

      if (response['success']) {
        final List books = response['books'];
        return books.map((book) => BookModel.fromJson(book)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  // ============ TESTS ============

  Future<List<TestModel>> getTests({
    String? category,
    String? course,
    String? subject,
    String? difficulty,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (category != null) queryParams['category'] = category;
      if (course != null) queryParams['course'] = course;
      if (subject != null) queryParams['subject'] = subject;
      if (difficulty != null) queryParams['difficulty'] = difficulty;

      final response = await _apiService.get('/student/tests', queryParams: queryParams);

      if (response['success']) {
        final List tests = response['tests'];
        return tests.map((test) => TestModel.fromJson(test)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<TestModel?> getTestById(String id) async {
    try {
      final response = await _apiService.get('/student/tests/$id');

      if (response['success']) {
        return TestModel.fromJson(response['test']);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> submitTest(String testId, List<Map<String, dynamic>> answers) async {
    try {
      final response = await _apiService.post(
        '/student/tests/$testId/submit',
        body: {'answers': answers},
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // ============ PPTs ============

  Future<List<PPTModel>> getPPTs({
    String? category,
    String? course,
    String? subject,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (category != null) queryParams['category'] = category;
      if (course != null) queryParams['course'] = course;
      if (subject != null) queryParams['subject'] = subject;

      final response = await _apiService.get('/student/ppts', queryParams: queryParams);

      if (response['success']) {
        final List ppts = response['ppts'];
        return ppts.map((ppt) => PPTModel.fromJson(ppt)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  // ============ PROJECTS ============

  Future<List<ProjectModel>> getProjects({
    String? category,
    String? technology,
    String? difficulty,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (category != null) queryParams['category'] = category;
      if (technology != null) queryParams['technology'] = technology;
      if (difficulty != null) queryParams['difficulty'] = difficulty;

      final response = await _apiService.get('/student/projects', queryParams: queryParams);

      if (response['success']) {
        final List projects = response['projects'];
        return projects.map((project) => ProjectModel.fromJson(project)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  // ============ ASSIGNMENTS ============

  Future<List<AssignmentModel>> getAssignments({
    String? category,
    String? course,
    String? subject,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (category != null) queryParams['category'] = category;
      if (course != null) queryParams['course'] = course;
      if (subject != null) queryParams['subject'] = subject;

      final response = await _apiService.get('/student/assignments', queryParams: queryParams);

      if (response['success']) {
        final List assignments = response['assignments'];
        return assignments.map((assignment) => AssignmentModel.fromJson(assignment)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  // ============ DOWNLOAD TRACKING ============

  Future<void> trackDownload(String type, String id) async {
    try {
      await _apiService.put('/student/download/$type/$id');
    } catch (e) {
      // Silently fail - download tracking is not critical
    }
  }
}
