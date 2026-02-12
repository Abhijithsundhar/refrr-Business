import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:refrr_admin/Core/common/snackbar.dart';
import 'package:refrr_admin/Core/constants/firebaseConstants.dart';
import 'package:refrr_admin/Feature/Team/repository/affiliate-repository.dart';
import 'package:refrr_admin/models/affiliate-model.dart';
import 'package:refrr_admin/models/balance-amount-model.dart';
import 'package:refrr_admin/models/total-credit-model.dart';

/// Affiliate Repository Provider
final affiliateRepositoryProvider = Provider((ref) => AffiliateRepository());

/// 🔹 Stream Provider for single affiliate by ID (Real-time updates)
final affiliateByIdStreamProvider = StreamProvider.family<AffiliateModel?, String>((ref, affiliateId) {
  final repository = ref.watch(affiliateRepositoryProvider);
  return repository.getAffiliateById(affiliateId);
});

/// Affiliate Stream Provider with search support
final affiliateStreamProvider = StreamProvider.family<List<AffiliateModel>, String>((ref, searchQuery) {
  final repository = ref.watch(affiliateRepositoryProvider);
  return repository.getAffiliate(searchQuery);
});

/// Affiliate by Marketer Provider
final affiliateByMarketerProvider = FutureProvider.family<AffiliateModel?, String>((ref, marketerId) async {
  final controller = ref.read(affiliateControllerProvider.notifier);
  return await controller.getAffiliateByMarketerId(marketerId);
});

/// 🔹 NEW: Team Members Provider - Fetches affiliates by IDs from teamMembers list
final teamProvider = StreamProvider.family<List<AffiliateModel>, String>((ref, leadId) async* {
  final firestore = FirebaseFirestore.instance;

  // Listen to lead document changes to get updated teamMembers
  final leadStream = firestore
      .collection(FirebaseCollections.leadsCollection)
      .doc(leadId)
      .snapshots();

  await for (final leadSnapshot in leadStream) {
    if (!leadSnapshot.exists) {
      debugPrint('⚠️ Lead document not found: $leadId');
      yield [];
      continue;
    }

    final leadData = leadSnapshot.data();
    final List<String> teamMemberIds = List<String>.from(leadData?['teamMembers'] ?? []);

    debugPrint('📋 Team Member IDs for lead $leadId: $teamMemberIds');

    if (teamMemberIds.isEmpty) {
      debugPrint('📋 No team members found');
      yield [];
      continue;
    }

    // Fetch affiliates by IDs
    try {
      final repository = ref.read(affiliateRepositoryProvider);
      final affiliates = await repository.getAffiliatesByIds(teamMemberIds);
      debugPrint('✅ Fetched ${affiliates.length} team members');
      yield affiliates;
    } catch (e) {
      debugPrint('❌ Error fetching team members: $e');
      yield [];
    }
  }
});

/// AffiliateController Provider
final affiliateControllerProvider = StateNotifierProvider<AffiliateController, bool>((ref) {
  return AffiliateController(repository: ref.read(affiliateRepositoryProvider));
});

class AffiliateController extends StateNotifier<bool> {
  final AffiliateRepository _repository;

  AffiliateController({required AffiliateRepository repository})
      : _repository = repository,
        super(false);

  /// Add affiliate
  Future<void> addAffiliate({
    required AffiliateModel affiliateModel,
    required BuildContext context,
  }) async {
    state = true;
    var snap = await _repository.addAffiliate(affiliateModel);
    state = false;
    snap.fold(
          (l) => showCommonSnackbar(context, l.failure),
          (r) {
        showCommonSnackbar(context, "Affiliate added successfully");
        Navigator.pop(context);
      },
    );
  }

  /// Update Affiliate
  Future<void> updateAffiliate({
    required AffiliateModel affiliateModel,
    required BuildContext context,
  }) async {
    state = true;
    var snap = await _repository.updateAffiliate(affiliateModel);
    state = false;
    snap.fold(
          (l) => showCommonSnackbar(context, l.failure),
          (r) {
        showCommonSnackbar(context, "Affiliate updated successfully");
        Navigator.pop(context);
      },
    );
  }

  /// Affiliate stream
  Stream<List<AffiliateModel>> getAffiliate(String searchQuery) {
    return _repository.getAffiliate(searchQuery);
  }

  /// Get Affiliate by Marketer ID
  Future<AffiliateModel?> getAffiliateByMarketerId(String marketerId) async {
    state = true;
    final result = await _repository.getAffiliateByMarketerId(marketerId);
    state = false;
    return result.fold(
          (l) => null,
          (affiliate) => affiliate,
    );
  }

