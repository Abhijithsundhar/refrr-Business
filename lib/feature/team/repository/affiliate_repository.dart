import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:refrr_admin/core/constants/failure.dart';
import 'package:refrr_admin/core/constants/firebase_constants.dart';
import 'package:refrr_admin/core/constants/typedef.dart';
import 'package:refrr_admin/models/affiliate_model.dart';
import 'package:refrr_admin/models/balanceamount_model.dart';
import 'package:refrr_admin/models/totalcredit_model.dart';


final affiliateRepositoryProvider = Provider<AffiliateRepository>((ref) {
  return AffiliateRepository();
});

class AffiliateRepository {
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Add affiliate
  FutureEither<AffiliateModel> addAffiliate(AffiliateModel affiliate) async {
    try {
      DocumentReference ref = _firestore
          .collection(FirebaseCollections.affiliatesCollection)
          .doc();
      print('11111111111111111111111111111111111111111111111111');
      print(ref);
      print('1111111111111111111111111111111111111111111111111');

      AffiliateModel affiliateModel = affiliate.copyWith(
        reference: ref,
      );
      await ref.set(affiliateModel.toMap());
      return right(affiliateModel);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  /// Update affiliate
  FutureVoid updateAffiliate(AffiliateModel affiliate) async {
    try {
      return right(await affiliate.reference!.update(affiliate.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  /// Affiliate stream with search
  Stream<List<AffiliateModel>> getAffiliate(String searchQuery) {
    final collection = _firestore.collection(FirebaseCollections.affiliatesCollection);

    if (searchQuery.isEmpty) {
      return collection
          .orderBy('createTime', descending: true)
          .where('delete', isEqualTo: false)
          .snapshots()
          .map((snapshot) =>
          snapshot.docs.map((doc) => AffiliateModel.fromMap(doc.data(), reference: doc.reference)).toList());
    } else {
      return collection
          .where('delete', isEqualTo: false)
          .where('search', arrayContains: searchQuery.toUpperCase())
          .snapshots()
          .map((snapshot) =>
          snapshot.docs.map((doc) => AffiliateModel.fromMap(doc.data(), reference: doc.reference)).toList());
    }
  }

  /// 🔹 Stream for single affiliate by ID (Real-time updates)
  Stream<AffiliateModel?> getAffiliateById(String affiliateId) {
    return _firestore
        .collection(FirebaseCollections.affiliatesCollection)
        .doc(affiliateId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        debugPrint('📡 Affiliate Stream Update: ${snapshot.data()}');
        return AffiliateModel.fromMap(snapshot.data()!, reference: snapshot.reference);
      }
      return null;
    });
  }

  /// 🔹 NEW: Get affiliates by list of IDs (for team members) - Handles ALL IDs
  Future<List<AffiliateModel>> getAffiliatesByIds(List<String> affiliateIds) async {
    if (affiliateIds.isEmpty) {
      return [];
    }

    List<AffiliateModel> allAffiliates = [];

    // Split into chunks of 10 (Firestore whereIn limit)
    for (int i = 0; i < affiliateIds.length; i += 10) {
      int end = (i + 10 < affiliateIds.length) ? i + 10 : affiliateIds.length;
      List<String> chunk = affiliateIds.sublist(i, end);

      debugPrint('📡 Fetching chunk ${i ~/ 10 + 1}: $chunk');

      final snapshot = await _firestore
          .collection(FirebaseCollections.affiliatesCollection)
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      final affiliates = snapshot.docs.map((doc) {
        return AffiliateModel.fromMap(doc.data(), reference: doc.reference);
      }).toList();

      allAffiliates.addAll(affiliates);
    }

    debugPrint('📡 Total affiliates fetched: ${allAffiliates.length}');
    return allAffiliates;
  }

  /// Fetch affiliate by marketerId
  FutureEither<AffiliateModel?> getAffiliateByMarketerId(String marketerId) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseCollections.affiliatesCollection)
          .where('id', isEqualTo: marketerId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        final affiliate = AffiliateModel.fromMap(data, reference: querySnapshot.docs.first.reference);
        return right(affiliate);
      } else {
        return right(null);
      }
    } on FirebaseException catch (e) {
      return left(Failure(failure: e.message ?? 'Firebase error'));
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  /// 🔹 Add Money to Affiliate (Uses Transaction to prevent overwriting)
  FutureEither<void> addMoneyToAffiliate({
    required String affiliateId,
    required int amount,
    required TotalCreditModel newCreditEntry,
    required BalanceModel newBalanceEntry,
  }) async {
    try {
      final affiliateRef = _firestore
          .collection(FirebaseCollections.affiliatesCollection)
          .doc(affiliateId);

      // Convert models to Maps for Firestore
      final Map<String, dynamic> creditEntryMap = newCreditEntry.toMap();
      final Map<String, dynamic> balanceEntryMap = newBalanceEntry.toMap();

      // Use Firestore Transaction to ensure atomic update with latest data
      await _firestore.runTransaction((transaction) async {
        // Step 1: Get the LATEST document from Firestore
        final docSnapshot = await transaction.get(affiliateRef);

        if (!docSnapshot.exists) {
          throw Exception('Affiliate document not found');
        }

        final currentData = docSnapshot.data() as Map<String, dynamic>;

        // Step 2: Get current totals from LATEST data
        final int currentTotalCredit = _parseToInt(currentData['totalCredit']);
        final int currentTotalBalance = _parseToInt(currentData['totalBalance']);

        // Step 3: Calculate new totals
        final int newTotalCredit = currentTotalCredit + amount;
        final int newTotalBalance = currentTotalBalance + amount;

        debugPrint('💰 Current Total Credit: $currentTotalCredit → New: $newTotalCredit');
        debugPrint('💰 Current Total Balance: $currentTotalBalance → New: $newTotalBalance');

        // Step 4: Update document using arrayUnion to APPEND new entries
        transaction.update(affiliateRef, {
          'totalCredit': newTotalCredit,
          'totalBalance': newTotalBalance,
          'totalCredits': FieldValue.arrayUnion([creditEntryMap]),
          'balance': FieldValue.arrayUnion([balanceEntryMap]),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      debugPrint('✅ repository: Money added successfully');
      return right(null);
    } on FirebaseException catch (e) {
      debugPrint('❌ repository Firebase Error: ${e.message}');
      return left(Failure(failure: e.message ?? 'Firebase error'));
    } catch (e) {
      debugPrint('❌ repository Error adding money: $e');
      return left(Failure(failure: e.toString()));
    }
  }

  /// Helper method to safely parse int
  int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// 🔹 Hire multiple affiliates to a firm/lead (Store IDs only)
  FutureEither<void> hireAffiliates({
    required String leadId,
    required List<String> affiliateIds,
  }) async {
    try {
      debugPrint('🚀 repository: Hiring ${affiliateIds.length} affiliates to lead $leadId');

      // Start a batch write for atomic operation
      final WriteBatch batch = _firestore.batch();

      // 1. Add affiliate IDs to lead's teamMembers using arrayUnion (IDs only!)
      final leadRef = _firestore
          .collection(FirebaseCollections.leadsCollection)
          .doc(leadId);

      batch.update(leadRef, {
        'teamMembers': FieldValue.arrayUnion(affiliateIds),
      });

      debugPrint('✅ repository: Added to batch - Lead teamMembers update');

      // 2. Add lead ID to each affiliate's workingFirms using arrayUnion
      for (final affiliateId in affiliateIds) {
        final affiliateRef = _firestore
            .collection(FirebaseCollections.affiliatesCollection)
            .doc(affiliateId);

        batch.update(affiliateRef, {
          'workingFirms': FieldValue.arrayUnion([leadId]),
        });

        debugPrint('✅ repository: Added to batch - Affiliate $affiliateId workingFirms update');
      }

      // 3. Commit the batch
      await batch.commit();

      debugPrint('🎉 repository: Batch committed successfully!');

      return right(null);
    } on FirebaseException catch (e) {
      debugPrint('❌ repository Firebase Error: ${e.message}');
      return left(Failure(failure: e.message ?? 'Firebase error occurred'));
    } catch (e) {
      debugPrint('❌ repository Error: $e');
      return left(Failure(failure: e.toString()));
    }
  }

  /// 🔹 Remove affiliates from a firm/lead
  FutureEither<void> removeAffiliates({
    required String leadId,
    required List<String> affiliateIds,
  }) async {
    try {
      debugPrint('🚀 repository: Removing ${affiliateIds.length} affiliates from lead $leadId');

      final WriteBatch batch = _firestore.batch();

      // 1. Remove affiliate IDs from lead's teamMembers
      final leadRef = _firestore
          .collection(FirebaseCollections.leadsCollection)
          .doc(leadId);

      batch.update(leadRef, {
        'teamMembers': FieldValue.arrayRemove(affiliateIds),
      });

      // 2. Remove lead ID from each affiliate's workingFirms
      for (final affiliateId in affiliateIds) {
        final affiliateRef = _firestore
            .collection(FirebaseCollections.affiliatesCollection)
            .doc(affiliateId);

        batch.update(affiliateRef, {
          'workingFirms': FieldValue.arrayRemove([leadId]),
        });
      }

      await batch.commit();

      debugPrint('🎉 repository: Affiliates removed successfully!');

      return right(null);
    } on FirebaseException catch (e) {
      debugPrint('❌ repository Firebase Error: ${e.message}');
      return left(Failure(failure: e.message ?? 'Firebase error occurred'));
    } catch (e) {
      debugPrint('❌ repository Error: $e');
      return left(Failure(failure: e.toString()));
    }
  }

  /// 🔹 Check if affiliates are already in team
  Future<List<String>> getAlreadyHiredAffiliates({
    required String leadId,
    required List<String> affiliateIds,
  }) async {
    try {
      final leadDoc = await _firestore
          .collection(FirebaseCollections.leadsCollection)
          .doc(leadId)
          .get();

      if (!leadDoc.exists) {
        return [];
      }

      final List<String> existingTeamIds = List<String>.from(
        leadDoc.data()?['teamMembers'] ?? [],
      );

      // Return IDs that are already in the team
      return affiliateIds.where((id) => existingTeamIds.contains(id)).toList();
    } catch (e) {
      debugPrint('❌ Error checking hired affiliates: $e');
      return [];
    }
  }
}
