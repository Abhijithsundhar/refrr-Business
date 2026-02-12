import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:refrr_admin/models/affiliate-model.dart';
import 'package:refrr_admin/models/services-model.dart';

class LeadsModel {
  final String logo;
  final String name;
  final String industry;
  final String contactNo;
  final String mail;
  final String country;
  final String zone;
  final String website;
  final String currency;
  final String address;
  final String aboutFirm;
  final bool delete;
  final List<dynamic> search;
  final DateTime createTime;
  final String addedBy;
  final List<ServiceModel> services;
  final int status;
  final String affiliate;
  final String password;
  final String organizationType;
  final List<String> teamMembers;
  final List<AffiliateModel> applications;
  final List<dynamic> jobType;
  final List<dynamic> lookingAt;

  /// 🔹 Added / merged fields
  final String plan;       // basic / moderate / high
  final int teamLimit;

  final DocumentReference? reference;

  LeadsModel({
    required this.logo,
    required this.name,
    required this.industry,
    required this.contactNo,
    required this.mail,
    required this.country,
    required this.zone,
    required this.website,
    required this.currency,
    required this.address,
    required this.aboutFirm,
    required this.delete,
    required this.search,
    required this.createTime,
    required this.addedBy,
    required this.services,
    required this.status,
    required this.affiliate,
    required this.password,
    required this.organizationType,
    required this.teamMembers,
    required this.applications,
    required this.jobType,
    required this.lookingAt,
    required this.plan,
    required this.teamLimit,
    this.reference,
  });

  LeadsModel copyWith({
    String? logo,
    String? name,
    String? industry,
    String? contactNo,
    String? mail,
    String? country,
    String? zone,
    String? website,
    String? currency,
    String? address,
    String? aboutFirm,
    bool? delete,
    List<dynamic>? search,
    DateTime? createTime,
    String? addedBy,
    List<ServiceModel>? services,
    int? status,
    String? affiliate,
    String? password,
    String? organizationType,
    List<String>? teamMembers,
    List<AffiliateModel>? applications,
    List<dynamic>? jobType,
    List<dynamic>? lookingAt,
    String? plan,
    int? teamLimit,
    DocumentReference? reference,
  }) {
    return LeadsModel(
      logo: logo ?? this.logo,
      name: name ?? this.name,
      industry: industry ?? this.industry,
      contactNo: contactNo ?? this.contactNo,
      mail: mail ?? this.mail,
      country: country ?? this.country,
      zone: zone ?? this.zone,
      website: website ?? this.website,
      currency: currency ?? this.currency,
      address: address ?? this.address,
      aboutFirm: aboutFirm ?? this.aboutFirm,
      delete: delete ?? this.delete,
      search: search ?? this.search,
      createTime: createTime ?? this.createTime,
      addedBy: addedBy ?? this.addedBy,
      services: services ?? this.services,
      status: status ?? this.status,
      affiliate: affiliate ?? this.affiliate,
      password: password ?? this.password,
      organizationType: organizationType ?? this.organizationType,
      teamMembers: teamMembers ?? this.teamMembers,
      applications: applications ?? this.applications,
      jobType: jobType ?? this.jobType,
      lookingAt: lookingAt ?? this.lookingAt,
      plan: plan ?? this.plan,
      teamLimit: teamLimit ?? this.teamLimit,
      reference: reference ?? this.reference,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'logo': logo,
      'name': name,
      'industry': industry,
      'contactNo': contactNo,
      'mail': mail,
      'country': country,
      'zone': zone,
      'website': website,
      'currency': currency,
      'address': address,
      'aboutFirm': aboutFirm,
      'delete': delete,
      'search': search,
      'createTime': Timestamp.fromDate(createTime),
      'addedBy': addedBy,
      'services': services.map((s) => s.toMap()).toList(),
      'status': status,
      'affiliate': affiliate,
      'password': password,
      'organizationType': organizationType,
      'teamMembers': teamMembers,
      'applications': applications.map((a) => a.toMap()).toList(),
      'jobType': jobType,
      'lookingAt': lookingAt,
      'plan': plan,
      'teamLimit': teamLimit,
      'reference': reference,
    };
  }

  factory LeadsModel.fromMap(
      Map<String, dynamic> map, {
        DocumentReference? reference,}) {
    return LeadsModel(
      logo: map['logo'] as String? ?? '',
      name: map['name'] as String? ?? '',
      industry: map['industry'] as String? ?? '',
      contactNo: map['contactNo'] as String? ?? '',
      mail: map['mail'] as String? ?? '',
      country: map['country'] as String? ?? '',
      zone: map['zone'] as String? ?? '',
      website: map['website'] as String? ?? '',
      currency: map['currency'] as String? ?? '',
      address: map['address'] as String? ?? '',
      aboutFirm: map['aboutFirm'] as String? ?? '',
      delete: map['delete'] as bool? ?? false,
      search: List<dynamic>.from(map['search'] ?? []),
      createTime: (map['createTime'] as Timestamp).toDate(),
      addedBy: map['addedBy'] as String? ?? '',
      services: (map['services'] as List<dynamic>? ?? [])
          .map((e) => ServiceModel.fromMap(e as Map<String, dynamic>)).toList(),
      status: map['status'] as int? ?? 0,
      affiliate: map['affiliate'] as String? ?? '',
      password: map['password'] as String? ?? '',
      organizationType: map['organizationType'] as String? ?? '',
      teamMembers:List<String>.from(map['teamMembers'] ?? []) ,
      applications: (map['applications'] as List<dynamic>? ?? [])
          .map((e) => AffiliateModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      jobType: (map['jobType'] as List?)?.map((e) => e.toString()).toList() ?? [],
      lookingAt: (map['lookingAt'] as List?)?.map((e) => e.toString()).toList() ?? [],
      plan: map['plan'] as String? ?? 'basic',
      teamLimit: map['teamLimit'] as int? ?? 0,
      reference: reference ?? map['reference'] as DocumentReference?,
    );
  }
}
