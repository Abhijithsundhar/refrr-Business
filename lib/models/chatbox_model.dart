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
  ChatModel copyWith({
    String? type,
    String? chatterId,
    String? message,
    DateTime? time,
    DateTime? dateLabel,
    int? amount,
    String? description,
    String? transactionStatus,
    bool? requiresAction,
    String? imageUrl,
  }) {
    return ChatModel(
      type: type ?? this.type,
      chatterId: chatterId ?? this.chatterId,
      message: message ?? this.message,
      time: time ?? this.time,
      dateLabel: dateLabel ?? this.dateLabel,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      transactionStatus: transactionStatus ?? this.transactionStatus,
      requiresAction: requiresAction ?? this.requiresAction,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

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
