import 'package:cloud_firestore/cloud_firestore.dart';

class ZonalManagerModel {
  final String id;
  final DocumentReference? reference;
  final bool delete;
  final bool isActive;
  final String userName;
  final String password;
  final String countryId;
  final String cityId;
  final String cityName;
  final String createdType; // "auto" | "manual"
  final double totalBusiness;
  final double totalMarketers;
  final double totalRevenue;
  final double totalWithdrawals;
  final String image;

  // Zone Names (if multiple zones under one manager)
  final List<String> zonalNames;
  final List<String> businessIds;

  // Meta
  final int marketerCountAtCreation;
  final DateTime createdDate;

  const ZonalManagerModel({
    required this.id,
    this.reference,
    required this.delete,
    required this.isActive,
    required this.userName,
    required this.password,
    required this.countryId,
    required this.cityId,
    required this.cityName,
    required this.createdType,
    required this.totalBusiness,
    required this.totalMarketers,
    required this.totalRevenue,
    required this.totalWithdrawals,
    required this.zonalNames,
    required this.marketerCountAtCreation,
    required this.createdDate,
    required this.businessIds,
    required this.image,
  });

  ZonalManagerModel copyWith({
    String? id,
    DocumentReference? reference,
    bool? delete,
    bool? isActive,
    String? userName,
    String? password,
    String? countryId,
    String? cityId,
    String? cityName,
    String? createdType,
    double? totalBusiness,
    double? totalMarketers,
    double? totalRevenue,
    double? totalWithdrawals,
    List<String>? zonalNames,
    List<String>? businessIds,
    int? marketerCountAtCreation,
    DateTime? createdDate,
    String? image,
  }) {
    return ZonalManagerModel(
      id: id ?? this.id,
      reference: reference ?? this.reference,
      delete: delete ?? this.delete,
      isActive: isActive ?? this.isActive,
      userName: userName ?? this.userName,
      password: password ?? this.password,
      countryId: countryId ?? this.countryId,
      cityId: cityId ?? this.cityId,
      cityName: cityName ?? this.cityName,
      createdType: createdType ?? this.createdType,
      totalBusiness: totalBusiness ?? this.totalBusiness,
      totalMarketers: totalMarketers ?? this.totalMarketers,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalWithdrawals: totalWithdrawals ?? this.totalWithdrawals,
      zonalNames: zonalNames ?? this.zonalNames,
      marketerCountAtCreation:
      marketerCountAtCreation ?? this.marketerCountAtCreation,
      createdDate: createdDate ?? this.createdDate,
      businessIds: businessIds ?? this.businessIds,
      image: image ?? this.image,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reference': reference,
      'delete': delete,
      'isActive': isActive,
      'userName': userName,
      'password': password,
      'countryId': countryId,
      'cityId': cityId,
      'cityName': cityName,
      'createdType': createdType,
      'totalBusiness': totalBusiness,
      'totalMarketers': totalMarketers,
      'totalRevenue': totalRevenue,
      'totalWithdrawals': totalWithdrawals,
      'zonalNames': zonalNames,
      'marketerCountAtCreation': marketerCountAtCreation,
      'createdDate': Timestamp.fromDate(createdDate),
      'businessIds': businessIds,
      'image': image,
    };
  }

  factory ZonalManagerModel.fromMap(Map<String, dynamic> map) {
    return ZonalManagerModel(
      id: map['id'] ?? "",
      reference: map['reference'],
      delete: map['delete'] ?? false,
      isActive: map['isActive'] ?? true,
      userName: map['userName'] ?? "",
      password: map['password'] ?? "",
      countryId: map['countryId'] ?? "",
      cityId: map['cityId'] ?? "",
      cityName: map['cityName'] ?? "",
      createdType: map['createdType'] ?? "manual",
      totalBusiness: (map['totalBusiness'] ?? 0).toDouble(),
      totalMarketers: (map['totalMarketers'] ?? 0).toDouble(),
      totalRevenue: (map['totalRevenue'] ?? 0).toDouble(),
      totalWithdrawals: (map['totalWithdrawals'] ?? 0).toDouble(),
      zonalNames: List<String>.from(map['zonalNames'] ?? []),
      businessIds: List<String>.from(map['businessIds'] ?? []),
      marketerCountAtCreation: map['marketerCountAtCreation'] ?? 0,
      createdDate: (map['createdDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      image: map['image'] ?? "",
    );
  }
}
