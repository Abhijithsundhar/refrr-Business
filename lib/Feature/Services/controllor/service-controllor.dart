import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:refrr_admin/Feature/Services/repository/service-repository.dart';
import 'package:refrr_admin/models/services-model.dart';


final serviceControllerProvider =
StateNotifierProvider<ServiceController, AsyncValue<List<ServiceModel>>>((ref) {
  return ServiceController(ref.read(serviceRepositoryProvider));
});

final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  return ServiceRepository();
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

  Future<void> addService({
    required String leadId,
    required int firmIndex,
    required String serviceId,
    required ServiceModel service,
    required BuildContext context,
  }) async {
    try {
      await _repository.addServiceToFirm(
        leadId: leadId,
        firmIndex: firmIndex,
        serviceId: serviceId,
        service: service,
      );
      fetchAll(); // refresh
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Service added")));
    } catch (e) {
      debugPrint('Error adding service: $e');
    }
  }

  Future<void> deleteService({
    required String leadId,
    required int firmIndex,
    required String serviceId,
    required BuildContext context,
  }) async {
    try {
      await _repository.deleteService(
        leadId: leadId,
        firmIndex: firmIndex,
        serviceId: serviceId,
      );
      fetchAll(); // refresh
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Service deleted")));
    } catch (e) {
      debugPrint('Error deleting service: $e');
    }
  }
}