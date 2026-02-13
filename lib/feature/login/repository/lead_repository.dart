import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:refrr_admin/core/constants/failure.dart';
import 'package:refrr_admin/core/constants/firebase_constants.dart';
import 'package:refrr_admin/core/constants/typedef.dart';
import 'package:refrr_admin/models/affiliate_model.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:refrr_admin/models/services_model.dart';


final leadRepositoryProvider = Provider<LeadRepository>((ref) {
  return LeadRepository();
});

class LeadRepository {
  /// ========== LOGIN (UPDATED WITH DELETE CHECK) ==========
  FutureEither<LeadsModel> loginLead(String email, String password) async {
    try {
      // Step 1: Query WITHOUT delete filter to check if account exists
      final querySnapshot = await FirebaseFirestore.instance
          .collection(FirebaseCollections.leadsCollection)
          .where('mail', isEqualTo: email)
          .where('password', isEqualTo: password)
          .get();

      // Step 2: Check if any matching account exists
      if (querySnapshot.docs.isEmpty) {
        return left(Failure(failure: "Invalid email or password"));
      }

      final doc = querySnapshot.docs.first;
      final leadData = doc.data();

      // Step 3: Check if account is deleted
      if (leadData['delete'] == true) {
        return left(Failure(failure: "ACCOUNT_DELETED"));
      }

      // Step 4: account is active - return lead model
      final lead = LeadsModel.fromMap({
        ...leadData,
        'reference': doc.reference,
      });

      return right(lead);
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  /// Add lead
  FutureEither<LeadsModel> addLead(LeadsModel lead) async {
    try {
      DocumentReference ref = FirebaseFirestore.instance
          .collection(FirebaseCollections.leadsCollection)
          .doc();

      print('11111111111111111111111111111111111111111111111111');
      print(ref);
      print('1111111111111111111111111111111111111111111111111');

      LeadsModel leadModel = lead.copyWith(reference: ref);
      await ref.set(leadModel.toMap());
      return right(leadModel);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  /// Update lead
  FutureVoid updateLead(LeadsModel lead) async {
    try {
      return right(await lead.reference!.update(lead.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  /// Lead stream with search
  Stream<List<LeadsModel>> getLead(String searchQuery) {
    final collection =
    FirebaseFirestore.instance.collection(FirebaseCollections.leadsCollection);

    if (searchQuery.isEmpty) {
      return collection
          .orderBy('createTime', descending: true)
          .where('delete', isEqualTo: false)
          .snapshots()
          .map((snapshot) =>
          snapshot.docs.map((doc) => LeadsModel.fromMap(doc.data())).toList());
    } else {
      return collection
          .where('delete', isEqualTo: false)
          .where('search', arrayContains: searchQuery.toUpperCase())
          .snapshots()
          .map((snapshot) =>
          snapshot.docs.map((doc) => LeadsModel.fromMap(doc.data())).toList());
    }
  }

  /// Get services from lead
  Stream<List<ServiceModel>> getFirmServices(String leadId) {
    return FirebaseFirestore.instance
        .collection('leads')
        .doc(leadId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return <ServiceModel>[];

      final data = snapshot.data();
      if (data == null || data['services'] == null) return <ServiceModel>[];

      final List<ServiceModel> services = (data['services'] as List)
          .map((e) => ServiceModel.fromMap(Map<String, dynamic>.from(e)))
          .toList();

      return services;
    });
  }

  /// Get applications from lead
  Stream<List<AffiliateModel>> getApplications(String appId) {
    return FirebaseFirestore.instance
        .collection('leads')
        .doc(appId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return <AffiliateModel>[];

      final data = snapshot.data();
      if (data == null || data['applications'] == null) return <AffiliateModel>[];

      final List<AffiliateModel> applications = (data['applications'] as List)
          .map((e) => AffiliateModel.fromMap(Map<String, dynamic>.from(e)))
          .toList();

      return applications;
    });
  }

  /// Get team members from lead
  /// 🔹 Get team Members by IDs (FIXED - teamMembers contains only IDs)
  Stream<List<AffiliateModel>> getTeam(String leadId) {
    return FirebaseFirestore.instance
        .collection('leads')
        .doc(leadId)
        .snapshots()
        .asyncMap((snapshot) async {
      if (!snapshot.exists) {
        debugPrint('⚠️ Lead document not found: $leadId');
        return <AffiliateModel>[];
      }

      final data = snapshot.data();
      if (data == null || data['teamMembers'] == null) {
        debugPrint('⚠️ No teamMembers found');
        return <AffiliateModel>[];
      }

      // teamMembers is now List<String> (affiliate IDs)
      final List<String> teamMemberIds = List<String>.from(data['teamMembers'] ?? []);

      debugPrint('📋 team Member IDs: $teamMemberIds');

      if (teamMemberIds.isEmpty) {
        return <AffiliateModel>[];
      }

      // Fetch affiliates by IDs
      List<AffiliateModel> affiliates = [];

      // Split into chunks of 10 (Firestore whereIn limit)
      for (int i = 0; i < teamMemberIds.length; i += 10) {
        int end = (i + 10 < teamMemberIds.length) ? i + 10 : teamMemberIds.length;
        List<String> chunk = teamMemberIds.sublist(i, end);

        debugPrint('📡 Fetching chunk: $chunk');

        final querySnapshot = await FirebaseFirestore.instance
            .collection('affiliates') // or use FirebaseCollections.affiliatesCollection
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        final chunkAffiliates = querySnapshot.docs.map((doc) {
          return AffiliateModel.fromMap(doc.data(), reference: doc.reference);
        }).toList();

        affiliates.addAll(chunkAffiliates);
      }

      debugPrint('✅ Fetched ${affiliates.length} team members');
      return affiliates;
    });
  }

  /// Update firm services
  Future<void> updateFirmServices({
    required String leadId,
    required List<ServiceModel> services,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection(FirebaseCollections.leadsCollection)
          .doc(leadId)
          .update({
        'services': services.map((e) => e.toMap()).toList(),
      });
    } catch (e) {
      debugPrint('Error updating services: $e');
      rethrow;
    }
  }

  /// Add team members to lead
  FutureVoid addTeamMembers({
    required String leadId,
    required List<AffiliateModel> affiliates,
  }) async {
    try {
      // Convert affiliates to map format
      final affiliateMaps = affiliates.map((e) => e.toMap()).toList();

      // Use arrayUnion to add without duplicates
      await FirebaseFirestore.instance
          .collection(FirebaseCollections.leadsCollection)
          .doc(leadId)
          .update({
        'teamMembers': FieldValue.arrayUnion(affiliateMaps),
      });

      return right(null);
    } on FirebaseException catch (e) {
      return left(Failure(failure: e.message ?? 'Failed to add team members'));
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  /// Remove team members from lead
  FutureVoid removeTeamMembers({
    required String leadId,
    required List<AffiliateModel> affiliates,
  }) async {
    try {
      final affiliateMaps = affiliates.map((e) => e.toMap()).toList();

      await FirebaseFirestore.instance
          .collection(FirebaseCollections.leadsCollection)
          .doc(leadId)
          .update({
        'teamMembers': FieldValue.arrayRemove(affiliateMaps),
      });

      return right(null);
    } on FirebaseException catch (e) {
      return left(Failure(failure: e.message ?? 'Failed to remove team members'));
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  /// Update entire team members list
  FutureVoid updateTeamMembers({
    required String leadId,
    required List<AffiliateModel> teamMembers,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection(FirebaseCollections.leadsCollection)
          .doc(leadId)
          .update({
        'teamMembers': teamMembers.map((e) => e.toMap()).toList(),
      });

      return right(null);
    } on FirebaseException catch (e) {
      return left(Failure(failure: e.message ?? 'Failed to update team members'));
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  /// Remove application and add to team members (hire action)
  /// Hire affiliates - Store IDs only in teamMembers
  FutureVoid hireAffiliatesFromApplications({
    required String leadId,
    required List<AffiliateModel> affiliates,
  }) async {
    try {
      final leadRef = FirebaseFirestore.instance
          .collection(FirebaseCollections.leadsCollection)
          .doc(leadId);

      // Get current data
      final snapshot = await leadRef.get();
      if (!snapshot.exists) {
        return left(Failure(failure: 'Lead not found'));
      }

      final data = snapshot.data()!;
      final currentApplications = data['applications'] as List? ?? [];
      final currentTeamMemberIds = List<String>.from(data['teamMembers'] ?? []);

      // Convert applications to AffiliateModel list
      final applications = currentApplications
          .map((e) => AffiliateModel.fromMap(Map<String, dynamic>.from(e)))
          .toList();

      // Extract affiliate IDs to add
      final List<String> affiliateIdsToAdd = [];

      // Remove from applications and collect IDs
      for (var affiliate in affiliates) {
        final affiliateId = affiliate.reference?.id ?? '';

        if (affiliateId.isEmpty) continue;

        // Remove from applications
        applications.removeWhere((app) =>
        app.reference?.id == affiliate.reference?.id ||
            app.id == affiliate.id);

        // Add to team member IDs if not already present
        if (!currentTeamMemberIds.contains(affiliateId)) {
          affiliateIdsToAdd.add(affiliateId);
        }
      }

      if (affiliateIdsToAdd.isEmpty) {
        return left(Failure(failure: 'All affiliates already in team'));
      }

      // Merge team member IDs
      final mergedTeamMemberIds = [...currentTeamMemberIds, ...affiliateIdsToAdd];

      // Update Firestore with IDs only
      await leadRef.update({
        'applications': applications.map((e) => e.toMap()).toList(),
        'teamMembers': mergedTeamMemberIds,
      });

      // Update each affiliate's workingFirms
      final batch = FirebaseFirestore.instance.batch();
      for (final affiliateId in affiliateIdsToAdd) {
        final affiliateRef = FirebaseFirestore.instance
            .collection(FirebaseCollections.affiliatesCollection)
            .doc(affiliateId);

        batch.update(affiliateRef, {
          'workingFirms': FieldValue.arrayUnion([leadId]),
        });
      }
      await batch.commit();

      return right(null);
    } on FirebaseException catch (e) {
      return left(Failure(failure: e.message ?? 'Failed to hire affiliates'));
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  FutureEither<LeadsModel?> getLeadById({
    required String leadId,
  }) async {
    print("get lead by id repo triggered $leadId");
    try {
      final doc = await FirebaseFirestore.instance
          .collection(FirebaseCollections.leadsCollection)
          .doc(leadId)
          .get();

      if (doc.exists) {
        return right(LeadsModel.fromMap(
          doc.data() as Map<String, dynamic>,
          reference: doc.reference,
        ));
      }
      return left(Failure(failure: "Lead not found"));
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }
}
