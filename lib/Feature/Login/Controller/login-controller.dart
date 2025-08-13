import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../Core/common/snackbar.dart';
import '../../../Model/admin-model.dart';
import '../Repository/login-repository.dart';

final adminRepositoryProvider = Provider((ref) => AdminRepository());

/// Admin Stream Provider with search support
final adminStreamProvider = StreamProvider.family<List<AdminModel>, String>((ref, searchQuery) {
  final repository = ref.watch(adminRepositoryProvider);
  return repository.getAdmin(searchQuery);
});

/// AdminController Provider
final adminControllerProvider = StateNotifierProvider<AdminController, bool>((ref) {
  return AdminController(repository: ref.read(adminRepositoryProvider));
});

class AdminController extends StateNotifier<bool> {
  final AdminRepository _repository;

  AdminController({required AdminRepository repository})
      : _repository = repository,
        super(false);

  /// Add admin
  Future<void> addAdmin({
    required AdminModel adminModel,
    required BuildContext context,
  }) async {
    state = true;
    var snap = await _repository.addAdmin(adminModel);
    state = false;
    snap.fold(
          (l) => showCommonSnackbar(context, l.failure),
          (r) {
        showCommonSnackbar(context, "Admin added successfully");
        Navigator.pop(context);
      },
    );
  }

  /// Update admin
  Future<void> updateAdmin({
    required AdminModel adminModel,
    required BuildContext context,
  }) async {
    state = true;
    var snap = await _repository.updateAdmin(adminModel);
    state = false;
    snap.fold(
          (l) => showCommonSnackbar(context, l.failure),
          (r) {
        showCommonSnackbar(context, "Admin updated successfully");
        Navigator.pop(context);
      },
    );
  }

  /// Admin stream
  Stream<List<AdminModel>> getAdmin(String searchQuery) {
    return _repository.getAdmin(searchQuery);
  }
}
