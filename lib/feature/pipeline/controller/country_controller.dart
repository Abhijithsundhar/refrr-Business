import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:refrr_admin/feature/pipeline/repository/country_repository.dart';
import 'package:refrr_admin/models/city_model.dart';
import 'package:refrr_admin/models/country_model.dart';



/// repository provider
final countryRepositoryProvider = Provider<CountryRepository>((ref) {
  return CountryRepository();
});

/// controller provider with loading state
final countryControllerProvider =
StateNotifierProvider<CountryController, bool>((ref) {
  final repo = ref.watch(countryRepositoryProvider);
  return CountryController(repo);
});

/// Provider for selected country
final selectedCountryProvider = StateProvider<CountryModel?>((ref) => null);

/// Provider for cities/zones list based on selected country
final citiesListProvider = StateProvider<List<CityModel>>((ref) => []);

/// Provider for zone names only (derived from citiesListProvider)
final zoneNamesProvider = Provider<List<String>>((ref) {
  final cities = ref.watch(citiesListProvider);
  return cities.map((city) => city.zone).toList();
});

/// FutureProvider for countries
final countriesFutureProvider = FutureProvider<List<CountryModel>>((ref) async {
  final repository = ref.watch(countryRepositoryProvider);
  return repository.fetchCountries();
});


/// FutureProvider for cities based on country document ID
final citiesFutureProvider = FutureProvider.family<List<CityModel>, String>((ref, countryDocumentId) async {
  final controller = ref.watch(countryControllerProvider.notifier);
  return await controller.fetchCitiesByCountryId(countryDocumentId);
});

class CountryController extends StateNotifier<bool> {
  final CountryRepository repository;

  CountryController(this.repository) : super(false);

  /// Add country
  Future<CountryModel?> addCountry(CountryModel country) async {
    state = true;
    try {
      final addedCountry = await repository.addCountry(country);
      return addedCountry;
    } catch (e) {
      rethrow;
    } finally {
      state = false;
    }
  }

  /// Fetch countries
  Future<List<CountryModel>> fetchCountries() async {
    try {
      final countries = await repository.fetchCountries();
      return countries;
    } catch (e, stack) {
      debugPrint("❌ Fetch countries error: $e");
      debugPrint("Stack: $stack");
      throw e; // or just let it throw naturally
    }
  }


  /// Fetch cities by country document ID
  Future<List<CityModel>> fetchCitiesByCountryId(String countryDocumentId) async {
    state = true;
    try {
      final cities = await repository.fetchCitiesByCountryId(countryDocumentId);
      return cities;
    } catch (e) {
      rethrow;
    } finally {
      state = false;
    }
  }
  /// Update country
  Future<void> updateCountry(CountryModel country) async {
    state = true;
    try {
      await repository.updateCountry(country);
    } catch (e) {
      rethrow;
    } finally {
      state = false;
    }
  }

  /// Delete country
  Future<void> deleteCountry(CountryModel country) async {
    state = true;
    try {
      await repository.deleteCountry(country);
    } catch (e) {
      rethrow;
    } finally {
      state = false;
    }
  }

  /// Update city
  Future<void> updateCity(String countryDocumentId, CityModel city) async {
    state = true;
    try {
      await repository.updateCity(countryDocumentId, city);
    } catch (e) {
      rethrow;
    } finally {
      state = false;
    }
  }

  /// Delete city
  Future<void> deleteCity(String countryDocumentId, CityModel city) async {
    state = true;
    try {
      await repository.deleteCity(countryDocumentId, city);
    } catch (e) {
      rethrow;
    } finally {
      state = false;
    }
  }
}
