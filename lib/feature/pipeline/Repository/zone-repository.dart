// lib/feature/pipeline/Repository/zone-repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:refrr_admin/Core/constants/failure.dart';
import 'package:refrr_admin/Core/constants/typedef.dart';
import 'package:refrr_admin/Feature/Login/Repository/auth-repository.dart';
import 'package:refrr_admin/models/zone-model.dart';

final zonalManagerRepositoryProvider = Provider((ref) {
  return ZonalManagerRepository(firestore: ref.read(firestoreProvider));
});

class ZonalManagerRepository {
  final FirebaseFirestore _firestore;

  ZonalManagerRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference get _zonalManagers =>
      _firestore.collection('zonalManagers');

  // ✅ Get unique cities from zonal managers - WITH IMAGE
  Stream<List<Map<String, dynamic>>> getUniqueCities() {
    print('🔄 Starting to fetch unique cities from zonalManagers...');

    return _zonalManagers
        .where('delete', isEqualTo: false)
        .snapshots()
        .asyncMap((snapshot) async {
      print('📦 Received ${snapshot.docs.length} zonal manager documents');

      // Fetch all countries first
      final countriesSnapshot = await _firestore.collection('countries').get();
      final Map<String, String> countryCodeToName = {};

      for (var countryDoc in countriesSnapshot.docs) {
        final data = countryDoc.data();
        final shortName = data['shortName']?.toString().toUpperCase() ?? '';
        final countryName = data['countryName']?.toString() ?? '';
        if (shortName.isNotEmpty) {
          countryCodeToName[shortName] = countryName;
        }
      }

      print('🗺️ Country mapping: $countryCodeToName');

      final Map<String, Map<String, dynamic>> uniqueCitiesMap = {};

      for (var doc in snapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;

          final cityId = data['cityId']?.toString() ?? '';
          final cityName = data['cityName']?.toString() ?? '';
          final countryId = data['countryId']?.toString().toUpperCase() ?? '';

          // ✅ Get image - try multiple field names for flexibility
          final image = (data['image'] ??
              data['cityImage'] ??
              data['zoneImage'] ??
              data['profile'] ??
              data['photo'] ??
              '').toString();

          // Get country name from the map
          final countryName = countryCodeToName[countryId] ?? countryId;

          if (cityId.isNotEmpty && cityName.isNotEmpty) {
            if (!uniqueCitiesMap.containsKey(cityId)) {
              uniqueCitiesMap[cityId] = {
                'cityId': cityId,
                'cityName': cityName,
                'countryId': countryId,
                'countryName': countryName,
                'image': image,  // ✅ Added image field
              };
              print('   ✅ Added: $cityName, $countryName ($countryId) | Image: ${image.isNotEmpty ? "YES" : "NO"}');
            }
          }
        } catch (e) {
          print('   ❌ Error parsing document ${doc.id}: $e');
        }
      }

      print('✅ Total unique cities: ${uniqueCitiesMap.length}');
      return uniqueCitiesMap.values.toList();
    });
  }

  // ✅ Get zone image by city name
  Future<String> getZoneImageByCityName(String cityName) async {
    try {
      print('🔍 Searching image for city: $cityName');

      final querySnapshot = await _zonalManagers
          .where('delete', isEqualTo: false)
          .get();

      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final docCityName = (data['cityName'] ?? '').toString().toLowerCase().trim();

        if (docCityName == cityName.toLowerCase().trim()) {
          final image = (data['image'] ??
              data['cityImage'] ??
              data['zoneImage'] ??
              data['profile'] ??
              data['photo'] ??
              '').toString();

          print('🖼️ Found image for $cityName: ${image.isNotEmpty ? image : "NO IMAGE"}');
          return image;
        }
      }

      print('⚠️ No image found for city: $cityName');
      return '';
    } catch (e) {
      print('❌ Error getting zone image: $e');
      return '';
    }
  }

  // ✅ Get zone image by city ID
  Future<String> getZoneImageByCityId(String cityId) async {
    try {
      print('🔍 Searching image for cityId: $cityId');

      final querySnapshot = await _zonalManagers
          .where('delete', isEqualTo: false)
          .where('cityId', isEqualTo: cityId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data() as Map<String, dynamic>;
        final image = (data['image'] ??
            data['cityImage'] ??
            data['zoneImage'] ??
            data['profile'] ??
            data['photo'] ??
            '').toString();

        print('🖼️ Found image for cityId $cityId: ${image.isNotEmpty ? image : "NO IMAGE"}');
        return image;
      }

      print('⚠️ No image found for cityId: $cityId');
      return '';
    } catch (e) {
      print('❌ Error getting zone image by cityId: $e');
      return '';
    }
  }

  // ✅ Get complete zone data by city name (including image)
  Future<Map<String, dynamic>?> getZoneDataByCityName(String cityName) async {
    try {
      print('🔍 Getting zone data for city: $cityName');

      // Fetch country mapping
      final countriesSnapshot = await _firestore.collection('countries').get();
      final Map<String, String> countryCodeToName = {};

      for (var countryDoc in countriesSnapshot.docs) {
        final data = countryDoc.data();
        final shortName = data['shortName']?.toString().toUpperCase() ?? '';
        final countryNameVal = data['countryName']?.toString() ?? '';
        if (shortName.isNotEmpty) {
          countryCodeToName[shortName] = countryNameVal;
        }
      }

      final querySnapshot = await _zonalManagers
          .where('delete', isEqualTo: false)
          .get();

      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final docCityName = (data['cityName'] ?? '').toString().toLowerCase().trim();

        if (docCityName == cityName.toLowerCase().trim()) {
          final cityId = data['cityId']?.toString() ?? '';
          final countryId = data['countryId']?.toString().toUpperCase() ?? '';
          final countryName = countryCodeToName[countryId] ?? countryId;
          final image = (data['image'] ??
              data['cityImage'] ??
              data['zoneImage'] ??
              data['profile'] ??
              data['photo'] ??
              '').toString();

          final zoneData = {
            'cityId': cityId,
            'cityName': data['cityName'] ?? '',
            'countryId': countryId,
            'countryName': countryName,
            'image': image,
            'documentId': doc.id,
          };

          print('✅ Found zone data: $zoneData');
          return zoneData;
        }
      }

      print('⚠️ No zone data found for city: $cityName');
      return null;
    } catch (e) {
      print('❌ Error getting zone data: $e');
      return null;
    }
  }

  // ✅ Get complete zone data by city ID (including image)
  Future<Map<String, dynamic>?> getZoneDataByCityId(String cityId) async {
    try {
      print('🔍 Getting zone data for cityId: $cityId');

      // Fetch country mapping
      final countriesSnapshot = await _firestore.collection('countries').get();
      final Map<String, String> countryCodeToName = {};

      for (var countryDoc in countriesSnapshot.docs) {
        final data = countryDoc.data();
        final shortName = data['shortName']?.toString().toUpperCase() ?? '';
        final countryNameVal = data['countryName']?.toString() ?? '';
        if (shortName.isNotEmpty) {
          countryCodeToName[shortName] = countryNameVal;
        }
      }

      final querySnapshot = await _zonalManagers
          .where('delete', isEqualTo: false)
          .where('cityId', isEqualTo: cityId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data() as Map<String, dynamic>;

        final countryId = data['countryId']?.toString().toUpperCase() ?? '';
        final countryName = countryCodeToName[countryId] ?? countryId;
        final image = (data['image'] ??
            data['cityImage'] ??
            data['zoneImage'] ??
            data['profile'] ??
            data['photo'] ??
            '').toString();

        final zoneData = {
          'cityId': cityId,
          'cityName': data['cityName'] ?? '',
          'countryId': countryId,
          'countryName': countryName,
          'image': image,
          'documentId': doc.id,
        };

        print('✅ Found zone data: $zoneData');
        return zoneData;
      }

      print('⚠️ No zone data found for cityId: $cityId');
      return null;
    } catch (e) {
      print('❌ Error getting zone data by cityId: $e');
      return null;
    }
  }

  // Stream all zonal managers
  Stream<List<ZonalManagerModel>> getZonalManagers() {
    return _zonalManagers
        .where('delete', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ZonalManagerModel.fromMap({
          ...data,
          'id': doc.id,
          'reference': doc.reference,
        });
      }).toList();
    });
  }

  // Stream zonal managers by country
  Stream<List<ZonalManagerModel>> getZonalManagersByCountry(String countryId) {
    return _zonalManagers
        .where('delete', isEqualTo: false)
        .where('countryId', isEqualTo: countryId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ZonalManagerModel.fromMap({
          ...data,
          'id': doc.id,
          'reference': doc.reference,
        });
      }).toList();
    });
  }

  // Add business ID to zone
  FutureEither<void> addBusinessToZone({
    required String cityId,
    required String businessId,
  }) async {
    try {
      print('🏢 Adding business $businessId to city $cityId');

      // Find the zonal manager document with this cityId
      final querySnapshot = await _zonalManagers
          .where('delete', isEqualTo: false)
          .where('cityId', isEqualTo: cityId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('❌ No zonal manager found for cityId: $cityId');
        return left(Failure(failure: 'Zone not found for this city'));
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data() as Map<String, dynamic>;
      final currentBusinessIds = List<String>.from(data['businessIds'] ?? []);

      // Check if business already exists
      if (currentBusinessIds.contains(businessId)) {
        print('⚠️ Business already exists in this zone');
        return right(null);
      }

      // Add new business ID
      currentBusinessIds.add(businessId);

      // Update document
      await doc.reference.update({
        'businessIds': currentBusinessIds,
        'totalBusiness': (data['totalBusiness'] ?? 0) + 1,
      });

      print('✅ Business added successfully to zone');
      return right(null);
    } on FirebaseException catch (e) {
      print('❌ Firebase error: ${e.message}');
      return left(Failure(failure: e.message ?? 'Firebase error occurred'));
    } catch (e) {
      print('❌ Error: $e');
      return left(Failure(failure: e.toString()));
    }
  }

  // Remove business ID from zone
  FutureEither<void> removeBusinessFromZone({
    required String cityId,
    required String businessId,
  }) async {
    try {
      print('🗑️ Removing business $businessId from city $cityId');

      final querySnapshot = await _zonalManagers
          .where('delete', isEqualTo: false)
          .where('cityId', isEqualTo: cityId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return left(Failure(failure: 'Zone not found for this city'));
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data() as Map<String, dynamic>;
      final currentBusinessIds = List<String>.from(data['businessIds'] ?? []);

      // Remove business ID
      currentBusinessIds.remove(businessId);

      // Update document
      await doc.reference.update({
        'businessIds': currentBusinessIds,
        'totalBusiness': currentBusinessIds.length,
      });

      print('✅ Business removed successfully from zone');
      return right(null);
    } on FirebaseException catch (e) {
      return left(Failure(failure: e.message ?? 'Firebase error occurred'));
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  // Add zonal manager
  FutureEither<void> addZonalManager(ZonalManagerModel manager) async {
    try {
      await _zonalManagers.doc(manager.id).set(manager.toMap());
      return right(null);
    } on FirebaseException catch (e) {
      return left(Failure(failure: e.message ?? 'Firebase error occurred'));
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  // Update zonal manager
  FutureEither<void> updateZonalManager(ZonalManagerModel manager) async {
    try {
      await _zonalManagers.doc(manager.id).update(manager.toMap());
      return right(null);
    } on FirebaseException catch (e) {
      return left(Failure(failure: e.message ?? 'Firebase error occurred'));
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  // Delete (soft delete) zonal manager
  FutureEither<void> deleteZonalManager(String managerId) async {
    try {
      await _zonalManagers.doc(managerId).update({'delete': true});
      return right(null);
    } on FirebaseException catch (e) {
      return left(Failure(failure: e.message ?? 'Firebase error occurred'));
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  // Check if city exists
  Future<bool> cityExists(String cityId) async {
    final querySnapshot = await _zonalManagers
        .where('delete', isEqualTo: false)
        .where('cityId', isEqualTo: cityId)
        .limit(1)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  // Get zone by city ID
  Future<ZonalManagerModel?> getZoneByCityId(String cityId) async {
    try {
      final querySnapshot = await _zonalManagers
          .where('delete', isEqualTo: false)
          .where('cityId', isEqualTo: cityId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data() as Map<String, dynamic>;
      return ZonalManagerModel.fromMap({
        ...data,
        'id': doc.id,
        'reference': doc.reference,
      });
    } catch (e) {
      print('❌ Error getting zone: $e');
      return null;
    }
  }
}
