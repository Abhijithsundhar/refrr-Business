import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../Model/serviceLeadModel.dart';
import '../repository/serviceLead-repository.dart';
import '../../../core/common/snackbar.dart';

final serviceLeadsRepositoryProvider = Provider((ref) => ServiceLeadsRepository());

final serviceLeadsControllerProvider = StateNotifierProvider<ServiceLeadsController, bool>((ref) {
  return ServiceLeadsController(repository: ref.read(serviceLeadsRepositoryProvider));
});
final serviceLeadsStreamProvider = StreamProvider.autoDispose<List<ServiceLeadModel>>((ref) {
  final controller = ref.watch(serviceLeadsControllerProvider.notifier);
  return controller.getServiceLeads(""); // "" = all records
});
class ServiceLeadsController extends StateNotifier<bool> {
  final ServiceLeadsRepository _repository;

  ServiceLeadsController({required ServiceLeadsRepository repository})
      : _repository = repository,
        super(false);

  Future<void> addServiceLeads({
    required ServiceLeadModel serviceLeadsModel,
    required BuildContext context,
  }) async {
    state = true;
    final result = await _repository.addServiceLeads(serviceLeadsModel);
    state = false;
    result.fold(
          (l) => showCommonSnackbar(context, l.failure),
          (r) {
        showCommonSnackbar(context, "Service Lead added successfully");
        Navigator.pop(context);
      },
    );
  }

  Future<void> updateServiceLeads({
    required ServiceLeadModel serviceLeadsModel,
    required BuildContext context,
  }) async {
    state = true;
    final result = await _repository.updateServiceLeads(serviceLeadsModel);
    state = false;
    result.fold(
          (l) => showCommonSnackbar(context, l.failure),
          (r) {
        showCommonSnackbar(context, "Service Lead updated successfully");
        Navigator.pop(context);
      },
    );
  }

  Stream<List<ServiceLeadModel>> getServiceLeads(String searchQuery) {
    return _repository.getServiceLeads(searchQuery);
  }
}