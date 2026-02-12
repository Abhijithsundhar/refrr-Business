import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:refrr_admin/Core/constants/failure.dart';
import 'package:refrr_admin/Core/constants/firebaseConstants.dart';
import 'package:refrr_admin/Core/constants/typedef.dart';
import 'package:refrr_admin/models/affiliate-model.dart';
import 'package:refrr_admin/models/chatbox-model.dart';
import 'package:refrr_admin/models/lead-handler-model.dart';
import 'package:refrr_admin/models/sales-person-model.dart';
import 'package:refrr_admin/models/serviceLeadModel.dart';

final serviceLeadsRepositoryProvider = Provider<ServiceLeadsRepository>((ref) {
  return ServiceLeadsRepository();
});

class ServiceLeadsRepository {
  Future<Either<Failure, ServiceLeadModel>> addServiceLeads(ServiceLeadModel serviceLeads) async {
    try {
      final ref = FirebaseFirestore.instance.collection(FirebaseCollections.serviceLeadsCollection).doc();
      final modelWithRef = serviceLeads.copyWith(reference: ref);
      await ref.set(modelWithRef.toMap());
      return right(modelWithRef);
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  // ✅ FIXED: Now properly updates without overwriting
  FutureVoid updateServiceLeads(ServiceLeadModel updatedModel) async {
    try {
      final docRef = updatedModel.reference!;

      // Use set with merge to avoid overwriting
      await docRef.set(updatedModel.toMap(), SetOptions(merge: true));

      return right(null);
    } on FirebaseException catch (e) {
      return left(Failure(failure: e.message ?? 'Firebase error'));
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  // ✅ NEW: Add this method for adding chat messages safely
  FutureVoid addChatMessage({
    required String serviceLeadId,
    required ChatModel message,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection(FirebaseCollections.serviceLeadsCollection)
          .doc(serviceLeadId)
          .update({
        'chat': FieldValue.arrayUnion([message.toMap()]),
      });

      return right(null);
    } on FirebaseException catch (e) {
      return left(Failure(failure: e.message ?? 'Firebase error'));
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  // ✅ NEW: Add this method for updating lead handlers safely
  FutureVoid updateLeadHandlers({
    required String serviceLeadId,
    required List<SalesPersonModel> handlers,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection(FirebaseCollections.serviceLeadsCollection)
          .doc(serviceLeadId)
          .update({
        'leadHandler': handlers.map((h) => h.toMap()).toList(),
      });

      return right(null);
    } on FirebaseException catch (e) {
      return left(Failure(failure: e.message ?? 'Firebase error'));
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  Stream<List<ServiceLeadModel>> getServiceLeads(String searchQuery) {
    final collection = FirebaseFirestore.instance.collection(FirebaseCollections.serviceLeadsCollection);
    if (searchQuery.isEmpty) {
      return collection
          .orderBy('createTime', descending: true)
          .where('delete', isEqualTo: false)
          .snapshots()
          .map((snapshot) =>
          snapshot.docs.map((doc) => ServiceLeadModel.fromMap(doc.data())).toList());
    } else {
      return collection
          .where('search', arrayContains: searchQuery.toUpperCase())
          .where('delete', isEqualTo: false)
          .snapshots()
          .map((snapshot) =>
          snapshot.docs.map((doc) => ServiceLeadModel.fromMap(doc.data())).toList());
    }
  }

  Stream<List<ChatModel>> getChats(String serviceId) {
    return FirebaseFirestore.instance
        .collection(FirebaseCollections.serviceLeadsCollection)
        .doc(serviceId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return <ChatModel>[];

      final data = snapshot.data();
      if (data == null || data['chat'] == null) return <ChatModel>[];

      final List<ChatModel> chats = (data['chat'] as List)
          .map((e) => ChatModel.fromMap(Map<String, dynamic>.from(e)))
          .toList();

      return chats;
    });
  }

  Stream<List<SalesPersonModel>> getLeadHandler(String serviceId) {
    return FirebaseFirestore.instance
        .collection(FirebaseCollections.serviceLeadsCollection)
        .doc(serviceId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return <SalesPersonModel>[];

      final data = snapshot.data();
      if (data == null || data['leadHandler'] == null) return <SalesPersonModel>[];

      final List<SalesPersonModel> leadhandler = (data['leadHandler'] as List)
          .map((e) => SalesPersonModel.fromMap(Map<String, dynamic>.from(e)))
          .toList();

      return leadhandler;
    });
  }

  /// ✅ Get service leads for specific affiliate and firm
  Stream<List<ServiceLeadModel>> getServiceLeadsByAffiliateAndFirm({
    required String affiliateId,
    required String firmId,
  }) {
    return FirebaseFirestore.instance
        .collection('serviceLeads')
        .where('affiliateId', isEqualTo: affiliateId)
        .where('firmId', isEqualTo: firmId)
        .where('delete', isEqualTo: false)
        .orderBy('createTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ServiceLeadModel.fromMap(data);
      }).toList();
    });
  }
}