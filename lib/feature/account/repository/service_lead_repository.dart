import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:refrr_admin/core/constants/failure.dart';
import 'package:refrr_admin/core/constants/firebase_constants.dart';
import 'package:refrr_admin/core/constants/typedef.dart';
import 'package:refrr_admin/models/serviceLead_model.dart';


final serviceLeadRepositoryProvider = Provider<ServiceLeadRepository>((ref) {
  return ServiceLeadRepository();
});

class ServiceLeadRepository {
  /// add service lead
  FutureEither<ServiceLeadModel> addServiceLead(ServiceLeadModel serviceLead) async {
    try {
      DocumentReference ref = FirebaseFirestore.instance
          .collection(FirebaseCollections.serviceLeadsCollection)
          .doc();

      ServiceLeadModel serviceLeadModel = serviceLead.copyWith(reference: ref);
      await ref.set(serviceLeadModel.toMap());
      return right(serviceLeadModel);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  /// update service lead
  FutureVoid updateServiceLead(ServiceLeadModel serviceLead) async {
    try {
      return right(await serviceLead.reference!.update(serviceLead.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  /// service lead stream with search
  Stream<List<ServiceLeadModel>> getServiceLead(String searchQuery) {
    final collection =
    FirebaseFirestore.instance.collection(FirebaseCollections.serviceLeadsCollection);

    if (searchQuery.isEmpty) {
      return collection
          .orderBy('createTime', descending: true)
          .where('delete', isEqualTo: false)
          .snapshots()
          .map((snapshot) =>
          snapshot.docs.map((doc) => ServiceLeadModel.fromMap(doc.data())).toList());
    } else {
      return collection
          .where('delete', isEqualTo: false)
          .where('search', arrayContains: searchQuery.toUpperCase())
          .snapshots()
          .map((snapshot) =>
          snapshot.docs.map((doc) => ServiceLeadModel.fromMap(doc.data())).toList());
    }
  }
}
