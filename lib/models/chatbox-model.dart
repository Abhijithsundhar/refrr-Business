import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String type; // date_label, simple, transaction, action, text, status_update
  final String chatterId;
  final String? message;
  final DateTime? time;
  // For date label
  final DateTime? dateLabel;
  // For transaction
  final int? amount;
  final String? description;
  final String? transactionStatus;
  // For action message
  final bool? requiresAction;
  final String? imageUrl;

  ChatModel({
    required this.type,
    required this.chatterId,
    this.message,
    this.time,
    this.dateLabel,
    this.amount,
    this.description,
    this.transactionStatus,
    this.requiresAction,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'chatterId': chatterId,
      'message': message,
      'time': time,
      'dateLabel': dateLabel,
      'amount': amount,
      'description': description,
      'transactionStatus': transactionStatus,
      'requiresAction': requiresAction,
      'imageUrl': imageUrl,
    };
  }

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      type: map['type'] ?? '',
      chatterId: map['chatterId'] ?? '',
      message: map['message'],
      dateLabel:(map['dateLabel'] as Timestamp).toDate(),
      time: (map['time'] as Timestamp).toDate(),
      amount: map['amount'],
      description: map['description'],
      transactionStatus: map['transactionStatus'],
      requiresAction: map['requiresAction'],
      imageUrl: map['imageUrl'],
    );
  }
}
