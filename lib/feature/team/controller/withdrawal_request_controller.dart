

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:refrr_admin/feature/team/repository/withdrawal_request_repository.dart';
import 'package:refrr_admin/models/withdrewrequst_model.dart';

class WithdrawalRequestFilter {
  final String affiliateId;
  final bool isFirmRequest;
  final int? statusFilter;

  const WithdrawalRequestFilter({
    required this.affiliateId,
    required this.isFirmRequest,
    this.statusFilter,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is WithdrawalRequestFilter &&
              runtimeType == other.runtimeType &&
              affiliateId == other.affiliateId &&
              isFirmRequest == other.isFirmRequest &&
              statusFilter == other.statusFilter;

  @override
  int get hashCode =>
      affiliateId.hashCode ^ isFirmRequest.hashCode ^ statusFilter.hashCode;
}

final withdrawalRequestsProvider = AutoDisposeFutureProvider.family<
    List<WithdrewrequstModel>, WithdrawalRequestFilter>((ref, filter) async {
  return ref.read(walletRepositoryProvider).fetchWithdrawalRequests(
    affiliateId: filter.affiliateId,
    isFirmRequest: filter.isFirmRequest,
    statusFilter: filter.statusFilter,
  );
});

final walletMutationsProvider =
AutoDisposeNotifierProvider<WalletMutations, bool>(
      () => WalletMutations(),
);

class WalletMutations extends AutoDisposeNotifier<bool> {
  @override
  bool build() => false;

  Future<bool> submitWithdrawalRequest(
      WithdrewrequstModel model, String affiliateId) async {
    state = true;
    final result =
    await ref.read(walletRepositoryProvider).addWithdrawalRequest(
      model: model,
    );

    state = false;

    final success = result.fold((l) => false, (_) => true);
    if (success) {
      ref.invalidate(withdrawalRequestsProvider(
        WithdrawalRequestFilter(
          affiliateId: affiliateId,
          isFirmRequest: model.leadId.isNotEmpty,
        ),
      ));
    }
    return success;
  }

  /// Status: 0 = Pending, 1 = Approved, 2 = Rejected
  Future<bool> updateWithdrawalRequest({
    required WithdrewrequstModel request,
    required int newStatus,
    required String affiliateId,
  }) async {
    state = true;

    final updatedRequest = request.copyWith(status: newStatus);
    final result = await ref
        .read(walletRepositoryProvider)
        .updateWithdrawalRequest(updatedRequest);

    state = false;

    final success = result.fold((l) => false, (_) => true);
    if (success) {
      ref.invalidate(withdrawalRequestsProvider(
        WithdrawalRequestFilter(
          affiliateId: affiliateId,
          isFirmRequest: request.leadId.isNotEmpty,
        ),
      ));
    }

    return success;
  }

  Future<bool> rejectWithdrawalRequest({
    required WithdrewrequstModel request,
    required String affiliateId,
  }) {
    return updateWithdrawalRequest(
      request: request,
      newStatus: 2,
      affiliateId: affiliateId,
    );
  }

  // ✅ Accept withdrawal request + Update affiliate balances + Add to lists
  Future<bool> acceptWithdrawalRequest({
    required WithdrewrequstModel request,
    required String affiliateId,
    required String currency,
  }) async {
    state = true;

    final result = await ref
        .read(walletRepositoryProvider)
        .acceptWithdrawalAndUpdateBalance(
      request: request,
      affiliateId: affiliateId,
      currency: currency,
    );

    state = false;

    final success = result.fold((l) => false, (_) => true);
    if (success) {
      ref.invalidate(withdrawalRequestsProvider(
        WithdrawalRequestFilter(
          affiliateId: affiliateId,
          isFirmRequest: request.leadId.isNotEmpty,
        ),
      ));
    }

    return success;
  }
}
