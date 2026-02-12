import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:refrr_admin/Core/constants/failure.dart';
import 'package:refrr_admin/Core/constants/firebaseConstants.dart';
import 'package:refrr_admin/Core/constants/typedef.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:refrr_admin/models/services-model.dart';

final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  return ServiceRepository();
});

class ServiceRepository {
  final _firestore = FirebaseFirestore.instance;

  /// ➕ Add Service to Lead (Subcollection)
  FutureEither<ServiceModel> addService({
    required String leadId,
    required ServiceModel service,
  }) async {
    try {
      final ref = _firestore
          .collection(FirebaseCollections.leadsCollection)
          .doc(leadId)
          .collection('services')
          .doc();

      final serviceWithId = service.copyWith(
        id: ref.id,
        reference: ref,
      );
      await ref.set(serviceWithId.toMap());

      return right(serviceWithId);
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  /// ✏️ Update Service
  FutureVoid updateService({
    required String leadId,
    required ServiceModel service,
  }) async {
    try {
      return right(
        await _firestore
            .collection(FirebaseCollections.leadsCollection)
            .doc(leadId)
            .collection(FirebaseCollections.servicesCollection)
            .doc(service.id)
            .update(service.toMap()),
      );
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  /// ❌ Soft Delete Service
  FutureVoid deleteService({
    required String leadId,
    required String serviceId,
  }) async {
    try {
      return right(
        await _firestore
            .collection(FirebaseCollections.leadsCollection)
            .doc(leadId)
            .collection('services')
            .doc(serviceId)
            .update({
          'delete': true,
        }),
      );
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  /// 📡 Get Services Stream
  Stream<List<ServiceModel>> getServices(String leadId) {
    return _firestore
        .collection(FirebaseCollections.leadsCollection)
        .doc(leadId)
        .collection(FirebaseCollections.servicesCollection)
        .where('delete', isEqualTo: false)
        .orderBy('createTime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(
            (doc) => ServiceModel.fromMap(
          doc.data(),
          id: doc.id,
        ),
      )
          .toList(),
    );
  }
}
