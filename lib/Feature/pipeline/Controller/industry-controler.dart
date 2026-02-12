import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:refrr_admin/Core/common/snackbar.dart';
import 'package:refrr_admin/Feature/pipeline/Repository/industry-repositery.dart';
import 'package:refrr_admin/models/industry-model.dart';

/// ✅ Industry Repository Provider
final industryRepositoryProvider = Provider((ref) => IndustryRepository());

final industryModelProvider = StateProvider<IndustryModel?>((ref) {
  return null;
});

final listOfServiceProvider = StateProvider<List<String>>((ref) {
  return [];
});

final serviceProvider = StateProvider<String>((ref) {
  return '';
});
final industrySearchProvider = StateProvider<String>((ref) => '');

/// ✅ Industry Stream Provider with search query
final industryStreamProvider =
StreamProvider.family<List<IndustryModel>, String>((ref, searchQuery) {
  final repository = ref.watch(industryRepositoryProvider);
  return repository.getIndustry(searchQuery);
});

/// ✅ Industry Controller Provider
final industryControllerProvider =
StateNotifierProvider<IndustryController, bool>((ref) {
  return IndustryController(repository: ref.read(industryRepositoryProvider));
});

/// ✅ Industry Controller
class IndustryController extends StateNotifier<bool> {
  final IndustryRepository _repository;

  IndustryController({required IndustryRepository repository})
      : _repository = repository,
        super(false);

  /// ✅ Add Industry
  Future<void> addIndustry({
    required IndustryModel industryModel,
    required BuildContext context,
  }) async {
    state = true;

    final result = await _repository.addIndustry(industryModel);

    state = false;
    result.fold(
          (l) => showCommonSnackbar(context, l.failure),
          (r) {
        showCommonSnackbar(context, "Industry added successfully");
        Navigator.pop(context);
      },
    );
  }

  /// ✅ Update Industry
  Future<void> updateIndustry({
    required IndustryModel industryModel,
    required BuildContext context,
  }) async {
    state = true;

    final result = await _repository.updateIndustry(industryModel);

    state = false;
    result.fold(
          (l) => showCommonSnackbar(context, l.failure),
          (r) {
        showCommonSnackbar(context, "Industry updated successfully");
        Navigator.pop(context);
      },
    );
  }

  /// ✅ Stream Industries
  Stream<List<IndustryModel>> getIndustry(String searchQuery) {
    return _repository.getIndustry(searchQuery);
  }
}