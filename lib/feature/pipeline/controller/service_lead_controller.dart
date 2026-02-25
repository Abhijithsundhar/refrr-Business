import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:refrr_admin/core/common/snackbar.dart';
import 'package:refrr_admin/feature/pipeline/repository/service_lead_repository.dart';
import 'package:refrr_admin/models/chatbox_model.dart';
import 'package:refrr_admin/models/salesperson_model.dart';
import 'package:refrr_admin/models/serviceLead_model.dart';

final serviceLeadsRepositoryProvider = Provider((ref) => ServiceLeadsRepository());
/// ✅ Provider to get service leads for specific affiliate and firm
final affiliateServiceLeadsProvider = StreamProvider.autoDispose
    .family<List<ServiceLeadModel>, ({String affiliateId, String firmId})>((ref, filter) {
  final repository = ref.watch(serviceLeadsRepositoryProvider);
  return repository.getServiceLeadsByAffiliateAndFirm(
    affiliateId: filter.affiliateId,
    firmId: filter.firmId,
  );
});

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

// ✅ Method for adding chat messages with optional updates
  Future<void> addChatMessageWithUpdate({
    required String serviceLeadId,
    required ChatModel message,
    required BuildContext context,
    String? leadType,
    Map<String, dynamic>? statusHistoryEntry,
  }) async {
    state = true;
    final result = await _repository.addChatMessageWithUpdate(
      serviceLeadId: serviceLeadId,
      message: message,
      leadType: leadType,
      statusHistoryEntry: statusHistoryEntry,
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
  // Add this to your ServiceLeadsController class
  Future<void> updateChatAtIndex({
    required String serviceLeadId,
    required List<ChatModel> currentChatList,
    required int index,
    required ChatModel updatedChat,
    required BuildContext context,
  }) async {
    state = true;

    // Create new list with updated chat at index
    final updatedChatList = List<ChatModel>.from(currentChatList);
    updatedChatList[index] = updatedChat;

    final result = await _repository.updateChatInArray(
      serviceLeadId: serviceLeadId,
      updatedChatList: updatedChatList,
    );

    state = false;
    result.fold(
          (l) => showCommonSnackbar(context, l.failure),
          (r) {}, // Silent success
    );
  }
}
