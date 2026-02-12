import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:refrr_admin/Core/common/snackbar.dart';
import 'package:refrr_admin/Core/constants/firebaseConstants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:refrr_admin/Feature/website/repository/firm-repository.dart';
import 'package:refrr_admin/models/firm-model.dart';

final firmControllerProvider =
StateNotifierProvider<FirmController, bool>((ref) {
  return FirmController(ref.read(firmRepositoryProvider));
});

final firmsStreamProvider =
StreamProvider.family<List<AddFirmModel>, String>((ref, leadId) {
  return ref.read(firmRepositoryProvider).getFirms(leadId);
});

class FirmController extends StateNotifier<bool> {
  final FirmRepository _repository;

  FirmController(this._repository) : super(false);

  Future<void> addFirm({
    required String leadId,
    required AddFirmModel firm,
    required BuildContext context,
  }) async {
    state = true;

    final res = await _repository.addFirm(
      leadId: leadId,
      firm: firm,
    );

    state = false;

    res.fold(
          (l) => showCommonSnackbar(context, l.failure),
          (r) => showCommonSnackbar(context, 'Firm added'),
    );
  }

  /// ✏️ Update Firm
  Future<void> updateFirm({
    required String leadId,
    required AddFirmModel firm,
    required BuildContext context,
  }) async {
    state = true;

    final res = await _repository.updateFirm(
      leadId: leadId,
      firm: firm,
    );

    state = false;

    res.fold(
          (l) => showCommonSnackbar(context, l.failure),
          (_) {
        showCommonSnackbar(context, 'Firm updated successfully');
      },
    );
  }

  Future<String> uploadFirmLogo({
    required File file,
    required String leadId,
  }) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child(FirebaseCollections.leadsCollection)
        .child(leadId)
        .child(FirebaseCollections.addFirmCollection)
        .child('logos')
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

  Future<String> uploadFirmDocument({
    required File file,
    required String leadId,
  }) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child(FirebaseCollections.leadsCollection)
        .child(leadId)
        .child(FirebaseCollections.addFirmCollection)
        .child('documents')
        .child('${DateTime.now().millisecondsSinceEpoch}.pdf');

    final task = await storageRef.putFile(
      file,
      SettableMetadata(
        contentType: 'application/pdf',
        cacheControl: 'public,max-age=3600',
      ),
    );

    return await task.ref.getDownloadURL();
  }

  /// DELETE (SOFT DELETE)
  Future<void> deleteFirm({
    required String leadId,
    required String firmId,
    required BuildContext context,
  }) async {
    state = true;

    final res = await _repository.deleteFirm(
      leadId: leadId,
      firmId: firmId,
    );

    state = false;

    res.fold(
          (l) => showCommonSnackbar(context, l.failure),
          (_) => showCommonSnackbar(context, 'Firm deleted'),
    );
  }
}
