import 'package:cloud_firestore/cloud_firestore.dart';

class BalanceModel {
  final double amount;
  final DateTime addedTime;
  final DocumentReference? reference;
  final String acceptBy;
  final String currency;

  BalanceModel({
    required this.amount,
    required this.addedTime,
    this.reference,
    required this.acceptBy,
    required this.currency,
  });

  BalanceModel copyWith({
    double? amount,
    DateTime? addedTime,
    DocumentReference? reference,
    String? acceptBy,
    String? currency,
  }) {
    return BalanceModel(
      amount: amount ?? this.amount,
      addedTime: addedTime ?? this.addedTime,
      reference: reference ?? this.reference,
      acceptBy: acceptBy ?? this.acceptBy,
      currency: currency ?? this.currency,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'addedTime': Timestamp.fromDate(addedTime),
      'acceptBy': acceptBy,
      'currency': currency,
      'reference': reference,
    };
  }

  factory BalanceModel.fromMap(Map<String, dynamic> map, {DocumentReference? reference}) {
    return BalanceModel(
      amount: (map['amount'] as num).toDouble(),
      addedTime: (map['addedTime'] as Timestamp).toDate(),
      acceptBy: map['acceptBy'] as String,
      currency: map['currency'] as String,
      reference: reference,
    );
  }
}
