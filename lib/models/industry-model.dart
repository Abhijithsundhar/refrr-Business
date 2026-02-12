import 'package:cloud_firestore/cloud_firestore.dart';

class IndustryModel {
  final String? id;
  final String name;
  final List<String> services;
  final List<String> search;
  final int noOfBusiness;
  final int noOfMarketers;
  final DateTime createTime;
  final bool delete;
  final DocumentReference? reference;

  IndustryModel({
    this.id,
    required this.name,
    required this.services,
    required this.search,
    required this.noOfBusiness,
    required this.noOfMarketers,
    required this.createTime,
    required this.delete,
    this.reference,
  });

  IndustryModel copyWith({
    String? id,
    String? name,
    List<String>? services,
    List<String>? search,
    int? noOfBusiness,
    int? noOfMarketers,
    DateTime? createTime,
    bool? delete,
    DocumentReference? reference,
  }) {
    return IndustryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      services: services ?? this.services,
      search: search ?? this.search,
      noOfBusiness: noOfBusiness ?? this.noOfBusiness,
      noOfMarketers: noOfMarketers ?? this.noOfMarketers,
      createTime: createTime ?? this.createTime,
      delete: delete ?? this.delete,
      reference: reference ?? this.reference,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'services': services,
      'search': search,
      'noOfBusiness': noOfBusiness,
      'noOfMarketers': noOfMarketers,
      'createTime': Timestamp.fromDate(createTime),
      'delete': delete,
      'reference': reference,
    };
  }

  factory IndustryModel.fromMap(
      Map<String, dynamic> map, {
        String? id,
        DocumentReference? reference,
      }) {
    return IndustryModel(
      id: id ?? map['id'] as String?,
      name: map['name'] as String? ?? '',
      services: List<String>.from(map['services'] ?? []),
      search: List<String>.from(map['search'] ?? []),
      noOfBusiness: map['noOfBusiness'] as int? ?? 0,
      noOfMarketers: map['noOfMarketers'] as int? ?? 0,
      createTime: map['createTime'] != null
          ? (map['createTime'] as Timestamp).toDate()
          : DateTime.now(),
      delete: map['delete'] as bool? ?? false,
      reference: reference ?? map['reference'] as DocumentReference?,
    );
  }

  @override
  String toString() {
    return 'IndustryModel(id: $id, name: $name, services: $services, search: $search, noOfBusiness: $noOfBusiness, noOfMarketers: $noOfMarketers, createTime: $createTime, delete: $delete)';
  }
}