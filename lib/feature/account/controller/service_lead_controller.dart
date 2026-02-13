
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:refrr_admin/core/common/snackbar.dart';
import 'package:refrr_admin/feature/account/repository/service_lead_repository.dart';
import 'package:refrr_admin/models/serviceLead_model.dart';


final serviceLeadRepositoryProvider = Provider((ref) => ServiceLeadRepository());

/// serviceLead Stream Provider with search support
final serviceLeadStreamProvider = StreamProvider.family<List<ServiceLeadModel>, String>((ref, searchQuery) {
  final repository = ref.watch(serviceLeadRepositoryProvider);

  return repository.getServiceLead(searchQuery);
});

/// ServiceLeadController Provider
final serviceLeadControllerProvider = StateNotifierProvider<ServiceLeadController, bool>((ref) {
  return ServiceLeadController(repository: ref.read(serviceLeadRepositoryProvider));
});

class ServiceLeadController extends StateNotifier<bool> {
  final ServiceLeadRepository _repository;

  ServiceLeadController({required ServiceLeadRepository repository})
      : _repository = repository,
        super(false);

  /// Add ServiceLead
  Future<void> addServiceLead({
    required ServiceLeadModel serviceLeadModel,
    required BuildContext context,
  }) async {
    state = true;
    var snap = await _repository.addServiceLead(serviceLeadModel);
    state = false;
    snap.fold(
          (l) => showCommonSnackbar(context, l.failure),
          (r) {
        showCommonSnackbar(context, "Service Lead added successfully");
        Navigator.pop(context);
      },
    );
  }

  /// Update ServiceLead
  Future<void> updateServiceLead({
    required ServiceLeadModel serviceLeadModel,
    required BuildContext context,
  }) async {
    state = true;
    var snap = await _repository.updateServiceLead(serviceLeadModel);
    state = false;
    snap.fold(
          (l) => showCommonSnackbar(context, l.failure),
          (r) {
        showCommonSnackbar(context, "Service Lead updated successfully");
        Navigator.pop(context);
      },
    );
  }

  /// ServiceLead stream
  Stream<List<ServiceLeadModel>> getServiceLead(String searchQuery) {
    return _repository.getServiceLead(searchQuery);
  }
}
