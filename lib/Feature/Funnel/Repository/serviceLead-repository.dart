import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import '../../../Model/serviceLeadModel.dart';
import '../../../core/constants/failure.dart';
import '../../../core/constants/firebaseConstants.dart';

final serviceLeadsRepositoryProvider = Provider<ServiceLeadsRepository>((ref) {
  return ServiceLeadsRepository();
});

class ServiceLeadsRepository {
  Future<Either<Failure, ServiceLeadModel>> addServiceLeads(ServiceLeadModel serviceLeads) async {
    try {
      final ref = FirebaseFirestore.instance.collection(FirebaseCollections.ServiceLeadsCollection).doc();
      final modelWithRef = serviceLeads.copyWith(reference: ref);
      await ref.set(modelWithRef.toMap());
      return right(modelWithRef);
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  Future<Either<Failure, void>> updateServiceLeads(ServiceLeadModel serviceLeads) async {
    try {
      await serviceLeads.reference!.update(serviceLeads.toMap());
      return right(null);
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  Stream<List<ServiceLeadModel>> getServiceLeads(String searchQuery) {
    final collection = FirebaseFirestore.instance.collection(FirebaseCollections.ServiceLeadsCollection);
    if (searchQuery.isEmpty) {
      return collection
          .orderBy('createTime', descending: true)
          .snapshots()
          .map((snapshot) =>
          snapshot.docs.map((doc) => ServiceLeadModel.fromMap(doc.data())).toList());
    } else {
      return collection
          .where('search', arrayContains: searchQuery.toUpperCase())
          .snapshots()
          .map((snapshot) =>
          snapshot.docs.map((doc) => ServiceLeadModel.fromMap(doc.data())).toList());
    }
  }
}