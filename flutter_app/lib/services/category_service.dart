import '../models/category_model.dart';
import 'api_service.dart';

class CategoryService {
  final ApiService _apiService = ApiService();

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _apiService.get('/categories');
      if (response['success']) {
        final List categories = response['categories'];
        return categories.map((category) => CategoryModel.fromJson(category)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createCategory(String name, String type) async {
    try {
      await _apiService.post('/categories', body: {
        'name': name,
        'type': type,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addSubcategory(String categoryId, String name) async {
    try {
      await _apiService.post('/categories/$categoryId/subcategories', body: {
        'name': name,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await _apiService.delete('/categories/$categoryId');
    } catch (e) {
      rethrow;
    }
  }
}