import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:refrr_admin/Core/common/snackbar.dart';
import 'package:refrr_admin/Feature/Login/Repository/lead-repository.dart';
import 'package:refrr_admin/Feature/Login/Screens/home.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Repository provider
final leadRepositoryProvider = Provider((ref) => LeadRepository());

/// Stream provider for listing/searching leads (unchanged)
final leadStreamProvider =
StreamProvider.family<List<LeadsModel>, String>((ref, searchQuery) {
  final repository = ref.watch(leadRepositoryProvider);
  return repository.getLead(searchQuery);
});

/// Holds the current logged-in lead in memory
final currentLeadProvider = StateProvider<LeadsModel?>((ref) => null);

/// Loading controller provider (bool = isLoading)
final leadControllerProvider =
StateNotifierProvider<LeadController, bool>((ref) {
  return LeadController(repository: ref.read(leadRepositoryProvider), ref: ref);
});

class LeadController extends StateNotifier<bool> {
  final LeadRepository _repository;
  final Ref _ref;

  LeadController({
    required LeadRepository repository,
    required Ref ref,
  })  : _repository = repository,
        _ref = ref,
        super(false);

  /// Login by email/password
  /// - persists uid
  /// - caches lead in memory
  /// - navigates to Home
  Future<void> loginLead({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    state = true;
    final res = await _repository.loginLead(email, password);
    state = false;

    res.fold(
          (failure) => showCommonSnackbar(context, failure.failure),
          (lead) async {
        try {
          // Persist uid from Firestore doc id (adjust if your model stores it differently)
          final uid = lead.reference?.id;
          if (uid != null && uid.isNotEmpty) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('uid', uid);
          } else {
            debugPrint('Warning: Lead.reference is null or has no id, uid not saved.');
          }

          // Cache in memory
          _ref.read(currentLeadProvider.notifier).state = lead;

          showCommonSnackbar(context, "Login successful");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen(lead: lead)),
          );
        } catch (e) {
          showCommonSnackbar(context, 'Login completed, but failed to persist uid.');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen(lead: lead)),
          );
        }
      },
    );
  }

  /// Add lead (unchanged behavior)
  Future<void> addLead({
    required LeadsModel leadModel,
    required BuildContext context,
  }) async {
    state = true;
    final res = await _repository.addLead(leadModel);
    state = false;

    res.fold(
          (failure) => showCommonSnackbar(context, failure.failure),
          (_) {
        showCommonSnackbar(context, "Lead added successfully");
        if (Navigator.of(context).canPop()) {
          Navigator.pop(context);
        }
      },
    );
  }

  /// Update lead in Firestore (unchanged behavior, but pop guarded)
  Future<void> updateLead({
    required LeadsModel leadModel,
    required BuildContext context,
  }) async {
    state = true;
    final res = await _repository.updateLead(leadModel);
    state = false;

    res.fold(
          (failure) => showCommonSnackbar(context, failure.failure),
          (_) {
        showCommonSnackbar(context, "Lead updated successfully");
        if (Navigator.of(context).canPop()) {
          Navigator.pop(context);
        }
      },
    );
  }

  /// Fetch a single lead by uid (Firestore doc id) and cache it in memory
  Future<LeadsModel?> getLead(String uid) async {
    if (uid.isEmpty) return null;

    try {
      final doc =
      await FirebaseFirestore.instance.collection('leads').doc(uid).get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      final lead = LeadsModel.fromMap({
        ...data,
        'reference': doc.reference, // include reference if your model expects it
      });

      _ref.read(currentLeadProvider.notifier).state = lead;
      return lead;
    } catch (e) {
      debugPrint('getLead error: $e');
      return null;
    }
  }

  /// ONLY update in-memory lead (no navigation, no network)
  void setCurrentLead(LeadsModel leadModel) {
    _ref.read(currentLeadProvider.notifier).state = leadModel;
  }

  /// Optional: logout helper
  Future<void> logout(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('uid');
    } catch (_) {}
    _ref.read(currentLeadProvider.notifier).state = null;
  }
}