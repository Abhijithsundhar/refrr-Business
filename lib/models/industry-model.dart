import 'package:cloud_firestore/cloud_firestore.dart';

class IndustryModel {
  final String industryName;
  final List<String> services;
  final DocumentReference? reference;
  final String? id;

  IndustryModel({
    required this.industryName,
    required this.services,
    this.reference,
    this.id,
  });

  IndustryModel copyWith({
    String? industryName,
    List<String>? services,
    DocumentReference? reference,
    String? id,
  }) {
    return IndustryModel(
      industryName: industryName ?? this.industryName,
      services: services ?? this.services,
      reference: reference ?? this.reference,
      id: id ?? this.id,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'industryName': industryName,
      'services': services,
      'reference': reference,
      'id': id,
    };
  }

  factory IndustryModel.fromMap(Map<String, dynamic> map, {DocumentReference? reference}) {
    return IndustryModel(
      industryName: map['industryName'] ?? '',
      services: List<String>.from(map['services'] ?? []),
      reference: reference ?? map['reference'],
      id: map['id'] ?? '',
    );
  }
}