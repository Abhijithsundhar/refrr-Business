import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:refrr_admin/Core/constants/firebaseConstants.dart';
import 'package:refrr_admin/models/chatbox-model.dart';
import 'package:refrr_admin/models/services-model.dart';

class ServiceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch all services from all leads
  Future<List<ServiceModel>> fetchAllServicesFromLeads() async {
    List<ServiceModel> allServices = [];

    final leadSnapshot = await _firestore.collection('leads').get();

    for (var lead in leadSnapshot.docs) {
      final data = lead.data();

      if (data['services'] != null && data['services'] is List) {
        for (final service in List.from(data['services'])) {
          allServices.add(ServiceModel.fromMap(service));
        }
      }
    }

    return allServices;
  }

  /// Add service to lead
  Future<void> addServiceToLead({
    required String leadId,
    required ServiceModel service,
  }) async {
    await _firestore.collection('leads').doc(leadId).update({
      "services": FieldValue.arrayUnion([service.toMap()])
    });
  }

  /// Delete service from lead
  Future<void> deleteServiceFromLead({
    required String leadId,
    required ServiceModel service,
  }) async {
    await _firestore.collection('leads').doc(leadId).update({
      "services": FieldValue.arrayRemove([service.toMap()])
    });
  }

  /// 🔥 Update service inside a lead (services array)
  Future<void> updateServiceInLead({
    required String leadId,
    required int serviceIndex,
    required ServiceModel updatedService,
  }) async {
    final ref = _firestore.collection('leads').doc(leadId);

    final doc = await ref.get();
    final data = doc.data()!;

    List services = List.from(data['services'] ?? []);

    if (serviceIndex < 0 || serviceIndex >= services.length) {
      throw Exception("Invalid service index");
    }

    // Replace the service at index
    services[serviceIndex] = updatedService.toMap();

    await ref.update({"services": services});
  }


}
