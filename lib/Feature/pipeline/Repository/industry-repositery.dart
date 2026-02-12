import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:refrr_admin/Core/constants/failure.dart';
import 'package:refrr_admin/Core/constants/firebaseConstants.dart';
import 'package:refrr_admin/Core/constants/typedef.dart';
import 'package:refrr_admin/models/industry-model.dart';

/// Industry Repository Provider
final industryRepositoryProvider = Provider<IndustryRepository>((ref) {
  return IndustryRepository();
});

class IndustryRepository {
  /// ✅ Add Industry
  FutureEither<IndustryModel> addIndustry(IndustryModel industry) async {
    try {
      DocumentReference ref = FirebaseFirestore.instance
          .collection(FirebaseCollections.industriesCollection)
          .doc();

      IndustryModel newIndustry = industry.copyWith(reference: ref, id: ref.id);
      await ref.set(newIndustry.toMap());

      return right(newIndustry);
    } on FirebaseException catch (e) {
      return left(Failure(failure: e.message ?? 'Firebase error occurred'));
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  /// ✅ Update Industry
  FutureVoid updateIndustry(IndustryModel industry) async {
    try {
      return right(await industry.reference!.update(industry.toMap()));
    } on FirebaseException catch (e) {
      return left(Failure(failure: e.message ?? 'Firebase error occurred'));
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  /// ✅ Stream Industries
  Stream<List<IndustryModel>> getIndustry(String searchQuery) {
    final collection = FirebaseFirestore.instance
        .collection(FirebaseCollections.industriesCollection);

    return collection
        .where('delete', isEqualTo: false)
        // .orderBy('createTime', descending: true)
        .snapshots()
        .map((snapshot) {
      print('📦 Total industries in Firestore: ${snapshot.docs.length}');

      return snapshot.docs.map((doc) {
        print('📄 Industry doc ID: ${doc.id}, Data: ${doc.data()}');

        return IndustryModel.fromMap(
          doc.data(),
          id: doc.id,
          reference: doc.reference,
        );
      }).toList();
    });
  }
}