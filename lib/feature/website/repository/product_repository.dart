import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:refrr_admin/core/constants/failure.dart';
import 'package:refrr_admin/core/constants/firebase_constants.dart';
import 'package:refrr_admin/core/constants/typedef.dart';
import 'package:refrr_admin/models/product_model.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

class ProductRepository {
  final _firestore = FirebaseFirestore.instance;

  /// ➕ Add Product to Lead (Subcollection)
  FutureEither<ProductModel> addProduct({
    required String leadId,
    required ProductModel product,
  }) async {
    try {
      final ref = _firestore
          .collection(FirebaseCollections.leadsCollection)
          .doc(leadId)
          .collection('products')
          .doc();

      final productWithId = product.copyWith(
        id: ref.id,
        reference: ref,
      );
      await ref.set(productWithId.toMap());

      return right(productWithId);
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  /// ✏️ Update Product
  FutureVoid updateProduct({
    required String leadId,
    required ProductModel product,
  }) async {
    try {
      return right(
        await _firestore
            .collection(FirebaseCollections.leadsCollection)
            .doc(leadId)
            .collection('products')
            .doc(product.id)
            .update(product.toMap()),
      );
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  /// ❌ Soft Delete Product
  FutureVoid deleteProduct({
    required String leadId,
    required String productId,
  }) async {
    try {
      return right(
        await _firestore
            .collection(FirebaseCollections.leadsCollection)
            .doc(leadId)
            .collection('products')
            .doc(productId)
            .update({
          'delete': true,
        }),
      );
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  /// 📡 Get Products Stream
  Stream<List<ProductModel>> getProducts(String leadId) {
    return _firestore
        .collection(FirebaseCollections.leadsCollection)
        .doc(leadId)
        .collection(FirebaseCollections.productsCollection)
        .where('delete', isEqualTo: false)
        .orderBy('createTime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(
            (doc) => ProductModel.fromMap(
          doc.data(),
          id: doc.id,
        ),
      )
          .toList(),
    );
  }
}
