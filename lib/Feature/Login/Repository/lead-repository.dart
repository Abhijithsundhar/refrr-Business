
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import '../../../Model/leads-model.dart';
import '../../../core/constants/failure.dart';
import '../../../core/constants/firebaseConstants.dart';
import '../../../core/constants/typedef.dart';

final leadsRepositoryProvider = Provider<LeadsRepository>((ref) {return LeadsRepository();});

class LeadsRepository {
  /// Add leads
  FutureEither<LeadsModel> addLeads(LeadsModel leads) async {
    try {
      DocumentReference ref = FirebaseFirestore.instance
          .collection(FirebaseCollections.leadsCollection)
          .doc();
      LeadsModel leadsModel = leads.copyWith(reference: ref);
      await ref.set(leadsModel.toMap());
      return right(leadsModel);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  /// Update leads
  FutureVoid updateLeads(LeadsModel leads) async {
    try {
      return right(await leads.reference!.update(leads.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  /// Leads stream with search
  Stream<List<LeadsModel>> getLeads(String searchQuery) {
    final collection = FirebaseFirestore.instance.collection(FirebaseCollections.leadsCollection);

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

  /// Login lead (add this method!)
  Future<Either<Failure, LeadsModel>> loginLead({
    required String email,
    required String password,
  }) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection(FirebaseCollections.leadsCollection)
          .where('mail', isEqualTo: email)
          .where('password', isEqualTo: password)
          .where('delete', isEqualTo: false)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return left(Failure(failure: "Invalid email or password"));
      }

      final lead = LeadsModel.fromMap(query.docs.first.data());
      return right(lead);
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }
}