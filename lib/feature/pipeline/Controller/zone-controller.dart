// lib/feature/pipeline/Controller/zone-controller.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:refrr_admin/Feature/pipeline/Repository/zone-repository.dart';
import 'package:refrr_admin/models/zone-model.dart';

// State provider for loading
final zonalManagerLoadingProvider = StateProvider<bool>((ref) => false);

// Provider for all zonal managers stream
final zonalManagersStreamProvider =
StreamProvider<List<ZonalManagerModel>>((ref) {
  final repository = ref.watch(zonalManagerRepositoryProvider);
  return repository.getZonalManagers();
});

// Provider for zonal managers by country
final zonalManagersByCountryProvider =
StreamProvider.family<List<ZonalManagerModel>, String>((ref, countryId) {
  final repository = ref.watch(zonalManagerRepositoryProvider);
  return repository.getZonalManagersByCountry(countryId);
});

// Provider for unique cities WITH IMAGES
final uniqueCitiesStreamProvider =
StreamProvider<List<Map<String, dynamic>>>((ref) {
  final repository = ref.watch(zonalManagerRepositoryProvider);
  return repository.getUniqueCities();
});

// ✅ Provider to get zone image by city name
final zoneImageByNameProvider = FutureProvider.family<String, String>((ref, cityName) async {
  final repository = ref.watch(zonalManagerRepositoryProvider);
  return repository.getZoneImageByCityName(cityName);
});

// ✅ Provider to get zone image by city ID
final zoneImageByIdProvider = FutureProvider.family<String, String>((ref, cityId) async {
  final repository = ref.watch(zonalManagerRepositoryProvider);
  return repository.getZoneImageByCityId(cityId);
});

// ✅ Provider to get zone data by city name
final zoneDataByNameProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, cityName) async {
  final repository = ref.watch(zonalManagerRepositoryProvider);
  return repository.getZoneDataByCityName(cityName);
});

// ✅ Provider to get zone data by city ID
final zoneDataByIdProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, cityId) async {
  final repository = ref.watch(zonalManagerRepositoryProvider);
  return repository.getZoneDataByCityId(cityId);
});

final zonalManagerControllerProvider =
StateNotifierProvider<ZonalManagerController, bool>((ref) {
  return ZonalManagerController(
    zonalManagerRepository: ref.watch(zonalManagerRepositoryProvider),
    ref: ref,
  );
});

class ZonalManagerController extends StateNotifier<bool> {
  final ZonalManagerRepository _zonalManagerRepository;
  final Ref _ref;

  ZonalManagerController({
    required ZonalManagerRepository zonalManagerRepository,
    required Ref ref,
  })  : _zonalManagerRepository = zonalManagerRepository,
        _ref = ref,
        super(false);

  // Add business to zone
  Future<void> addBusinessToZone({
    required String cityId,
    required String businessId,
    required BuildContext context,
  }) async {
    state = true;
    final result = await _zonalManagerRepository.addBusinessToZone(
      cityId: cityId,
      businessId: businessId,
    );
    state = false;

    result.fold(
          (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.failure),
            backgroundColor: Colors.red,
          ),
        );
      },
          (_) {
        print('✅ Business successfully added to zone');
      },
    );
  }

  // Remove business from zone
  Future<void> removeBusinessFromZone({
    required String cityId,
    required String businessId,
    required BuildContext context,
  }) async {
    state = true;
    final result = await _zonalManagerRepository.removeBusinessFromZone(
      cityId: cityId,
      businessId: businessId,
    );
    state = false;

    result.fold(
          (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.failure),
            backgroundColor: Colors.red,
          ),
        );
      },
          (_) {
        print('✅ Business successfully removed from zone');
      },
    );
  }

  // Add zonal manager
  Future<void> addZonalManager({
    required ZonalManagerModel manager,
    required BuildContext context,
  }) async {
    state = true;
    final result = await _zonalManagerRepository.addZonalManager(manager);
    state = false;

    result.fold(
          (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.failure),
            backgroundColor: Colors.red,
          ),
        );
      },
          (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Zonal Manager added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }

  // Update zonal manager
  Future<void> updateZonalManager({
    required ZonalManagerModel manager,
    required BuildContext context,
  }) async {
    state = true;
    final result = await _zonalManagerRepository.updateZonalManager(manager);
    state = false;

    result.fold(
          (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.failure),
            backgroundColor: Colors.red,
          ),
        );
      },
          (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Zonal Manager updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }

  // Delete zonal manager
  Future<void> deleteZonalManager({
    required String managerId,
    required BuildContext context,
  }) async {
    state = true;
    final result = await _zonalManagerRepository.deleteZonalManager(managerId);
    state = false;

    result.fold(
          (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.failure),
            backgroundColor: Colors.red,
          ),
        );
      },
          (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Zonal Manager deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }

  // Check if city exists
  Future<bool> checkCityExists(String cityId) async {
    return await _zonalManagerRepository.cityExists(cityId);
  }

  // Get zone by city ID
  Future<ZonalManagerModel?> getZoneByCityId(String cityId) async {
    return await _zonalManagerRepository.getZoneByCityId(cityId);
  }

  // ✅ Get zone image by city name
  Future<String> getZoneImageByCityName(String cityName) async {
    return await _zonalManagerRepository.getZoneImageByCityName(cityName);
  }

  // ✅ Get zone image by city ID
  Future<String> getZoneImageByCityId(String cityId) async {
    return await _zonalManagerRepository.getZoneImageByCityId(cityId);
  }

  // ✅ Get zone data by city name
  Future<Map<String, dynamic>?> getZoneDataByCityName(String cityName) async {
    return await _zonalManagerRepository.getZoneDataByCityName(cityName);
  }

  // ✅ Get zone data by city ID
  Future<Map<String, dynamic>?> getZoneDataByCityId(String cityId) async {
    return await _zonalManagerRepository.getZoneDataByCityId(cityId);
  }
}
