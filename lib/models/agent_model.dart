import 'package:cloud_firestore/cloud_firestore.dart';

class AgentModel {
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
  final List<AgentModel> subAgents; // recursive field

  AgentModel({
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
    this.subAgents = const [],
  });

  AgentModel copyWith({
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
    List<AgentModel>? subAgents,
  }) {
    return AgentModel(
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
      subAgents: subAgents ?? this.subAgents,
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
      'subAgents': subAgents.map((e) => e.toMap()).toList(),
    };
  }

  factory AgentModel.fromMap(Map<String, dynamic> map, {DocumentReference? reference}) {
    return AgentModel(
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      profile: map['profile'] ?? '',
      zone: map['zone'] ?? '',
      userId: map['userId'] ?? '',
      password: map['password'] ?? '',
      mailId: map['mailId'] ?? '',
      delete: map['delete'] ?? false,
      search: List<dynamic>.from(map['search'] ?? []),
      createTime: (map['createTime'] as Timestamp).toDate(),
      reference: reference ?? map['reference'],
      subAgents: (map['subAgents'] as List<dynamic>?)?.map((e) =>
          AgentModel.fromMap(Map<String, dynamic>.from(e))).toList() ?? [],
    );
  }
}
