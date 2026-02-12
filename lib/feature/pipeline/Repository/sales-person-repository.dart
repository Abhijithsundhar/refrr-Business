import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:refrr_admin/Core/constants/failure.dart';
import 'package:refrr_admin/Core/constants/firebaseConstants.dart';
import 'package:refrr_admin/Core/constants/typedef.dart';
import 'package:refrr_admin/models/sales-person-model.dart';
import 'package:riverpod/riverpod.dart';


final industryRepositoryProvider = Provider<SalesPersonRepository>((ref) {
  return SalesPersonRepository();
});

class SalesPersonRepository {

  /// ✅ Add Sales Person
  FutureEither<SalesPersonModel?> addSalesPerson(SalesPersonModel person) async {
    try {
      DocumentReference ref = FirebaseFirestore.instance
          .collection(FirebaseCollections.salesPersonsCollection)
          .doc();

      SalesPersonModel newPerson = person.copyWith(reference: ref,leadHandlerId: ref.id);
      await ref.set(newPerson.toMap());
      await ref.update({'leadHandlerId': ref.id,});

      return right(newPerson);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  /// ✅ Update Sales Person
  Future<Either<dynamic, void>> updateSalesPerson(SalesPersonModel person) async {
    try {
      return right(await person.reference!.update(person.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  /// ✅ Stream All Sales Persons (with optional search)
  Stream<List<SalesPersonModel>> getSalesPersons(String searchQuery) {
    final collection = FirebaseFirestore.instance
        .collection(FirebaseCollections.salesPersonsCollection);

    return collection.snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) {
        return SalesPersonModel.fromMap(doc.data());
      }).toList();

      // If searchQuery is empty, show all
      if (searchQuery.isEmpty) return list;

      // Filter by name or phone number
      return list.where((person) {
        final q = searchQuery.toLowerCase();
        return person.name.toLowerCase().contains(q) ||
            person.phoneNumber.toLowerCase().contains(q);
      }).toList();
    });
  }
}
