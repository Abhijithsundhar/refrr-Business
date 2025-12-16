import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:refrr_admin/Core/common/snackbar.dart';
import 'package:refrr_admin/Feature/pipeline/Repository/serviceLead-repository.dart';
import 'package:refrr_admin/models/chatbox-model.dart';
import 'package:refrr_admin/models/sales-person-model.dart';
import 'package:refrr_admin/models/serviceLeadModel.dart';


final serviceLeadsRepositoryProvider = Provider((ref) => ServiceLeadsRepository());

final chatProvider = StreamProvider.family<List<ChatModel>, String>((ref, serviceId) {
  final repo = ref.watch(serviceLeadsRepositoryProvider);
  return repo.getChats(serviceId);
});
final leadhandlerProvider = StreamProvider.family<List<SalesPersonModel>, String>((ref, serviceId) {
  final repo = ref.watch(serviceLeadsRepositoryProvider);
  return repo.getLeadHandler(serviceId);
});

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
        // showCommonSnackbar(context, "Service Lead updated successfully");
      },
    );
  }

  // ✅ ADD: Method for adding chat messages
  Future<void> addChatMessage({
    required String serviceLeadId,
    required ChatModel message,
    required BuildContext context,
  }) async {
    state = true;
    final result = await _repository.addChatMessage(
      serviceLeadId: serviceLeadId,
      message: message,
    );
    state = false;
    result.fold(
          (l) => showCommonSnackbar(context, l.failure),
          (r) {}, // Silent success
    );
  }

  // ✅ ADD: Method for updating lead handlers
  Future<void> updateLeadHandlers({
    required String serviceLeadId,
    required List<SalesPersonModel> handlers,
    required BuildContext context,
  }) async {
    state = true;
    final result = await _repository.updateLeadHandlers(
      serviceLeadId: serviceLeadId,
      handlers: handlers,
    );
    state = false;
    result.fold(
          (l) => showCommonSnackbar(context, l.failure),
          (r) {}, // Silent success
    );
  }

  Stream<List<ServiceLeadModel>> getServiceLeads(String searchQuery) {
    return _repository.getServiceLeads(searchQuery);
  }
}