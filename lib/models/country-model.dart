import 'package:cloud_firestore/cloud_firestore.dart';

class CountryModel {
  final String countryName;
  final String shortName;
  final String countryCode;
  final String currency;
  final String language;
  final String flag;
  final String? documentId;
  final DocumentReference? reference;

  CountryModel({
    required this.countryName,
    required this.shortName,
    required this.countryCode,
    required this.currency,
    required this.language,
    required this.flag,
    this.documentId,
    this.reference,
  });

  /// TO MAP (for Firestore) - WITH documentId
  Map<String, dynamic> toMap() {
    return {
      'countryName': countryName,
      'shortName': shortName,
      'countryCode': countryCode,
      'currency': currency,
      'language': language,
      'flag': flag,
      'documentId': documentId, // Store document ID in Firestore
    };
  }

  /// FROM MAP (with optional reference)
  factory CountryModel.fromMap(Map<String, dynamic> map, {DocumentReference? ref}) {
    return CountryModel(
      countryName: map['countryName'] ?? '',
      shortName: map['shortName'] ?? '',
      countryCode: map['countryCode'] ?? '',
      currency: map['currency'] ?? '',
      language: map['language'] ?? '',
      flag: map['flag'] ?? '',
      documentId: map['documentId'],
      reference: ref,
    );
  }

  /// FROM RESTCOUNTRIES API
  factory CountryModel.fromApiJson(Map<String, dynamic> json) {
    String code = '';
    if (json['idd'] != null &&
        json['idd']['root'] != null &&
        json['idd']['suffixes'] != null &&
        json['idd']['suffixes'] is List &&
        (json['idd']['suffixes'] as List).isNotEmpty) {
      code = json['idd']['root'] + (json['idd']['suffixes'][0] ?? '');
    }

    String currency = '';
    if (json['currencies'] != null &&
        json['currencies'] is Map &&
        json['currencies'].isNotEmpty) {
      currency = json['currencies'].keys.first;
    }

    String language = '';
    if (json['languages'] != null &&
        json['languages'] is Map &&
        json['languages'].isNotEmpty) {
      language = (json['languages'] as Map).values.join(', ');
    }

    return CountryModel(
      countryName: json['name']['common'] ?? '',
      shortName: json['cca2'] ?? '',
      countryCode: code,
      currency: currency,
      language: language,
      flag: json['flags']['png'] ?? '',
    );
  }

  /// COPY WITH
  CountryModel copyWith({
    String? countryName,
    String? shortName,
    String? countryCode,
    String? currency,
    String? language,
    String? flag,
    String? documentId,
    DocumentReference? reference,
  }) {
    return CountryModel(
      countryName: countryName ?? this.countryName,
      shortName: shortName ?? this.shortName,
      countryCode: countryCode ?? this.countryCode,
      currency: currency ?? this.currency,
      language: language ?? this.language,
      flag: flag ?? this.flag,
      documentId: documentId ?? this.documentId,
      reference: reference ?? this.reference,
    );
  }
}
