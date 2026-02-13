import 'package:cloud_firestore/cloud_firestore.dart';

class SalesPersonModel {
  // 🔹 Basic Sales Person Info
  final String name;
  final String phoneNumber;
  final String addedBy;
  final String profile;
  final String email;
  final String firmName;

  // 🔹 Lead Handler Info
  final String? leadHandlerId;
  final String changedBy;
  final DateTime changedTime;

  // 🔹 NEW FIELD
  final bool currentHandler;

  // 🔹 Created Time
  final DateTime createdAt;

  // 🔹 Firebase Document Reference
  final DocumentReference? reference;

  SalesPersonModel({
    required this.name,
    required this.phoneNumber,
    required this.addedBy,
    required this.profile,
    required this.email,
    required this.firmName,
     this.leadHandlerId,
    required this.changedBy,
    required this.changedTime,
    required this.currentHandler,
    required this.createdAt,
    this.reference,
  });

  /// ------------------------------------------------
  /// 🔄 Firestore Map → Model
  /// ------------------------------------------------
  factory SalesPersonModel.fromMap(Map<String, dynamic> map,) {
    return SalesPersonModel(
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      addedBy: map['addedBy'] ?? '',
      profile: map['profile'] ?? '',
      email: map['email'] ?? '',
      firmName: map['firmName'] ?? '',
      leadHandlerId: map['leadHandlerId'] ?? '',
      changedBy: map['changedBy'] ?? '',
      changedTime: (map['changedTime'] as Timestamp).toDate(),
      currentHandler: map['currentHandler'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      reference: map['reference'],
    );
  }

  /// ------------------------------------------------
  /// 🔄 Model → Firestore Map
  /// ------------------------------------------------
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'addedBy': addedBy,
      'profile': profile,
      'email': email,
      'firmName': firmName,
      'leadHandlerId': leadHandlerId,
      'changedBy': changedBy,
      'changedTime': changedTime,
      'currentHandler': currentHandler,
      'createdAt': createdAt,
      'reference':reference
    };
  }

  /// ------------------------------------------------
  /// ✏️ Copy With
  /// ------------------------------------------------
  SalesPersonModel copyWith({
    String? name,
    String? phoneNumber,
    String? addedBy,
    String? profile,
    String? email,
    String? firmName,
    String? leadHandlerId,
    String? changedBy,
    DateTime? changedTime,
    bool? currentHandler,
    DateTime? createdAt,
    DocumentReference? reference,
  }) {
    return SalesPersonModel(
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      addedBy: addedBy ?? this.addedBy,
      profile: profile ?? this.profile,
      email: email ?? this.email,
      firmName: firmName ?? this.firmName,
      leadHandlerId: leadHandlerId ?? this.leadHandlerId,
      changedBy: changedBy ?? this.changedBy,
      changedTime: changedTime ?? this.changedTime,
      currentHandler: currentHandler ?? this.currentHandler,
      createdAt: createdAt ?? this.createdAt,
      reference: reference ?? this.reference,
    );
  }
}
