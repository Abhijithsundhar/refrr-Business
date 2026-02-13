import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:refrr_admin/feature/website/repository/categoty_repository.dart';
import 'package:refrr_admin/models/category_model.dart';



/// Category repository Provider
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository();
});
final categoriesByIdsProvider =
FutureProvider.family<List<CategoryModel>, List<String>>((ref, ids) async {
  final repo = ref.read(categoryRepositoryProvider);
  return repo.fetchCategoriesByIds(ids);
});
/// StateNotifier Provider (handles loading state for add/update/delete)
final categoryControllerProvider =
StateNotifierProvider<CategoryController, bool>((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  return CategoryController(repo);
});

/// FutureProvider for loading category list (NO loading-state side effects)
/// Directly calls repository, not controller — avoids provider modification errors.
final categoriesFutureProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final repo = ref.read(categoryRepositoryProvider);
  return repo.fetchCategories('');
});

/// StateProvider for tracking a selected category
final selectedCategoryProvider = StateProvider<CategoryModel?>((ref) => null);

/// Category controller
class CategoryController extends StateNotifier<bool> {
  final CategoryRepository repository;

  CategoryController(this.repository) : super(false);

  /// Add Category
  Future<CategoryModel?> addCategory(CategoryModel category) async {
    state = true; // safe: triggered manually by user action, not during build
    try {
      final created = await repository.addCategory(category);
      return created;
    } catch (e) {
      rethrow;
    } finally {
      state = false;
    }
  }

  /// Fetch Categories (kept callable separately, though FutureProvider fetches directly)
  Future<List<CategoryModel>> fetchCategories() async {
    // do NOT toggle state here — causes provider modification during init
    try {
      return await repository.fetchCategories('');
    } catch (e) {
      rethrow;
    }
  }

  /// Update Category
  Future<void> updateCategory(CategoryModel category) async {
    state = true;
    try {
      await repository.updateCategory(category);
    } catch (e) {
      rethrow;
    } finally {
      state = false;
    }
  }

  /// Delete Category
  Future<void> deleteCategory(CategoryModel category) async {
    state = true;
    try {
      await repository.deleteCategory(category);
    } catch (e) {
      rethrow;
    } finally {
      state = false;
    }
  }
}
