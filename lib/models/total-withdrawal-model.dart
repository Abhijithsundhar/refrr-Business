import 'package:cloud_firestore/cloud_firestore.dart';

class TotalWithdrawalsModel {
  final double amount;
  final DateTime addedTime;
  final String acceptBy;
  final String currency;
  final int status;
  final String? image;
  final String description;

  TotalWithdrawalsModel({
    required this.amount,
    required this.addedTime,
    required this.acceptBy,
    required this.currency,
    required this.status,
    this.image,
    required this.description,
  });

  TotalWithdrawalsModel copyWith({
    double? amount,
    DateTime? addedTime,
    String? acceptBy,
    String? currency,
    int? status,
    String? image,
    String? description,
  }) {
    return TotalWithdrawalsModel(
      amount: amount ?? this.amount,
      addedTime: addedTime ?? this.addedTime,
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
      'addedTime': Timestamp.fromDate(addedTime),
      'acceptBy': acceptBy,
      'currency': currency,
      'status': status,
      'image': image,
      'description': description,
    };
  }

  factory TotalWithdrawalsModel.fromMap(Map<String, dynamic> map, {DocumentReference? reference}) {
    return TotalWithdrawalsModel(
      amount: (map['amount'] as num).toDouble(),
      addedTime: (map['addedTime'] as Timestamp).toDate(),
      acceptBy: map['acceptBy'] as String,
      currency: map['currency'] as String,
      status: map['status'] ?? 0,
      image: map['image'] as String,
      description: map['description'] as String,// Provide default if missing
    );
  }
}
