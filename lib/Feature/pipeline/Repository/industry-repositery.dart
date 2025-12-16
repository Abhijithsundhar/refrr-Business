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
      throw e.message!;
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  /// ✅ Update Industry
  FutureVoid updateIndustry(IndustryModel industry) async {
    try {
      return right(await industry.reference!.update(industry.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  /// ✅ Stream Industries with optional search
  Stream<List<IndustryModel>> getIndustry(String searchQuery) {
    final collection =
    FirebaseFirestore.instance.collection(FirebaseCollections.industriesCollection);

    if (searchQuery.isEmpty) {
      return collection
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) => IndustryModel.fromMap(doc.data()))
          .toList());
    } else {
      return collection
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) => IndustryModel.fromMap(doc.data()))
          .toList());
    }
  }
}