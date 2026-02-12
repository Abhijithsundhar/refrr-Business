import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:refrr_admin/Core/common/snackbar.dart';
import 'package:refrr_admin/Feature/pipeline/Repository/sales-person-repository.dart';
import 'package:refrr_admin/models/sales-person-model.dart';

final salesPersonControllerProvider = StateNotifierProvider<SalesPersonController, bool>((ref) {
  return SalesPersonController(repository: ref.read(salesPersonRepositoryProvider),);});

final salesPersonRepositoryProvider = Provider<SalesPersonRepository>((ref) {
  return SalesPersonRepository();
});


class SalesPersonController extends StateNotifier<bool> {
  final SalesPersonRepository _repository;

  SalesPersonController({required SalesPersonRepository repository}): _repository = repository, super(false);

  /// ✅ Add Sales Person
  Future<SalesPersonModel?> addSalesPerson({
    required SalesPersonModel salesPerson,
    required BuildContext context,
  }) async {
    state = true;

    final result = await _repository.addSalesPerson(salesPerson);

    state = false;

    return result.fold((l) {
        showCommonSnackbar(context, l.failure);
        return null;
      },(savedPerson) {
        showCommonSnackbar(context, "Sales person added successfully");
        return savedPerson;
      },
    );
  }

  /// ✅ Update Sales Person
  Future<void> updateSalesPerson({
    required SalesPersonModel salesPerson,
    required BuildContext context,
  }) async {
    state = true;

    final result = await _repository.updateSalesPerson(salesPerson);

    state = false;
    result.fold(
          (l) => showCommonSnackbar(context, l.failure),
          (r) {
        showCommonSnackbar(context, "Sales person updated successfully");
        Navigator.pop(context);
      },
    );
  }

  /// ✅ Stream Sales Persons with optional search
  Stream<List<SalesPersonModel>> getSalesPersons(String searchQuery) {
    return _repository.getSalesPersons(searchQuery);
  }
}
