// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:fpdart/fpdart.dart';
// import '../../../Core/constants/failure.dart';
// import '../../../Core/constants/firebaseConstants.dart';
// import '../../../Core/constants/typedef.dart';
// import '../../../model/admin-model.dart';
//
// final adminRepositoryProvider = Provider<AdminRepository>((ref) {
//   return AdminRepository();
// });
//
// class AdminRepository {
//   /// Add admin
//   FutureEither<AdminModel> addAdmin(AdminModel admin) async {
//     try {
//       DocumentReference ref = FirebaseFirestore.instance
//           .collection(FirebaseCollections.adminsCollection)
//           .doc();
//
//       print('11111111111111111111111111111111111111111111111111');
//       print(ref);
//       print('1111111111111111111111111111111111111111111111111');
//
//       AdminModel adminModel = admin.copyWith(reference: ref);
//       await ref.set(adminModel.toMap());
//       return right(adminModel);
//     } on FirebaseException catch (e) {
//       throw e.message!;
//     } catch (e) {
//       return left(Failure(failure: e.toString()));
//     }
//   }
//
//   /// Update admin
//   FutureVoid updateAdmin(AdminModel admin) async {
//     try {
//       return right(await admin.reference!.update(admin.toMap()));
//     } on FirebaseException catch (e) {
//       throw e.message!;
//     } catch (e) {
//       return left(Failure(failure: e.toString()));
//     }
//   }
//
//   /// Admin stream with search
//   Stream<List<AdminModel>> getAdmin(String searchQuery) {
//     final collection =
//     FirebaseFirestore.instance.collection(FirebaseCollections.adminsCollection);
//
//     if (searchQuery.isEmpty) {
//       return collection
//           .orderBy('createTime', descending: true)
//           .where('delete', isEqualTo: false)
//           .snapshots()
//           .map((snapshot) =>
//           snapshot.docs.map((doc) => AdminModel.fromMap(doc.data())).toList());
//     } else {
//       return collection
//           .where('delete', isEqualTo: false)
//           .where('search', arrayContains: searchQuery.toUpperCase())
//           .snapshots()
//           .map((snapshot) =>
//           snapshot.docs.map((doc) => AdminModel.fromMap(doc.data())).toList());
//     }
//   }
// }
