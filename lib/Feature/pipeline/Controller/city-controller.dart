import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:refrr_admin/Core/common/snackbar.dart';
import 'package:refrr_admin/Core/constants/firebaseConstants.dart';
import 'package:refrr_admin/Feature/pipeline/Repository/city-repository.dart';
import 'package:refrr_admin/models/city-model.dart';

/// STATE
final cityControllerProvider =
StateNotifierProvider<CityController, bool>((ref) {
  return CityController(ref.read(cityRepositoryProvider));
});

/// STREAM
final citiesStreamProvider =
StreamProvider.family<List<CityModel>, String>((ref, leadId) {
  return ref.read(cityRepositoryProvider).getCities(leadId);
});

class CityController extends StateNotifier<bool> {
  final CityRepository _repository;

  CityController(this._repository) : super(false);

  /// ADD CITY
  Future<void> addCity({
    required String leadId,
    required CityModel city,
    required BuildContext context,
  }) async {
    state = true;

    final res = await _repository.addCity(
      leadId: leadId,
      city: city,
    );

    state = false;

    res.fold(
          (l) => showCommonSnackbar(context, l.failure),
          (_) => showCommonSnackbar(context, 'City added'),
    );
  }

  /// UPLOAD CITY IMAGE
  Future<String> uploadCityImage({
    required File file,
    required String leadId,
  }) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child(FirebaseCollections.leadsCollection)
        .child(leadId)
        .child(FirebaseCollections.cityCollection)
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

  /// ADD CITY FLOW (IMAGE + DATA)
  Future<void> addCityFlow({
    required File file,
    required String leadId,
    required BuildContext context,
  }) async {
    if (state) return; // prevent double tap
    state = true;

    try {
      final imageUrl = await uploadCityImage(
        file: file,
        leadId: leadId,
      );

      final city = CityModel(
        profile: imageUrl,
        isDeleted: false,
        createdTime: DateTime.now(),
        zone:'' ,
        country: '',
        totalBusinessCount: 0,
        isZone: false,
        marketerCount: 0,
      );

      await _repository.addCity(
        leadId: leadId,
        city: city,
      );

      showCommonSnackbar(context, 'City added');
    } catch (e) {
      showCommonSnackbar(context, 'Upload failed');
      debugPrint(e.toString());
    } finally {
      state = false;
    }
  }

  /// SOFT DELETE CITY
  Future<void> deleteCity({
    required String leadId,
    required String cityId,
    required BuildContext context,
  }) async {
    state = true;

    final res = await _repository.deleteCity(
      leadId: leadId,
      cityId: cityId,
    );

    state = false;

    res.fold(
          (l) => showCommonSnackbar(context, l.failure),
          (_) => showCommonSnackbar(context, 'City deleted'),
    );
  }
}
