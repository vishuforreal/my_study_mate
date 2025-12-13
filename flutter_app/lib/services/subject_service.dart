import 'api_service.dart';
import '../models/subject_model.dart';

class SubjectService {
  final ApiService _apiService = ApiService();

  Future<List<SubjectModel>> getSubjects({String? category, String? subcategory}) async {
    try {
      String url = '/subjects';
      List<String> params = [];
      
      if (category != null) params.add('category=$category');
      if (subcategory != null) params.add('subcategory=$subcategory');
      
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      final response = await _apiService.get(url);
      if (response['success']) {
        final List subjects = response['subjects'];
        return subjects.map((subject) => SubjectModel.fromJson(subject)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createSubject(String name, String category, String subcategory) async {
    try {
      await _apiService.post('/subjects', body: {
        'name': name,
        'category': category,
        'subcategory': subcategory,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateSubject(String subjectId, String name) async {
    try {
      await _apiService.put('/subjects/$subjectId', body: {
        'name': name,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteSubject(String subjectId) async {
    try {
      await _apiService.delete('/subjects/$subjectId');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getUnitsForSubject(String subjectName) async {
    try {
      final response = await _apiService.get('/admin/notes/units/$subjectName');
      if (response['success']) {
        return List<Map<String, dynamic>>.from(response['units']);
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getBooksForSubject(String subjectName) async {
    try {
      final response = await _apiService.get('/admin/books/units/$subjectName');
      if (response['success']) {
        return List<Map<String, dynamic>>.from(response['units']);
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getPPTsForSubject(String subjectName) async {
    try {
      final response = await _apiService.get('/admin/ppts/subjects/$subjectName');
      if (response['success']) {
        return List<Map<String, dynamic>>.from(response['ppts']);
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAssignmentsForSubject(String subjectName) async {
    try {
      final response = await _apiService.get('/admin/assignments/subjects/$subjectName');
      if (response['success']) {
        return List<Map<String, dynamic>>.from(response['assignments']);
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}