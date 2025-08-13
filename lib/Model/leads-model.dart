import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:refrr_admin/Model/affiliate-model.dart';
import 'firm-model.dart';

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
  final List<AddFirmModel> firms;
  final int status;
  final String affiliate;
  final String? password;
  final List<AffiliateModel> teamMembers;
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
    required this.firms,
    required this.status,
    required this.affiliate,
    required this.teamMembers, // ✅ Constructor
    this.password,
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
    List<AddFirmModel>? firms,
    int? status,
    String? affiliate,
    String? password,
    List<AffiliateModel>? teamMembers, // ✅ CopyWith
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
      firms: firms ?? this.firms,
      status: status ?? this.status,
      affiliate: affiliate ?? this.affiliate,
      teamMembers: teamMembers ?? this.teamMembers, // ✅ copyWith updated
      password: password ?? this.password,
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
      'firms': firms.map((f) => f.toMap()).toList(),
      'status': status,
      'affiliate': affiliate,
      'teamMembers': teamMembers, // ✅ Added in toMap
      'password': password,
      'reference': reference,
    };
  }

  factory LeadsModel.fromMap(Map<String, dynamic> map, {DocumentReference? reference}) {
    return LeadsModel(
      logo: map['logo'] as String,
      name: map['name'] as String,
      industry: map['industry'] as String,
      contactNo: map['contactNo'] as String,
      mail: map['mail'] as String,
      country: map['country'] as String,
      zone: map['zone'] as String,
      website: map['website'] as String,
      currency: map['currency'] as String,
      address: map['address'] as String,
      aboutFirm: map['aboutFirm'] as String,
      delete: map['delete'] as bool? ?? false,
      search: List<dynamic>.from(map['search'] ?? []),
      createTime: (map['createTime'] as Timestamp).toDate(),
      addedBy: map['addedBy'] as String,
      firms: map['firms'] != null ? List<AddFirmModel>.from((map['firms'] as List)
              .where((e) => e != null).map((e) => AddFirmModel.fromMap(e as Map<String, dynamic>))) : [],
      status: map['status'] as int? ?? 0,
      affiliate: map['affiliate'] as String? ?? '',
      teamMembers:map['teamMembers'] != null
          ? List<AffiliateModel>.from(
          (map['teamMembers'] as List)
              .where((e) => e != null)
              .map((e) => AffiliateModel.fromMap(e as Map<String, dynamic>))) : [],
      password: map['password'] as String? ?? '',
      reference: map['reference'] is DocumentReference ? map['reference'] as DocumentReference : null,
    );
  }
}