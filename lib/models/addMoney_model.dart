import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final int amount;
  final DateTime date;
  final String added;
  final String remarks;
  final String receiver;

  PaymentModel({
    required this.amount,
    required this.date,
    required this.added,
    required this.remarks,
    required this.receiver,
  });

  // Convert model → Map (for Firebase)
  Map<String, dynamic> toMap() {
    return {
      "amount": amount,
      "date": Timestamp.fromDate(date),
      "added": added,
      "remarks": remarks,
      "receiver": receiver,
    };
  }

  // Convert Map → Model (for reading from Firebase)
  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      amount: map["amount"] ?? 0,
      date: (map['date'] as Timestamp).toDate(),
      added: map["added"] ?? "",
      remarks: map["remarks"] ?? "",
      receiver: map["receiver"] ?? "",
    );
  }
}
