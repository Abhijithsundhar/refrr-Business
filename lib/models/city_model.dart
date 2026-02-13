import 'package:cloud_firestore/cloud_firestore.dart';

class CityModel {
  final String? id;
  final DocumentReference? reference;
  final String zone;
  final String country;
  final String profile;
  final bool isDeleted;
  final bool isZone;
  final DateTime createdTime;
  final int  marketerCount;
  final int  totalBusinessCount;

  CityModel({
    this.id,
    this.reference,
    required this.zone,
    required this.country,
    required this.profile,
    required this. marketerCount,
    required this. totalBusinessCount,
    required this. isZone,
    this.isDeleted = false,
    DateTime? createdTime,
  }) : createdTime = createdTime ?? DateTime.now();

  /// Convert model → Map (Firestore / API)
  Map<String, dynamic> toMap() {
    return {
      'zone': zone,
      'country': country,
      'profile': profile,
      'isDeleted': isDeleted,
      'createdTime': Timestamp.fromDate(createdTime),
      'id': id,
      'reference': reference,
      'marketerCount':  marketerCount,
      'isZone':  isZone,
      'totalBusinessCount':  totalBusinessCount,
    };
  }

  /// Create model from Firestore Map
  factory CityModel.fromMap(
      Map<String, dynamic> map, {
        String id = '',
        DocumentReference? reference,
      }) {
    return CityModel(
      id: id,
      reference: reference,
      zone: map['zone'] ?? '',
      country: map['country'] ?? '',
      profile: map['profile'] ?? '',
      marketerCount: map['marketerCount'] ?? 0,
      totalBusinessCount: map['totalBusinessCount'] ?? 0,
      isDeleted: map['isDeleted'] ?? false,
      isZone: map['isZone'] ?? false,
      createdTime: map['createdTime'] is Timestamp
          ? (map['createdTime'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Copy with (update / soft delete)
  CityModel copyWith({
    String? id,
    DocumentReference? reference,
    String? zone,
    String? country,
    String? profile,
    bool? isDeleted,
    bool? isZone,
    DateTime? createdTime,
    int?  marketerCount,
    int?  totalBusinessCount,
  }) {
    return CityModel(
      id: id ?? this.id,
      reference: reference ?? this.reference,
      zone: zone ?? this.zone,
      country: country ?? this.country,
      profile: profile ?? this.profile,
      isDeleted: isDeleted ?? this.isDeleted,
      createdTime: createdTime ?? this.createdTime,
      marketerCount:  marketerCount ?? this. marketerCount,
      isZone:  isZone ?? this. isZone,
      totalBusinessCount:  totalBusinessCount ?? this. totalBusinessCount,
    );
  }
}
