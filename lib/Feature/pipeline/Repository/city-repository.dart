import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:refrr_admin/Core/constants/failure.dart';
import 'package:refrr_admin/Core/constants/firebaseConstants.dart';
import 'package:refrr_admin/Core/constants/typedef.dart';
import 'package:refrr_admin/models/city-model.dart';

final cityRepositoryProvider = Provider<CityRepository>((ref) {
  return CityRepository();
});

class CityRepository {
  final _firestore = FirebaseFirestore.instance;
  /// ➕ Add City to Lead (Subcollection)
  FutureEither<CityModel> addCity({
    required String leadId,
    required CityModel city,
  }) async {
    try {
      final ref = _firestore
          .collection(FirebaseCollections.leadsCollection)
          .doc(leadId)
          .collection(FirebaseCollections.cityCollection)
          .doc();

      final cityWithId = city.copyWith(
        id: ref.id,
        reference: ref,
      );

      await ref.set(cityWithId.toMap());

      return right(cityWithId);
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  /// ✏️ Update City
  FutureVoid updateCity({
    required String leadId,
    required CityModel city,
  }) async {
    try {
      return right(
        await _firestore
            .collection(FirebaseCollections.leadsCollection)
            .doc(leadId)
            .collection(FirebaseCollections.cityCollection)
            .doc(city.id)
            .update(city.toMap()),
      );
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  /// ❌ Soft Delete City
  FutureVoid deleteCity({
    required String leadId,
    required String cityId,
  }) async {
    try {
      return right(
        await _firestore
            .collection(FirebaseCollections.leadsCollection)
            .doc(leadId)
            .collection(FirebaseCollections.cityCollection)
            .doc(cityId)
            .update({'isDeleted': true,
        }),
      );
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  /// 📡 Get Cities Stream
  Stream<List<CityModel>> getCities(String leadId) {
    return _firestore
        .collection(FirebaseCollections.leadsCollection)
        .doc(leadId)
        .collection(FirebaseCollections.cityCollection)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
          .map((doc) => CityModel.fromMap(
          doc.data(),
          id: doc.id,),
      ).toList(),
    );
  }
}
