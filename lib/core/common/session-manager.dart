import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _key = 'loggedInLead';

  // Recursively sanitize Firestore data for SharedPreferences
  static dynamic _sanitizeForJson(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toIso8601String();
    } else if (value is DocumentReference) {
      return null; // don't store Firestore refs directly
    } else if (value is Map) {
      return value.map((key, val) => MapEntry(key, _sanitizeForJson(val)));
    } else if (value is List) {
      return value.map(_sanitizeForJson).toList();
    } else {
      return value;
    }
  }

  // Save the logged-in lead to SharedPreferences
  static Future<void> saveLoggedInLead(LeadsModel lead) async {
    final prefs = await SharedPreferences.getInstance();
    final rawMap = Map<String, dynamic>.from(lead.toMap());

    // remove non-encodable Firestore references from inside the map
    rawMap.remove('reference');

    // store a path so we can reconstruct the ref later if needed
    rawMap['referencePath'] = lead.reference?.path;

    final safeMap = _sanitizeForJson(rawMap);
    final jsonString = jsonEncode(safeMap);
    await prefs.setString(_key, jsonString);
  }

  // Read the logged-in lead from SharedPreferences
  static Future<LeadsModel?> getLoggedInLead() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return null;

    final decodedMap = jsonDecode(jsonString) as Map<String, dynamic>;

    // Rebuild Timestamp
    final ct = decodedMap['createTime'];
    if (ct is String) {
      decodedMap['createTime'] = Timestamp.fromDate(DateTime.parse(ct));
    }

    // Rebuild DocumentReference if path exists
    final refPath = decodedMap['referencePath'];
    if (refPath is String && refPath.isNotEmpty) {
      decodedMap['reference'] = FirebaseFirestore.instance.doc(refPath);
    }

    return LeadsModel.fromMap(decodedMap);
  }

  // Clear session
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
