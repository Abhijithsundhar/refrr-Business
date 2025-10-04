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

  CollectionReference get _admin => firestore.collection(FirebaseCollections.adminsCollection);

  FutureEither<AdminModel> adminLogin({
    required String userId,
    required String password,
  }) async {
    try {
      final QuerySnapshot query = await _admin
          .where('userId', isEqualTo: userId)
          .where("delete", isEqualTo: false)
          .where('password', isEqualTo: password)
          .get();

      if (query.docs.isNotEmpty) {
        DocumentSnapshot adminSnapshot = query.docs.first;
        AdminModel adminModel = AdminModel.fromMap(adminSnapshot.data() as Map<String, dynamic>);
        return right(adminModel);
      } else {
        throw "Invalid userId or Password";
      }
    } on FirebaseException catch (em) {
      throw em.message!;
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

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
        AdminModel adminModel = AdminModel.fromMap(snapshot.data() as Map<String, dynamic>);
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

  Future<DocumentSnapshot> getAdminModel({required String id}) async {
    return await _admin.doc(id).get();
  }
}
