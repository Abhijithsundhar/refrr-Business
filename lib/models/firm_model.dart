import 'package:cloud_firestore/cloud_firestore.dart';

class AddFirmModel {
  final String? id;
  final String name;
  final String industryType;
  final String address;
  final int phoneNo;
  final String email;
  final String website;
  final List<Map<String, dynamic>> contactPersons;
  final String logo;
  final bool delete;
  final DateTime createTime;
  final List<String> search;
  final String location;
  final String requirement;
  final String type;
  final DocumentReference? reference;

  AddFirmModel({
    this.id,
    required this.name,
    required this.industryType,
    required this.address,
    required this.phoneNo,
    required this.email,
    required this.website,
    required this.contactPersons,
    required this.logo,
    required this.delete,
    required this.createTime,
    required this.search,
    required this.location,
    required this.requirement,
    required this.type,
    this.reference,
  });

  AddFirmModel copyWith({
    String? id,
    String? name,
    String? industryType,
    String? address,
    int? phoneNo,
    String? email,
    String? website,
    List<Map<String, dynamic>>? contactPersons,
    String? logo,
    bool? delete,
    DateTime? createTime,
    List<String>? search,
    String? location,
    String? requirement,
    String? type,
    DocumentReference? reference,
  }) {
    return AddFirmModel(
      id: id ?? this.id,
      name: name ?? this.name,
      industryType: industryType ?? this.industryType,
      address: address ?? this.address,
      phoneNo: phoneNo ?? this.phoneNo,
      email: email ?? this.email,
      website: website ?? this.website,
      contactPersons: contactPersons ?? this.contactPersons,
      logo: logo ?? this.logo,
      delete: delete ?? this.delete,
      createTime: createTime ?? this.createTime,
      search: search ?? this.search,
      location: location ?? this.location,
      requirement: requirement ?? this.requirement,
      type: type ?? this.type,
      reference: reference ?? this.reference,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'industryType': industryType,
      'address': address,
      'phoneNo': phoneNo,
      'email': email,
      'website': website,
      'contactPersons': contactPersons,
      'logo': logo,
      'delete': delete,
      'createTime': Timestamp.fromDate(createTime),
      'search': search,
      'location': location,
      'requirement': requirement,
      'type': type,
      'reference': reference,
    };
  }

  factory AddFirmModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return AddFirmModel(
      id: id,
      name: map['name'] as String? ?? '',
      industryType: map['industryType'] as String? ?? '',
      address: map['address'] as String? ?? '',
      phoneNo: map['phoneNo'] as int? ?? 0,
      email: map['email'] as String? ?? '',
      website: map['website'] as String? ?? '',
      contactPersons: List<Map<String, dynamic>>.from(
        map['contactPersons'] ?? [],
      ),
      logo: map['logo'] as String? ?? '',
      delete: map['delete'] as bool? ?? false,
      createTime: (map['createTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      search: List<String>.from(map['search'] ?? []),
      location: map['location'] as String? ?? '',
      requirement: map['requirement'] as String? ?? '',
      type: map['type'] as String? ?? 'firm',
      reference: map['reference'] as DocumentReference?,
    );
  }

  /// Helper method to check if this is a firm
  bool get isFirm => type == 'firm';

  /// Helper method to check if this is a person
  bool get isPerson => type == 'person';


  @override
  String toString() {
    return 'AddFirmModel(id: $id, name: $name, type: $type, industryType: $industryType,'
        ' address: $address, phoneNo: $phoneNo, email: $email, website: $website, '
        'contactPersons: $contactPersons, logo: $logo, delete: $delete, createTime: $createTime, '
        'search: $search, location: $location,requirement: $requirement,reference: $reference)';
  }
}
