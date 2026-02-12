import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:refrr_admin/Core/constants/failure.dart';
import 'package:refrr_admin/Core/constants/firebaseConstants.dart';
import 'package:refrr_admin/Core/constants/typedef.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:refrr_admin/models/firm-model.dart';

final firmRepositoryProvider = Provider<FirmRepository>((ref) {
  return FirmRepository();
});

class FirmRepository {
  final _firestore = FirebaseFirestore.instance;

  /// ➕ Add Firm to Marketer (Subcollection)
  FutureEither<AddFirmModel> addFirm({
    required String leadId,
    required AddFirmModel firm,
  }) async {
    try {
      final ref = _firestore
          .collection(FirebaseCollections.leadsCollection)
          .doc(leadId)
          .collection(FirebaseCollections.addFirmCollection)
          .doc();

      final firmWithId = firm.copyWith(
        id: ref.id,
        reference: ref,
      );
      await ref.set(firmWithId.toMap());

      return right(firmWithId);
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  /// ✏️ Update Firm
  FutureVoid updateFirm({
    required String leadId,
    required AddFirmModel firm,
  }) async {
    try {
      return right(
        await _firestore
            .collection(FirebaseCollections.leadsCollection)
            .doc(leadId)
            .collection(FirebaseCollections.addFirmCollection)
            .doc(firm.id)
            .update(firm.toMap()),
      );
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  /// ❌ Soft Delete Firm
  FutureVoid deleteFirm({
    required String leadId,
    required String firmId,
  }) async {
    try {
      return right(
        await _firestore
            .collection(FirebaseCollections.leadsCollection)
            .doc(leadId)
            .collection(FirebaseCollections.addFirmCollection)
            .doc(firmId)
            .update({'delete': true,
        }),
      );
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  /// 📡 Get Firms Stream
  Stream<List<AddFirmModel>> getFirms(String leadId) {
    return _firestore
        .collection(FirebaseCollections.leadsCollection)
        .doc(leadId)
        .collection(FirebaseCollections.addFirmCollection)
        .where('delete', isEqualTo: false)
        .orderBy('createTime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(
            (doc) => AddFirmModel.fromMap(
          doc.data(),
          id: doc.id,
        ),
      )
          .toList(),
    );
  }

  /// 📡 Get All Firms Stream (Admin view)
  Stream<List<AddFirmModel>> getAllFirms() {
    return _firestore
        .collectionGroup(FirebaseCollections.addFirmCollection)
        .where('delete', isEqualTo: false)
        .orderBy('createTime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(
            (doc) => AddFirmModel.fromMap(
          doc.data(),
          id: doc.id,
        ),
      )
          .toList(),
    );
  }

  /// 📡 Get Firms by Status
  Stream<List<AddFirmModel>> getFirmsByStatus({
    required String leadId,
    required String status,
  }) {
    return _firestore
        .collection(FirebaseCollections.leadsCollection)
        .doc(leadId)
        .collection(FirebaseCollections.addFirmCollection)
        .where('delete', isEqualTo: false)
        .where('status', isEqualTo: status)
        .orderBy('createTime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(
            (doc) => AddFirmModel.fromMap(
          doc.data(),
          id: doc.id,
        ),
      )
          .toList(),
    );
  }

  /// 🔍 Search Firms
  Future<List<AddFirmModel>> searchFirms({
    required String leadId,
    required String searchTerm,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseCollections.leadsCollection)
          .doc(leadId)
          .collection(FirebaseCollections.addFirmCollection)
          .where('delete', isEqualTo: false)
          .where('search', arrayContains: searchTerm.toUpperCase())
          .get();

      return querySnapshot.docs
          .map((doc) => AddFirmModel.fromMap(
        doc.data(),
        id: doc.id,
      ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// 📊 Get Single Firm
  Future<AddFirmModel?> getFirmById({
    required String leadId,
    required String firmId,
  }) async {
    try {
      final doc = await _firestore
          .collection(FirebaseCollections.leadsCollection)
          .doc(leadId)
          .collection(FirebaseCollections.addFirmCollection)
          .doc(firmId)
          .get();

      if (doc.exists) {
        return AddFirmModel.fromMap(
          doc.data() as Map<String, dynamic>,
          id: doc.id,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// ✅ Update Firm Status
  FutureVoid updateFirmStatus({
    required String leadId,
    required String firmId,
    required String status,
  }) async {
    try {
      return right(
        await _firestore
            .collection(FirebaseCollections.leadsCollection)
            .doc(leadId)
            .collection(FirebaseCollections.addFirmCollection)
            .doc(firmId)
            .update({
          'status': status,
        }),
      );
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }
}