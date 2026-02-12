import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:refrr_admin/Core/constants/failure.dart';
import 'package:refrr_admin/Core/constants/firebaseConstants.dart';
import 'package:refrr_admin/Core/constants/typedef.dart';
import 'package:refrr_admin/models/creative-model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final creativeRepositoryProvider = Provider<CreativeRepository>((ref) {
  return CreativeRepository();
});

class CreativeRepository {
  final _firestore = FirebaseFirestore.instance;

  /// ➕ Add Creative to Lead (Subcollection)
  FutureEither<CreativeModel> addCreative({
    required String leadId,
    required CreativeModel creative,
  }) async {
    try {
      final ref = _firestore
          .collection(FirebaseCollections.leadsCollection)
          .doc(leadId)
          .collection('creatives')
          .doc();

      final creativeWithId = creative.copyWith(
        id: ref.id,
        reference: ref,
      );
      await ref.set(creativeWithId.toMap());

      return right(creativeWithId);
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  /// ✏️ Update Creative
  FutureVoid updateCreative({
    required String leadId,
    required CreativeModel creative,
  }) async {
    try {
      return right(
        await _firestore
            .collection(FirebaseCollections.leadsCollection)
            .doc(leadId)
            .collection('creatives')
            .doc(creative.id)
            .update(creative.toMap()),
      );
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  /// ❌ Soft Delete Creative
  FutureVoid deleteCreative({
    required String leadId,
    required String creativeId,
  }) async {
    try {
      return right(
        await _firestore
            .collection(FirebaseCollections.leadsCollection)
            .doc(leadId)
            .collection('creatives')
            .doc(creativeId)
            .update({'delete': true,
        }),
      );
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  /// 📡 Get Creatives Stream
  Stream<List<CreativeModel>> getCreatives(String leadId) {
    return _firestore
        .collection(FirebaseCollections.leadsCollection)
        .doc(leadId)
        .collection(FirebaseCollections.creativesCollection)
        .where('delete', isEqualTo: false)
        .orderBy('createTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
          .map((doc) => CreativeModel.fromMap(
          doc.data(), id: doc.id,
        ),
      )
          .toList(),
    );
  }
}
