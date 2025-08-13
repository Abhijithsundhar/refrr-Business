import 'package:cloud_firestore/cloud_firestore.dart';

class AdminModel {
  final String name;
  final String phone;
  final String profile;
  final String zone;
  final String userId;
  final String password;
  final String mailId;
  final bool delete;
  final List<dynamic> search;
  final DateTime createTime;
  final DocumentReference? reference;

  AdminModel({
    required this.name,
    required this.phone,
    required this.profile,
    required this.zone,
    required this.userId,
    required this.password,
    required this.mailId,
    required this.delete,
    required this.search,
    required this.createTime,
    this.reference,
  });

  AdminModel copyWith({
    String? name,
    String? phone,
    String? profile,
    String? zone,
    String? userId,
    String? password,
    String? mailId,
    bool? delete,
    List<dynamic>? search,
    DateTime? createTime,
    DocumentReference? reference,
  }) {
    return AdminModel(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      profile: profile ?? this.profile,
      zone: zone ?? this.zone,
      userId: userId ?? this.userId,
      password: password ?? this.password,
      mailId: mailId ?? this.mailId,
      delete: delete ?? this.delete,
      search: search ?? this.search,
      createTime: createTime ?? this.createTime,
      reference: reference ?? this.reference,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'profile': profile,
      'zone': zone,
      'userId': userId,
      'password': password,
      'mailId': mailId,
      'delete': delete,
      'search': search,
      'createTime': Timestamp.fromDate(createTime),
      'reference': reference,
    };
  }

  factory AdminModel.fromMap(Map<String, dynamic> map, {DocumentReference? reference}) {
    return AdminModel(
      name: map['name'] as String,
      phone: map['phone'] as String,
      profile: map['profile'] as String,
      zone: map['zone'] as String,
      userId: map['userId'] as String,
      password: map['password'] as String,
      mailId: map['mailId'] as String,
      delete: map['delete'] as bool? ?? false,
      search: List<dynamic>.from(map['search'] ?? []),
      createTime: (map['createTime'] as Timestamp).toDate(),
      reference: map['reference'] as DocumentReference,
    );
  }
}
