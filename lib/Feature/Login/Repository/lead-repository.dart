import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:refrr_admin/Core/constants/failure.dart';
import 'package:refrr_admin/Core/constants/firebaseConstants.dart';
import 'package:refrr_admin/Core/constants/typedef.dart';
import 'package:refrr_admin/models/leads_model.dart';


final leadRepositoryProvider = Provider<LeadRepository>((ref) {
  return LeadRepository();
});

class LeadRepository {
  // lead-repository.dart
///login
  FutureEither<LeadsModel> loginLead(String email, String password) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection(FirebaseCollections.leadsCollection)
          .where('mail', isEqualTo: email)
          .where('password', isEqualTo: password)
          .where('delete', isEqualTo: false) // Optional condition
          .get();

      if (querySnapshot.docs.isEmpty) {
        return left( Failure(failure: "Email not found"));
      }

      final leadData = querySnapshot.docs.first.data();
      final lead = LeadsModel.fromMap(leadData);

      if (lead.password != password) {
        return left( Failure(failure: "Incorrect password"));
      }

      return right(lead);
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }
  /// Add lead
  FutureEither<LeadsModel> addLead(LeadsModel lead) async {
    try {
      DocumentReference ref = FirebaseFirestore.instance
          .collection(FirebaseCollections.leadsCollection)
          .doc();

      print('11111111111111111111111111111111111111111111111111');
      print(ref);
      print('1111111111111111111111111111111111111111111111111');

      LeadsModel leadModel = lead.copyWith(reference: ref);
      await ref.set(leadModel.toMap());
      return right(leadModel);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  /// Update lead
  FutureVoid updateLead(LeadsModel lead) async {
    try {
      return right(await lead.reference!.update(lead.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  /// Lead stream with search
  Stream<List<LeadsModel>> getLead(String searchQuery) {
    final collection =
    FirebaseFirestore.instance.collection(FirebaseCollections.leadsCollection);

    if (searchQuery.isEmpty) {
      return collection
          .orderBy('createTime', descending: true)
          .where('delete', isEqualTo: false)
          .snapshots()
          .map((snapshot) =>
          snapshot.docs.map((doc) => LeadsModel.fromMap(doc.data())).toList());
    } else {
      return collection
          .where('delete', isEqualTo: false)
          .where('search', arrayContains: searchQuery.toUpperCase())
          .snapshots()
          .map((snapshot) =>
          snapshot.docs.map((doc) => LeadsModel.fromMap(doc.data())).toList());
    }
  }
}
