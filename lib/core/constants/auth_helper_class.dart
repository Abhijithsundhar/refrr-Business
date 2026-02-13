import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// Optional: Global auth check helper
class AuthHelper {
  static Future<bool> checkAndEnsureAuth() async {
    try {
      final auth = FirebaseAuth.instance;
      User? user = auth.currentUser;

      if (user == null) {
        debugPrint('AuthHelper: No user, signing in...');
        await auth.signInAnonymously();
        user = auth.currentUser;
      }

      if (user != null) {
        debugPrint('AuthHelper: User authenticated - ${user.uid}');
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('AuthHelper error: $e');
      return false;
    }
  }

  static User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  static String? getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }
}