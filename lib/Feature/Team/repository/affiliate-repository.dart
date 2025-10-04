
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:refrr_admin/Core/constants/failure.dart';
import 'package:refrr_admin/Core/constants/firebaseConstants.dart';
import 'package:refrr_admin/Core/constants/typedef.dart';
import 'package:refrr_admin/models/affiliate-model.dart';


final affiliateRepositoryProvider = Provider<AffiliateRepository>((ref) {return AffiliateRepository();});

class AffiliateRepository {

  ///add affiliate

  FutureEither<AffiliateModel> addAffiliate(AffiliateModel affiliate) async {
    try {
      DocumentReference ref = FirebaseFirestore.instance
          .collection(FirebaseCollections.affiliatesCollection).doc();
      print('11111111111111111111111111111111111111111111111111');
      print(ref);
      print('1111111111111111111111111111111111111111111111111');

      AffiliateModel affiliateModel = affiliate.copyWith(reference: ref,);
      await ref.set(affiliateModel.toMap());
      return right(affiliateModel);
    }
    on FirebaseException catch(e){
      throw e.message!;
    }
    catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  ///update affiliate
  FutureVoid updateAffiliate(AffiliateModel affiliate) async {
    try {
      return right(await affiliate.reference!.update(affiliate.toMap()));
    }
    on FirebaseException catch(e){
      throw e.message!;
    }
    catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }


  /// affiliate stream with search
  Stream<List<AffiliateModel>> getAffiliate(String searchQuery) {
    final collection = FirebaseFirestore.instance.collection(FirebaseCollections.affiliatesCollection);

    if (searchQuery.isEmpty) {
      return collection
          .orderBy('createTime', descending: true)
          .where('delete', isEqualTo: false)
          .snapshots()
          .map((snapshot) =>
          snapshot.docs.map((doc) => AffiliateModel.fromMap(doc.data())).toList());
    } else {
      return collection
          .where('delete', isEqualTo: false)
          .where('search', arrayContains: searchQuery.toUpperCase())
          .snapshots()
          .map((snapshot) =>
          snapshot.docs.map((doc) => AffiliateModel.fromMap(doc.data())).toList());
    }
  }

}