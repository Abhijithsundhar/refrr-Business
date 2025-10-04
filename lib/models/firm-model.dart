import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:refrr_admin/models/contact-person-model.dart';
import 'package:refrr_admin/models/services-model.dart';


class AddFirmModel {
  final String name;
  final String industryType;
  final String service;
  final String address;
  final int phoneNo;
  final String email;
  final String? website;
  final List<ContactPersonModel> contactPersons;
  final String logo;
  final String addFile;
  final String marketerId;
  final bool delete;
  final DateTime createTime;
  final DocumentReference? reference;
  final List<ServiceModel>? services;
  final String status;
  final List<dynamic> search;
  final String location;
  final String requirement;

  AddFirmModel({
    required this.name,
    required this.industryType,
    required this.service,
    required this.address,
    required this.phoneNo,
    required this.email,
    this.website,
    required this.contactPersons,
    required this.logo,
    required this.addFile,
    required this.marketerId,
    required this.delete,
    required this.createTime,
    this.reference,
    this.services,
    required this.status,
    required this.search,
    required this.location,
    required this.requirement,
  });

  AddFirmModel copyWith({
    String? name,
    String? industryType,
    String? service,
    String? address,
    int? phoneNo,
    String? email,
    String? website,
    List<ContactPersonModel>? contactPersons,
    String? logo,
    String? addFile,
    String? marketerId,
    bool? delete,
    DateTime? createTime,
    DocumentReference? reference,
    List<ServiceModel>? services,
    String? status,
    List<dynamic>? search,
    String? location,
    String? requirement,
  }) {
    return AddFirmModel(
      name: name ?? this.name,
      industryType: industryType ?? this.industryType,
      service: service ?? this.service,
      address: address ?? this.address,
      phoneNo: phoneNo ?? this.phoneNo,
      email: email ?? this.email,
      website: website ?? this.website,
      contactPersons: contactPersons ?? this.contactPersons,
      logo: logo ?? this.logo,
      addFile: addFile ?? this.addFile,
      marketerId: marketerId ?? this.marketerId,
      delete: delete ?? this.delete,
      createTime: createTime ?? this.createTime,
      reference: reference ?? this.reference,
      services: services ?? this.services,
      status: status ?? this.status,
      search: search ?? this.search,
      location: location ?? this.location,
      requirement: requirement ?? this.requirement,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'industryType': industryType,
      'service': service,
      'address': address,
      'phoneNo': phoneNo,
      'email': email,
      'website': website,
      'contactPersons': contactPersons.map((e) => e.toMap()).toList(),
      'logo': logo,
      'addFile': addFile,
      'marketerId': marketerId,
      'delete': delete,
      'createTime': Timestamp.fromDate(createTime),
      'reference': reference,
      'services': services?.map((e) => e.toMap()).toList(),
      'status': status,
      'search': search,
      'location': location,
      'requirement': requirement,
    };
  }

  factory AddFirmModel.fromMap(Map<String, dynamic> map, {DocumentReference? reference}) {
    return AddFirmModel(
      name: map['name']?.toString() ?? '',
      industryType: map['industryType']?.toString() ?? '',
      service: map['service']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      phoneNo: map['phoneNo'] is int ? map['phoneNo'] : int.tryParse(map['phoneNo']?.toString() ?? '0') ?? 0,
      email: map['email']?.toString() ?? '',
      website: map['website']?.toString(),
      contactPersons: (map['contactPersons'] as List<dynamic>? ?? []).whereType<Map<String, dynamic>>().map((e) => ContactPersonModel.fromMap(e)).toList(),
      logo: map['logo']?.toString() ?? '',
      addFile: map['addFile']?.toString() ?? '',
      marketerId: map['marketerId']?.toString() ?? '',
      delete: map['delete'] as bool? ?? false,
      createTime: (map['createTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      // createTime: map['createTime'] is Timestamp
      //     ? map['createTime']
      //     : Timestamp.fromDate(DateTime.parse(map['createdAt'])),
      reference: map['reference'] as DocumentReference,
      services: (map['services'] as List<dynamic>? ?? []).whereType<Map<String, dynamic>>().map((e) => ServiceModel.fromMap(e)).toList(),
      status: map['status']?.toString() ?? '',
      search: List<dynamic>.from(map['search'] ?? []),
      location: map['location']?.toString() ?? '',
      requirement: map['requirement']?.toString() ?? '',
    );
  }
}
