import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:refrr_admin/Feature/Services/repository/service-repository.dart';
import 'package:refrr_admin/models/services-model.dart';

final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  return ServiceRepository();
});

final serviceControllerProvider =
StateNotifierProvider<ServiceController, AsyncValue<List<ServiceModel>>>((ref) {
  return ServiceController(ref.read(serviceRepositoryProvider));
});


class ServiceController extends StateNotifier<AsyncValue<List<ServiceModel>>> {
  final ServiceRepository _repository;

  ServiceController(this._repository) : super(const AsyncLoading()) {
    fetchAll();
  }

  Future<void> fetchAll() async {
    try {
      final data = await _repository.fetchAllServicesFromLeads();
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// ADD SERVICE
  Future<void> addService({
    required String leadId,
    required int firmIndex,
    required String serviceId,
    required ServiceModel service,
    required BuildContext context,
  }) async {
    try {
      await _repository.addServiceToLead(
        leadId: leadId,
        service: service,
      );

      fetchAll();

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Service added")));
    } catch (e) {
      debugPrint("Error adding service: $e");
    }
  }

  /// DELETE SERVICE
  Future<void> deleteService({
    required String leadId,
    required ServiceModel service,
    required BuildContext context,
  }) async {
    try {
      await _repository.deleteServiceFromLead(
        leadId: leadId,
        service: service,
      );

      fetchAll();

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Service deleted")));
    } catch (e) {
      debugPrint("Error deleting service: $e");
    }
  }

  /// 🔥 UPDATE SERVICE
  Future<void> updateService({
    required String leadId,
    required int serviceIndex,
    required ServiceModel updatedService,
    required BuildContext context,
  }) async {
    try {
      await _repository.updateServiceInLead(
        leadId: leadId,
        serviceIndex: serviceIndex,
        updatedService: updatedService,
      );

      fetchAll(); // refresh list

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Service updated")));
    } catch (e) {
      debugPrint("Error updating service: $e");
    }
  }

}
