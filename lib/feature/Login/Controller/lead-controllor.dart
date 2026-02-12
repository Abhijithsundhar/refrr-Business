import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/snackbar.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';
import 'package:refrr_admin/Feature/Login/Repository/lead-repository.dart';
import 'package:refrr_admin/Feature/Login/Screens/home.dart';
import 'package:refrr_admin/Feature/Login/Screens/contact-us.dart';
import 'package:refrr_admin/models/affiliate-model.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:refrr_admin/models/services-model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Repository provider
final leadRepositoryProvider = Provider((ref) => LeadRepository());

final leadByIdProvider =
FutureProvider.family<LeadsModel?, String>((ref, String leadId) async {
  final controller = ref.watch(leadControllerProvider.notifier);
  return controller.getLeadById(leadId: leadId);
});

final firmServicesProvider = StreamProvider.family<List<ServiceModel>, String>((ref, leadId) {
  final repo = ref.watch(leadRepositoryProvider);
  return repo.getFirmServices(leadId);
});

final applicationsProvider = StreamProvider.family<List<AffiliateModel>, String>((ref, appId) {
  final repo = ref.watch(leadRepositoryProvider);
  return repo.getApplications(appId);
});

final teamProvider = StreamProvider.family<List<AffiliateModel>, String>((ref, leadId) {
  final repo = ref.watch(leadRepositoryProvider);
  return repo.getTeam(leadId);
});

/// Stream provider for listing/searching leads
final leadStreamProvider =
StreamProvider.family<List<LeadsModel>, String>((ref, searchQuery) {
  final repository = ref.watch(leadRepositoryProvider);
  return repository.getLead(searchQuery);
});

/// Holds the current logged-in lead in memory
final currentLeadProvider = StateProvider<LeadsModel?>((ref) => null);

