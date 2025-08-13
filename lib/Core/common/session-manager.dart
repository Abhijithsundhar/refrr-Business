import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Model/leads-model.dart';

class SessionManager {
  static const String _key = 'loggedInLead';

  /// ✅ Recursively sanitize Firestore data for SharedPreferences
  static dynamic sanitizeForJson(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toIso8601String();
    } else if (value is DocumentReference) {
      return null; // We don't store Firestore references
    } else if (value is Map) {
      return value.map((key, val) => MapEntry(key, sanitizeForJson(val)));
    } else if (value is List) {
      return value.map(sanitizeForJson).toList();
    } else {
      return value;
    }
  }

  /// ✅ Save LeadModel to SharedPreferences safely
  static Future<void> saveLead(LeadsModel lead) async {
    final prefs = await SharedPreferences.getInstance();

    final rawMap = Map<String, dynamic>.from(lead.toMap());

    // Step 1: Remove fields that are not encodable
    rawMap.remove('reference');

    // Step 2: Deep-clean problematic values like Timestamps
    final safeMap = sanitizeForJson(rawMap);

    final jsonString = jsonEncode(safeMap);
    await prefs.setString(_key, jsonString);
  }

  /// ✅ Read LeadModel from SharedPreferences
  static Future<LeadsModel?> getLoggedInLead() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return null;

    final decodedMap = jsonDecode(jsonString);

    // Re-convert createTime string back to Timestamp (optional, your model may handle DateTime too)
    if (decodedMap['createTime'] is String) {
      decodedMap['createTime'] =
          Timestamp.fromDate(DateTime.parse(decodedMap['createTime']));
    }

    return LeadsModel.fromMap(decodedMap);
  }

  /// ✅ Logout (clear stored session)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}