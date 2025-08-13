import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../Model/services-model.dart';

class ServiceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<ServiceModel>> fetchAllServicesFromLeads() async {
    List<ServiceModel> allServices = [];

    final leadSnapshot = await _firestore.collection('leads').get();
    for (var lead in leadSnapshot.docs) {
      final data = lead.data();

      if (data['firms'] != null && data['firms'] is List) {
        for (final firm in List.from(data['firms'])) {
          if (firm['services'] != null && firm['services'] is Map<String, dynamic>) {
            Map<String, dynamic> servicesMap = Map<String, dynamic>.from(firm['services']);
            for (final entry in servicesMap.entries) {
              allServices.add(ServiceModel.fromMap(entry.value));
            }
          }
        }
      }
    }

    return allServices;
  }

  Future<void> addServiceToFirm({
    required String leadId,
    required int firmIndex,
    required String serviceId,
    required ServiceModel service,
  }) async {
    final leadsRef = _firestore.collection('leads').doc(leadId);
    final leadDoc = await leadsRef.get();
    final data = leadDoc.data()!;
    final firms = List.from(data['firms']);

    final currentFirm = Map<String, dynamic>.from(firms[firmIndex]);
    final currentServices = Map<String, dynamic>.from(currentFirm['services'] ?? {});
    currentServices[serviceId] = service.toMap();

    currentFirm['services'] = currentServices;
    firms[firmIndex] = currentFirm;

    await leadsRef.update({'firms': firms});
  }

  Future<void> deleteService({
    required String leadId,
    required int firmIndex,
    required String serviceId,
  }) async {
    final leadsRef = _firestore.collection('leads').doc(leadId);
    final doc = await leadsRef.get();

    final data = doc.data()!;
    final firms = List.from(data['firms']);

    final firm = Map<String, dynamic>.from(firms[firmIndex]);
    final servicesMap = Map<String, dynamic>.from(firm['services'] ?? {});

    servicesMap.remove(serviceId);
    firm['services'] = servicesMap;
    firms[firmIndex] = firm;

    await leadsRef.update({'firms': firms});
  }
}