import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:refrr_admin/core/common/snackbar.dart';
import 'package:refrr_admin/core/constants/firebase_constants.dart';
import 'package:refrr_admin/feature/promote/repository/creatives_repository.dart';
import 'package:refrr_admin/models/creative_model.dart';


final creativeControllerProvider =
StateNotifierProvider<CreativeController, bool>((ref) {
  return CreativeController(ref.read(creativeRepositoryProvider));
});
final creativesStreamProvider =
StreamProvider.family<List<CreativeModel>, String>((ref, leadId) {
  return ref.read(creativeRepositoryProvider).getCreatives(leadId);
});

class CreativeController extends StateNotifier<bool> {
  final CreativeRepository _repository;

  CreativeController(this._repository) : super(false);

  Future<void> addCreative({
    required String leadId,
    required CreativeModel creative,
    required BuildContext context,
  }) async {
    state = true;

    final res = await _repository.addCreative(
      leadId: leadId,
      creative: creative,
    );

    state = false;

    res.fold(
          (l) => showCommonSnackbar(context, l.failure),
          (r) => showCommonSnackbar(context, 'Creative added'),
    );
  }

  Future<String> uploadCreativeImage({
    required File file,
    required String leadId,
  }) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child(FirebaseCollections.leadsCollection)
        .child(leadId)
        .child(FirebaseCollections.creativesCollection)
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

  Future<void> addCreativeFlow({
    required File file,
    required String leadId,
    required BuildContext context,
  }) async {
    if (state) return; // prevent double call
    state = true;

    try {
      print('starting upload');

      final imageUrl = await uploadCreativeImage(
        file: file,
        leadId: leadId,
      );

      print('upload success');

      final creative = CreativeModel(
        url: imageUrl,
        addedBy: leadId,
        delete: false,
        createTime: DateTime.now(),
      );

      await _repository.addCreative(
        leadId: leadId,
        creative: creative,
      );
    } catch (e) {
      showCommonSnackbar(context, 'Upload failed');
      debugPrint(e.toString());
    } finally {
      state = false;
    }
  }
  /// DELETE (SOFT DELETE)
  Future<void> deleteCreative({
    required String leadId,
    required String creativeId,
    required BuildContext context,
  }) async {
    state = true;

    final res = await _repository.deleteCreative(
      leadId: leadId,
      creativeId: creativeId,
    );

    state = false;

    res.fold(
          (l) => showCommonSnackbar(context, l.failure),
          (_) => showCommonSnackbar(context, 'Creative deleted'),
    );
  }
}
