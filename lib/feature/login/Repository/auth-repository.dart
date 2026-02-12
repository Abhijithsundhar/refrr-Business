import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:refrr_admin/Core/constants/failure.dart';
import 'package:refrr_admin/Core/constants/firebaseConstants.dart';
import 'package:refrr_admin/Core/constants/typedef.dart';
import 'package:refrr_admin/models/admin-model.dart';
import 'package:shared_preferences/shared_preferences.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final loginRepositoryProvider = Provider<LoginRepository>((ref) {
  return LoginRepository(ref.watch(firestoreProvider));
});

class LoginRepository {
  final FirebaseFirestore firestore;
  LoginRepository(this.firestore);

  CollectionReference get _admin =>
      firestore.collection(FirebaseCollections.adminsCollection);

  /// ========== ADMIN LOGIN WITH DELETE CHECK ==========
  FutureEither<AdminModel> adminLogin({
    required String userId,
    required String password,
  }) async {
    try {
      // Step 1: First check if user exists with matching credentials (without delete filter)
      final QuerySnapshot query = await _admin
          .where('userId', isEqualTo: userId)
          .where('password', isEqualTo: password)
          .get();

      if (query.docs.isNotEmpty) {
        DocumentSnapshot adminSnapshot = query.docs.first;
        Map<String, dynamic> data = adminSnapshot.data() as Map<String, dynamic>;

        // Step 2: Check if account is deleted
        if (data['delete'] == true) {
          // Return specific error for deleted account
          return left(Failure(
            failure: "ACCOUNT_DELETED", // Use a specific code
          ));
        }

        // Step 3: account is active - return admin model
        AdminModel adminModel = AdminModel.fromMap(data);

        // Save to SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("uid", adminModel.reference?.id ?? '');

        return right(adminModel);
      } else {
        // No matching credentials found
        return left(Failure(failure: "Invalid userId or Password"));
      }
    } on FirebaseException catch (em) {
      return left(Failure(failure: em.message ?? "Firebase error occurred"));
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  /// ========== RESET PASSWORD ==========
  FutureEither<AdminModel> resetPassword({
    required String userId,
    required String password,
  }) async {
    try {
      final QuerySnapshot query = await _admin
          .where('userId', isEqualTo: userId)
          .get();

      if (query.docs.isNotEmpty) {
        DocumentSnapshot snapshot = query.docs.first;
        AdminModel adminModel =
        AdminModel.fromMap(snapshot.data() as Map<String, dynamic>);
        AdminModel updatedAdmin = adminModel.copyWith(password: password);
        await adminModel.reference?.update(updatedAdmin.toMap());
        return right(updatedAdmin);
      } else {
        throw "Invalid userId";
      }
    } on FirebaseException catch (em) {
      throw em.message!;
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  /// ========== LOG OUT ==========
  FutureVoid logOut() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove("uid");
      return right(null);
    } on FirebaseException catch (em) {
      throw em.message!;
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  /// ========== GET ADMIN MODEL ==========
  Future<DocumentSnapshot> getAdminModel({required String id}) async {
    return await _admin.doc(id).get();
  }
}
