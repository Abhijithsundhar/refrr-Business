import 'package:cloud_firestore/cloud_firestore.dart';

class WithdrewrequstModel {
  final int amount;
  final DateTime requstTime;
  final String acceptBy;
  final String currency;
  final bool status;
  final String? image; // 🔹 New
  final String description; // 🔹 New

  WithdrewrequstModel({
    required this.amount,
    required this.acceptBy,
    required this.currency,
    required this.status,
    required this.requstTime,
    required this.image, // 🔹 New
    required this.description, // 🔹 New
  });

  WithdrewrequstModel copyWith({
    int? amount,
    DateTime? requstTime,
    String? acceptBy,
    String? currency,
    bool? status,
    String? image, // 🔹 New
    String? description, // 🔹 New
  }) {
    return WithdrewrequstModel(
      amount: amount ?? this.amount,
      requstTime: requstTime ?? this.requstTime,
      acceptBy: acceptBy ?? this.acceptBy,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      image: image ?? this.image,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'requstTime': Timestamp.fromDate(requstTime),
      'acceptBy': acceptBy,
      'currency': currency,
      'status': status,
      'image': image, // 🔹 New
      'description': description, // 🔹 New
    };
  }

  factory WithdrewrequstModel.fromMap(Map<String, dynamic> map) {
    return WithdrewrequstModel(
      amount: map['amount'] as int,
      requstTime: (map['requstTime'] as Timestamp).toDate(),
      acceptBy: map['acceptBy'] as String,
      currency: map['currency'] as String,
      status: map['status'] as bool,
      image: map['image'] as String? ?? '', // 🔹 Defensive
      description: map['description'] as String? ?? '', // 🔹 Defensive
    );
  }
}
