import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:refrr_admin/Core/common/snackbar.dart';
import 'package:refrr_admin/Core/constants/firebaseConstants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:refrr_admin/Feature/website/repository/product-repository.dart';
import 'package:refrr_admin/models/product-model.dart';

final productControllerProvider =
StateNotifierProvider<ProductController, bool>((ref) {
  return ProductController(ref.read(productRepositoryProvider));
});

final productsStreamProvider =
StreamProvider.family<List<ProductModel>, String>((ref, leadId) {
  return ref.read(productRepositoryProvider).getProducts(leadId);
});

class ProductController extends StateNotifier<bool> {
  final ProductRepository _repository;

  ProductController(this._repository) : super(false);

  Future<void> addProduct({
    required String leadId,
    required ProductModel product,
    required BuildContext context,
  }) async {
    state = true;

    final res = await _repository.addProduct(
      leadId: leadId,
      product: product,
    );

    state = false;

    res.fold(
          (l) => showCommonSnackbar(context, l.failure),
          (r) => showCommonSnackbar(context, 'Product added'),
    );
  }

  /// ✏️ Update Product
  Future<void> updateProduct({
    required String leadId,
    required ProductModel product,
    required BuildContext context,
  }) async {
    state = true;

    final res = await _repository.updateProduct(
      leadId: leadId,
      product: product,
    );

    state = false;

    res.fold(
          (l) => showCommonSnackbar(context, l.failure),
          (_) {
        // showCommonSnackbar(context, 'Product updated successfully');
        Navigator.pop(context); // Close the edit screen
      },
    );
  }

  Future<String> uploadProductImage({
    required File file,
    required String leadId,
  }) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child(FirebaseCollections.leadsCollection)
        .child(leadId)
        .child(FirebaseCollections.productsCollection)
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

    final task = await storageRef.putFile(
      file,
      SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl: 'public,max-age=3600',
      ),
    );

    return await task.ref.getDownloadURL();
  }

  /// DELETE (SOFT DELETE)
  Future<void> deleteProduct({
    required String leadId,
    required String productId,
    required BuildContext context,
  }) async {
    state = true;

    final res = await _repository.deleteProduct(
      leadId: leadId,
      productId: productId,
    );

    state = false;

    res.fold(
          (l) => showCommonSnackbar(context, l.failure),
          (_) => showCommonSnackbar(context, 'Product deleted'),
    );
  }
}
