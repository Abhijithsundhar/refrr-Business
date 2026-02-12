import 'package:cloud_firestore/cloud_firestore.dart';

class WithdrewrequstModel {
  final int amount;
  final DateTime requstTime;
  final String acceptedBy;
  final String currency;
  final String? image; // 🔹 New
  final String description;
  final String leadId; // 🔹 New
  final DateTime? acceptedTime;
  final String affiliateId;
  final int status;
  final String? id;

  WithdrewrequstModel({
    required this.amount,
    required this.acceptedBy,
    required this.currency,
    required this.requstTime,
    required this.image, // 🔹 New
    required this.description, // 🔹 New
    required this.leadId, // 🔹 New
    required this.affiliateId,
    required this.acceptedTime,
    required this.status,
    required this.id,
  });

  WithdrewrequstModel copyWith({
    int? amount,
    DateTime? requstTime,
    String? acceptBy,
    String? currency,
    String? image, // 🔹 New
    String? description, // 🔹 New
    String? leadId, // 🔹 New
    String? affiliateId,
    DateTime? acceptedTime,
    int? status,
    String? id,
  }) {
    return WithdrewrequstModel(
      amount: amount ?? this.amount,
      requstTime: requstTime ?? this.requstTime,
      acceptedBy: acceptBy ?? this.acceptedBy,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      image: image ?? this.image,
      description: description ?? this.description,
      leadId: leadId ?? this.leadId,
      affiliateId: affiliateId ?? this.affiliateId,
      acceptedTime: acceptedTime ?? this.acceptedTime,
      id: id ?? this.id,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'requstTime': Timestamp.fromDate(requstTime),
      'acceptedBy': acceptedBy,
      'currency': currency,
      'status': status,
      'image': image, // 🔹 New
      'description': description, // 🔹 New
      'leadId': leadId, // 🔹 New
      'affiliateId': affiliateId,
      if (acceptedTime != null)'acceptedTime': Timestamp.fromDate(acceptedTime!),
      'id': id
    };
  }

  factory WithdrewrequstModel.fromMap(Map<String, dynamic> map) {
    return WithdrewrequstModel(
      amount: map['amount'] as int,
      requstTime: (map['requstTime'] as Timestamp).toDate(),
      acceptedBy: map['acceptedBy'] as String,
      currency: map['currency'] as String,
      status: map['status'] as int,
      image: map['image'] as String? ?? '', // 🔹 Defensive
      description: map['description'] as String? ?? '', // 🔹 Defensive
      leadId: map['leadId'] as String? ?? '', // 🔹 Defensive
      affiliateId: map['affiliateId'] as String,
      acceptedTime: map['acceptedTime'] != null
          ? (map['acceptedTime'] as Timestamp).toDate() : null,
      id: map['id'] as String,
    );
  }
}