import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:refrr_admin/Core/constants/firebaseConstants.dart';
import 'package:refrr_admin/models/city-model.dart';
import 'package:refrr_admin/models/country-model.dart';


class CountryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference
  CollectionReference get _countriesCollection =>
      _firestore.collection(FirebaseCollections.countryCollection);

  // Add country
  Future<CountryModel?> addCountry(CountryModel country) async {
    try {
      final docRef = await _countriesCollection.add(country.toMap());
      // Update with documentId
      await docRef.update({'documentId': docRef.id});
      return country.copyWith(documentId: docRef.id, reference: docRef);
    } catch (e) {
      rethrow;
    }
  }

  // Fetch all countries
  Future<List<CountryModel>> fetchCountries() async {
    try {
      final snapshot = await _countriesCollection
      // .orderBy('countryName')
          .get();

      return snapshot.docs.map((doc) {
        return CountryModel.fromMap(
          doc.data() as Map<String, dynamic>,
          ref: doc.reference,
        ).copyWith(documentId: doc.id);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Fetch cities/zones for a specific country using documentId
  Future<List<CityModel>> fetchCitiesByCountryId(String countryDocumentId) async {
    try {
      final snapshot = await _countriesCollection
          .doc(countryDocumentId)
          .collection('cities')
          .where('isDeleted', isEqualTo: false)
          .orderBy('zone')
          .get();

      return snapshot.docs.map((doc) {
        return CityModel.fromMap(
          doc.data(),
          id: doc.id,
          reference: doc.reference,
        );
      }).toList();
    } catch (e) {
      print('Error fetching cities: $e');
      rethrow;
    }
  }

  // Update country
  Future<void> updateCountry(CountryModel country) async {
    try {
      if (country.documentId != null) {
        await _countriesCollection.doc(country.documentId).update(country.toMap());
      } else if (country.reference != null) {
        await country.reference!.update(country.toMap());
      }
    } catch (e) {
      rethrow;
    }
  }

  // Delete country
  Future<void> deleteCountry(CountryModel country) async {
    try {
      if (country.documentId != null) {
        await _countriesCollection.doc(country.documentId).delete();
      } else if (country.reference != null) {
        await country.reference!.delete();
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update city
  Future<void> updateCity(String countryDocumentId, CityModel city) async {
    try {
      await _countriesCollection
          .doc(countryDocumentId)
          .collection('cities')
          .doc(city.id)
          .update(city.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Delete city (soft delete)
  Future<void> deleteCity(String countryDocumentId, CityModel city) async {
    try {
      await _countriesCollection
          .doc(countryDocumentId)
          .collection('cities')
          .doc(city.id)
          .update({'isDeleted': true});
    } catch (e) {
      rethrow;
    }
  }
}
