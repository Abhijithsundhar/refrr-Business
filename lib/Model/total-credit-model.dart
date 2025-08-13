import 'package:cloud_firestore/cloud_firestore.dart';

class TotalCreditModel {
  final double amount;
  final DateTime addedTime;
  final String acceptBy;
  final String currency;
  final String? image;
  final String description;

  TotalCreditModel({
    required this.amount,
    required this.addedTime,
    required this.acceptBy,
    required this.currency,
    this.image,
    required this.description,
  });

  TotalCreditModel copyWith({
    double? amount,
    DateTime? addedTime,
    String? acceptBy,
    String? currency,
    String? image,
    String? description,
  }) {
    return TotalCreditModel(
      amount: amount ?? this.amount,
      addedTime: addedTime ?? this.addedTime,
      acceptBy: acceptBy ?? this.acceptBy,
      currency: currency ?? this.currency,
      image: image ?? this.image,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'addedTime': Timestamp.fromDate(addedTime),
      'acceptBy': acceptBy,
      'currency': currency,
      'image': image,
      'description': description,
    };
  }

  factory TotalCreditModel.fromMap(Map<String, dynamic> map, {DocumentReference? reference}) {
    return TotalCreditModel(
      amount: (map['amount'] as num).toDouble(),
      addedTime: (map['addedTime'] as Timestamp).toDate(),
      acceptBy: map['acceptBy'] as String,
      currency: map['currency'] as String,
      image: map['image'] as String,
      description: map['description'] as String,
    );
  }
}
