import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../Core/common/session-manager.dart';
import '../../../Model/leads-model.dart';
import '../../../core/common/snackbar.dart';
import '../Repository/lead-repository.dart';

final leadsRepositoryProvider = Provider<LeadsRepository>((ref) => LeadsRepository());

final leadsStreamProvider = StreamProvider.family<List<LeadsModel>, String>((ref, searchQuery) {
  final repository = ref.watch(leadsRepositoryProvider);
  return repository.getLeads(searchQuery);
});

final leadsControllerProvider = StateNotifierProvider<LeadsController, bool>((ref) {
  return LeadsController(repository: ref.read(leadsRepositoryProvider));
});

class LeadsController extends StateNotifier<bool> {
  final LeadsRepository _repository;

  LeadsController({required LeadsRepository repository})
      : _repository = repository,
        super(false);

  /// Login lead
  Future<void> loginLead({
    required BuildContext context,
    required String email,
    required String password,
    required VoidCallback onSuccess,
  }) async {
    state = true;

    print("👉 Trying login with: $email / $password");

    final result = await _repository.loginLead(email: email, password: password);

    state = false;

    result.fold(
          (failure) {
        print("❌ Login failed: ${failure.failure}");
        showCommonSnackbar(context, failure.failure);
      },
          (lead) async {
        print("✅ Lead found: ${lead.mail} | Status: ${lead.status}");

        if (lead.status == 0) {
          showCommonSnackbar(context, "You have no approval from super admin");
        } else {
          await SessionManager.saveLead(lead);
          print("✅ Login success, navigating to HomeScreen...");
          onSuccess();
        }
      },
    );
  }

  /// Add leads
  Future<void> addLeads({
    required LeadsModel leadsModel,
    required BuildContext context,
  }) async {
    state = true;
    var snap = await _repository.addLeads(leadsModel);
    state = false;
    snap.fold(
          (l) => showCommonSnackbar(context, l.failure),
          (r) {
        showCommonSnackbar(context, "Lead added successfully");
        Navigator.pop(context);
      },
    );
  }

  /// Update lead
  Future<void> updateLeads({
    required LeadsModel leadsModel,
    required BuildContext context,
  }) async {
    state = true;
    var snap = await _repository.updateLeads(leadsModel);
    state = false;
    snap.fold(
          (l) => showCommonSnackbar(context, l.failure),
          (r) {
        showCommonSnackbar(context, "Lead updated successfully");
        Navigator.pop(context);
      },
    );
  }

  /// Lead stream
  Stream<List<LeadsModel>> getLeads(String searchQuery) {
    return _repository.getLeads(searchQuery);
  }
}