  /// 🔹 Add Money to Affiliate (Appends to existing data, doesn't overwrite)
  Future<bool> addMoneyToAffiliate({
    required String affiliateId,
    required int amount,
    required TotalCreditModel newCreditEntry,
    required BalanceModel newBalanceEntry,
    required BuildContext context,
  }) async {
    try {
      state = true;

      debugPrint('💰 Controller: Adding money to affiliate: $affiliateId');

      final result = await _repository.addMoneyToAffiliate(
        affiliateId: affiliateId,
        amount: amount,
        newCreditEntry: newCreditEntry,
        newBalanceEntry: newBalanceEntry,
      );

      state = false;

      return result.fold(
            (failure) {
          debugPrint('❌ Controller Error: ${failure.failure}');
          showCommonSnackbar(context, failure.failure);
          return false;
        },
            (_) {
          debugPrint('✅ Controller: Money added successfully');
          return true;
        },
      );
    } catch (e) {
      state = false;
      debugPrint('❌ Controller Exception: $e');
      showCommonSnackbar(context, 'Error: ${e.toString()}');
      return false;
    }
  }
  /// 🔹 Hire multiple affiliates to a firm/lead
  Future<Map<String, dynamic>> hireAffiliates({
    required String leadId,
    required List<AffiliateModel> affiliates,
    required BuildContext context,
  }) async {
    if (leadId.isEmpty) {
      showCommonSnackbar(context, 'Invalid lead ID');
      return {'success': false, 'added': 0, 'skipped': 0};
    }

    if (affiliates.isEmpty) {
      showCommonSnackbar(context, 'No affiliates selected');
      return {'success': false, 'added': 0, 'skipped': 0};
    }

    state = true;

    try {
      debugPrint('🚀 Controller: Starting hire process...');
      debugPrint('📋 Lead ID: $leadId');
      debugPrint('👥 Affiliates to hire: ${affiliates.length}');

      // Extract affiliate IDs
      final List<String> affiliateIds = affiliates
          .map((a) => a.reference?.id ?? '')
          .where((id) => id.isNotEmpty)
          .toList();

      if (affiliateIds.isEmpty) {
        showCommonSnackbar(context, 'No valid affiliate IDs found');
        state = false;
        return {'success': false, 'added': 0, 'skipped': 0};
      }

      debugPrint('📋 Affiliate IDs: $affiliateIds');

      // Check for already hired affiliates
      final List<String> alreadyHired = await _repository.getAlreadyHiredAffiliates(
        leadId: leadId,
        affiliateIds: affiliateIds,
      );

      debugPrint('⚠️ Already hired: $alreadyHired');

      // Filter out already hired
      final List<String> newIdsToAdd = affiliateIds
          .where((id) => !alreadyHired.contains(id))
          .toList();

      if (newIdsToAdd.isEmpty) {
        showCommonSnackbar(context, 'All selected affiliates are already in your team');
        state = false;
        return {'success': false, 'added': 0, 'skipped': alreadyHired.length};
      }

      debugPrint('✅ New IDs to add: $newIdsToAdd');

      // Hire affiliates using repository
      final result = await _repository.hireAffiliates(
        leadId: leadId,
        affiliateIds: newIdsToAdd,
      );

      state = false;

      return result.fold(
            (failure) {
          debugPrint('❌ Controller Error: ${failure.failure}');
          showCommonSnackbar(context, 'Failed to hire: ${failure.failure}');
          return {'success': false, 'added': 0, 'skipped': alreadyHired.length};
        },
            (_) {
          debugPrint('🎉 Controller: Hire successful!');

          final int addedCount = newIdsToAdd.length;
          final int skippedCount = alreadyHired.length;

          String message = '$addedCount affiliate(s) added to your team';
          if (skippedCount > 0) {
            message += ' ($skippedCount already in team)';
          }

          showCommonSnackbar(context, message);

          return {
            'success': true,
            'added': addedCount,
            'skipped': skippedCount,
          };
        },
      );
    } catch (e) {
      state = false;
      debugPrint('❌ Controller Exception: $e');
      showCommonSnackbar(context, 'Error: ${e.toString()}');
      return {'success': false, 'added': 0, 'skipped': 0};
    }
  }

  /// 🔹 Remove affiliates from a firm/lead
  Future<bool> removeAffiliates({
    required String leadId,
    required List<String> affiliateIds,
    required BuildContext context,
  }) async {
    state = true;

    try {
      final result = await _repository.removeAffiliates(
        leadId: leadId,
        affiliateIds: affiliateIds,
      );

      state = false;

      return result.fold(
            (failure) {
          showCommonSnackbar(context, 'Failed to remove: ${failure.failure}');
          return false;
        },
            (_) {
          showCommonSnackbar(context, '${affiliateIds.length} affiliate(s) removed');
          return true;
        },
      );
    } catch (e) {
      state = false;
      showCommonSnackbar(context, 'Error: ${e.toString()}');
      return false;
    }
  }
}