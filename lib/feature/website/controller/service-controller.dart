import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:refrr_admin/Core/common/snackbar.dart';
import 'package:refrr_admin/Core/constants/firebaseConstants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:refrr_admin/Feature/website/repository/service-repository.dart';
import 'package:refrr_admin/models/services-model.dart';

final serviceControllerProvider =
StateNotifierProvider<ServiceController, bool>((ref) {
  return ServiceController(ref.read(serviceRepositoryProvider));
});

final servicesStreamProvider =
StreamProvider.family<List<ServiceModel>, String>((ref, leadId) {
  return ref.read(serviceRepositoryProvider).getServices(leadId);
});

class ServiceController extends StateNotifier<bool> {
  final ServiceRepository _repository;

  ServiceController(this._repository) : super(false);

  Future<void> addService({
    required String leadId,
    required ServiceModel service,
    required BuildContext context,
  }) async {
    state = true;

    final res = await _repository.addService(
      leadId: leadId,
      service: service,
    );

    state = false;

    res.fold(
          (l) => showCommonSnackbar(context, l.failure),
          (r) => showCommonSnackbar(context, 'Service added'),
    );
  }

  Future<String> uploadServiceImage({
    required File file,
    required String leadId,
  }) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child(FirebaseCollections.leadsCollection)
        .child(leadId)
        .child(FirebaseCollections.servicesCollection)
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
  Future<void> deleteService({
    required String leadId,
    required String serviceId,
    required BuildContext context,
  }) async {
    state = true;

    final res = await _repository.deleteService(
      leadId: leadId,
      serviceId: serviceId,
    );

    state = false;

    res.fold(
          (l) => showCommonSnackbar(context, l.failure),
          (_) => showCommonSnackbar(context, 'Service deleted'),
    );
  }

  /// ✏️ Update Product
  Future<void> updateService({
    required String leadId,
    required ServiceModel service,
    required BuildContext context,
  }) async {
    state = true;

    final res = await _repository.updateService(
      leadId: leadId,
      service: service,
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
}