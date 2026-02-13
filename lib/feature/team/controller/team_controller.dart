import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:refrr_admin/feature/team/repository/team_repository.dart';

/// repository Provider
final teamRepositoryProvider = Provider<TeamRepository>((ref) {
  return TeamRepository();
});

/// team controller Provider
final teamControllerProvider = StateNotifierProvider<TeamController, bool>((ref) {
  return TeamController(ref.read(teamRepositoryProvider));
});

class TeamController extends StateNotifier<bool> {
  final TeamRepository _repository;

  TeamController(this._repository) : super(false);

  /// 🔹 Remove Affiliate from team
  Future<bool> removeAffiliateFromTeam({
    required String firmId,
    required String affiliateId,
  }) async {
    state = true;
    try {
      await _repository.removeAffiliateFromTeam(
        firmId: firmId,
        affiliateId: affiliateId,
      );
      state = false;
      return true;
    } catch (e) {
      debugPrint('❌ controller Error: $e');
      state = false;
      return false;
    }
  }
}