/// Loading controller provider
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

  /// ========== LOGIN BY EMAIL/PASSWORD (UPDATED) ==========
  Future<void> loginLead({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    state = true;
    final res = await _repository.loginLead(email, password);
    state = false;

    res.fold(
          (failure) {
        // 🔴 CHECK IF ACCOUNT IS DELETED
        if (failure.failure == "ACCOUNT_DELETED") {
          _showDeletedAccountSnackbar(context);
        } else {
          showCommonSnackbar(context, failure.failure);
        }
      },
          (lead) async {
        try {
          final uid = lead.reference?.id;
          if (uid != null && uid.isNotEmpty) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('uid', uid);
          } else {
            debugPrint('Warning: Lead.reference is null or has no id, uid not saved.');
          }

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

  /// ========== SHOW DELETED ACCOUNT SNACKBAR ==========
  void _showDeletedAccountSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 24,
            ),
            SizedBox(width: width * 0.03),
            Expanded(
              child: Text(
                "Your account has been deleted. Please contact admin to recover your account or create a new account.",
                style: GoogleFonts.dmSans(
                  fontSize: width * 0.035,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 6),
        margin: EdgeInsets.all(width * 0.04),
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.04,
          vertical: width * 0.035,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: SnackBarAction(
          label: 'Contact Us',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ContactUs()),
            );
          },
        ),
      ),
    );
  }

  // ========== REST OF YOUR EXISTING METHODS (NO CHANGES) ==========

  /// Add lead
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

  /// Update lead
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
        // showCommonSnackbar(context, "Lead updated successfully");
        if (Navigator.of(context).canPop()) {
          Navigator.pop(context);
        }
      },
    );
  }

  /// Fetch a single lead by uid
  Future<LeadsModel?> getLead(String uid) async {
    if (uid.isEmpty) return null;

    try {
      final doc =
      await FirebaseFirestore.instance.collection('leads').doc(uid).get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      final lead = LeadsModel.fromMap({
        ...data,
        'reference': doc.reference,
      });

      _ref.read(currentLeadProvider.notifier).state = lead;
      return lead;
    } catch (e) {
      debugPrint('getLead error: $e');
      return null;
    }
  }

  /// Update in-memory lead only
  void setCurrentLead(LeadsModel leadModel) {
    _ref.read(currentLeadProvider.notifier).state = leadModel;
  }

  /// Logout helper
  Future<void> logout(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('uid');
    } catch (_) {}
    _ref.read(currentLeadProvider.notifier).state = null;
  }

  /// Add team members to a lead
  Future<void> addTeamMembers({
    required BuildContext context,
    required String leadId,
    required List<AffiliateModel> affiliates,
  }) async {
    if (affiliates.isEmpty) {
      showCommonSnackbar(context, 'No affiliates to add');
      return;
    }

    state = true;
    final res = await _repository.addTeamMembers(
      leadId: leadId,
      affiliates: affiliates,
    );
    state = false;

    res.fold(
          (failure) => showCommonSnackbar(context, failure.failure),
          (_) {
        showCommonSnackbar(context, '${affiliates.length} team members added successfully');

        if (_ref.read(currentLeadProvider)?.reference?.id == leadId) {
          getLead(leadId);
        }
      },
    );
  }

  /// Remove team members from a lead
  Future<void> removeTeamMembers({
    required BuildContext context,
    required String leadId,
    required List<AffiliateModel> affiliates,
  }) async {
    if (affiliates.isEmpty) {
      showCommonSnackbar(context, 'No affiliates to remove');
      return;
    }

    state = true;
    final res = await _repository.removeTeamMembers(
      leadId: leadId,
      affiliates: affiliates,
    );
    state = false;

    res.fold(
          (failure) => showCommonSnackbar(context, failure.failure),
          (_) {
        showCommonSnackbar(context, '${affiliates.length} team members removed successfully');

        if (_ref.read(currentLeadProvider)?.reference?.id == leadId) {
          getLead(leadId);
        }
      },
    );
  }

  /// Hire affiliates (move from applications to team members)
  Future<void> hireAffiliates({
    required BuildContext context,
    required String leadId,
    required List<AffiliateModel> affiliates,
  }) async {
    if (affiliates.isEmpty) {
      showCommonSnackbar(context, 'No affiliates to hire');
      return;
    }

    state = true;
    final res = await _repository.hireAffiliatesFromApplications(
      leadId: leadId,
      affiliates: affiliates,
    );
    state = false;

    res.fold(
          (failure) => showCommonSnackbar(context, failure.failure),
          (_) {
        showCommonSnackbar(context, '${affiliates.length} marketers hired successfully!');

        if (_ref.read(currentLeadProvider)?.reference?.id == leadId) {
          getLead(leadId);
        }
      },
    );
  }

  /// Update entire team members list
  Future<void> updateTeamMembers({
    required BuildContext context,
    required String leadId,
    required List<AffiliateModel> teamMembers,
  }) async {
    state = true;
    final res = await _repository.updateTeamMembers(
      leadId: leadId,
      teamMembers: teamMembers,
    );
    state = false;

    res.fold(
          (failure) => showCommonSnackbar(context, failure.failure),
          (_) {
        showCommonSnackbar(context, 'Team members updated successfully');

        if (_ref.read(currentLeadProvider)?.reference?.id == leadId) {
          getLead(leadId);
        }
      },
    );
  }

  /// Hire affiliates from applications (move from applications to team members)
  Future<void> hireAffiliatesFromApplications({
    required BuildContext context,
    required String leadId,
    required List<AffiliateModel> affiliates,
  }) async {
    if (affiliates.isEmpty) {
      showCommonSnackbar(context, 'No affiliates to hire');
      return;
    }

    state = true;
    final res = await _repository.hireAffiliatesFromApplications(
      leadId: leadId,
      affiliates: affiliates,
    );
    state = false;

    res.fold(
          (failure) => showCommonSnackbar(context, failure.failure),
          (_) {
        showCommonSnackbar(context, '${affiliates.length} affiliate(s) hired successfully!');

        if (_ref.read(currentLeadProvider)?.reference?.id == leadId) {
          getLead(leadId);
        }
      },
    );
  }


  Future<LeadsModel?> getLeadById({
    required String leadId,
  }) async {
    final res = await _repository.getLeadById(leadId: leadId);
    return res.fold((l) {
      print("get LEad by id left worked ${l.failure}");
      throw Exception(l.failure);
    }, (r) => r);
  }
}