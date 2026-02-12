import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:refrr_admin/Core/constants/failure.dart';
import 'package:refrr_admin/Core/constants/firebaseConstants.dart';
import 'package:refrr_admin/Core/constants/typedef.dart';
import 'package:refrr_admin/models/balance-amount-model.dart';
import 'package:refrr_admin/models/firm-model.dart';
import 'package:refrr_admin/models/total-withdrawal-model.dart';
import 'package:refrr_admin/models/withdrew-requst-model.dart';

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository();
});

class WalletRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FutureEither<AddFirmModel?> getFirmById({required String firmId}) async {
    try {
      final doc = await _firestore
          .collection(FirebaseCollections.leadsCollection)
          .doc(firmId)
          .get();

      if (!doc.exists || doc.data() == null) {
        return left(Failure(failure: 'Firm not found'));
      }

      return right(AddFirmModel.fromMap(doc.data()!));
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  FutureEither<bool> addWithdrawalRequest({
    required WithdrewrequstModel model,
  }) async {
    try {
      final ref = _firestore
          .collection('affiliates')
          .doc(model.affiliateId)
          .collection('withdrawalRequests')
          .doc();

      final modelWithId = model.copyWith(id: ref.id);
      await ref.set(modelWithId.toMap(), SetOptions(merge: true));

      return right(true);
    } on FirebaseException catch (e) {
      return left(Failure(failure: '${e.code}: ${e.message}'));
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  Future<List<WithdrewrequstModel>> fetchWithdrawalRequests({
    required String affiliateId,
    required bool isFirmRequest,
    int? statusFilter,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('affiliates')
          .doc(affiliateId)
          .collection('withdrawalRequests')
          .orderBy('requstTime', descending: true);

      if (statusFilter != null) {
        query = query.where('status', isEqualTo: statusFilter);
      }

      final snapshot = await query.get();

      final requests = snapshot.docs
          .map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return WithdrewrequstModel.fromMap(data);
      })
          .where((model) =>
      isFirmRequest ? model.leadId.isNotEmpty : model.leadId.isEmpty)
          .toList();

      print("✅ Found ${requests.length} requests with status: $statusFilter");
      return requests;
    } on FirebaseException catch (e) {
      print("🔥 FIRESTORE ERROR: ${e.code} - ${e.message}");
      throw Failure(failure: '${e.code}: ${e.message}');
    }
  }

  Future<Either<dynamic, void>> updateWithdrawalRequest(
      WithdrewrequstModel model) async {
    try {
      if (model.id == null || model.id!.isEmpty) {
        return left(Failure(failure: 'Document id is null'));
      }

      return right(
        await _firestore
            .collection('affiliates')
            .doc(model.affiliateId)
            .collection('withdrawalRequests')
            .doc(model.id)
            .update(model.toMap()),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  // ✅ Accept withdrawal and update ALL affiliate fields
  Future<Either<dynamic, bool>> acceptWithdrawalAndUpdateBalance({
    required WithdrewrequstModel request,
    required String affiliateId,
    required String currency,
  }) async {
    try {
      if (request.id == null || request.id!.isEmpty) {
        return left(Failure(failure: 'Request ID is required'));
      }

      if (affiliateId.isEmpty) {
        return left(Failure(failure: 'Affiliate ID is required'));
      }

      // ✅ Use batch write for atomic operation
      final batch = _firestore.batch();

      // 1️⃣ Update withdrawal request with all fields
      final requestRef = _firestore
          .collection('affiliates')
          .doc(affiliateId)
          .collection('withdrawalRequests')
          .doc(request.id);

      batch.update(requestRef, {
        'status': 1,
        'acceptedBy': request.acceptedBy,
        'acceptedTime':DateTime.now(),
      });

      // 2️⃣ Update affiliate document
      final affiliateRef = _firestore
          .collection(FirebaseCollections.affiliatesCollection)
          .doc(affiliateId);

      // Create new balance entry
      final newBalanceEntry = BalanceModel(
        amount: double.parse((request.amount).toString()), // Negative for withdrawal
        addedTime: DateTime.now(),
        acceptBy: request.acceptedBy,
        currency: currency,
      );

      // Create new withdrawal entry
      final newWithdrawalEntry = TotalWithdrawalsModel(
        amount: double.parse(request.amount.toString()),
        addedTime: DateTime.now(),
        acceptBy: request.acceptedBy,
        currency: currency,
        status: 1,
        description: '',
        image: ''
      );

      batch.update(affiliateRef, {
        // Update total amounts
        'totalBalance': FieldValue.increment(-request.amount),
        'totalWithrew': FieldValue.increment(request.amount),

        // ✅ Add to balance list - Convert to Map!
        'balance': FieldValue.arrayUnion([newBalanceEntry.toMap()]),

        // ✅ Add to withdrawals list - Convert to Map!
        'totalWithdrawals': FieldValue.arrayUnion([newWithdrawalEntry.toMap()]),
      });

      // ✅ Commit batch
      await batch.commit();

      log('✅ Withdrawal accepted and all fields updated');
      log('   - Amount: ${request.amount}');
      log('   - Affiliate: $affiliateId');
      log('   - AcceptedBy: ${request.acceptedBy}');

      return right(true);
    } on FirebaseException catch (e) {
      log('🔥 FIRESTORE ERROR: ${e.code} - ${e.message}');
      return left(Failure(failure: '${e.code}: ${e.message}'));
    } catch (e) {
      log('❌ Error accepting withdrawal: $e');
      return left(Failure(failure: e.toString()));
    }
  }
}
