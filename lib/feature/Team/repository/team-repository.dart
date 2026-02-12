import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class TeamRepository {
  final FirebaseFirestore _firestore;

  TeamRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// 🔹 Remove Affiliate from Team
  Future<void> removeAffiliateFromTeam({
    required String firmId,
    required String affiliateId,
  }) async {
    try {
      debugPrint('🔄 Removing affiliate: $affiliateId from firm: $firmId');

      // Get the current document first
      final docSnapshot = await _firestore.collection('leads').doc(firmId).get();

      if (!docSnapshot.exists) {
        throw Exception('Firm document not found');
      }

      // Get current teamMembers list
      List<dynamic> currentTeamMembers = docSnapshot.data()?['teamMembers'] ?? [];

      debugPrint('📋 Current team members: $currentTeamMembers');

      // Remove the affiliate from list
      currentTeamMembers.removeWhere((member) {
        if (member is String) {
          return member == affiliateId;
        } else if (member is DocumentReference) {
          return member.id == affiliateId;
        } else if (member is Map) {
          return member['id'] == affiliateId || member['affiliateId'] == affiliateId;
        }
        return false;
      });

      debugPrint('📋 Updated team members: $currentTeamMembers');

      // Update the document with new list
      await _firestore.collection('leads').doc(firmId).update({
        'teamMembers': currentTeamMembers,
      });

      debugPrint('✅ Affiliate removed successfully');
    } catch (e) {
      debugPrint('❌ Error removing affiliate: $e');
      rethrow;
    }
  }
}
