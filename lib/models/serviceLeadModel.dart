import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:refrr_admin/models/add-money-on-lead-model.dart';
import 'package:refrr_admin/models/chatbox-model.dart';
import 'package:refrr_admin/models/sales-person-model.dart';

class ServiceLeadModel {
  final String leadName;
  final String leadLogo;
  final String firmName;
  final String marketerId;
  final String marketerName;
  final String serviceName;
  final String location;
  final String leadEmail;
  final int leadContact;
  final List<Map<String, dynamic>> statusHistory;
  final DocumentReference? reference;
  final DateTime createTime;
  final int leadScore;
  final List<PaymentModel> creditedAmount;
  final List<SalesPersonModel> leadHandler;
  final List<ChatModel> chat;

  /// 👉 NEW FIELD
  final String type;

  ServiceLeadModel({
    required this.leadName,
    required this.leadLogo,
    required this.firmName,
    required this.marketerId,
    required this.marketerName,
    required this.serviceName,
    required this.statusHistory,
    required this.reference,
    required this.createTime,
    required this.leadScore,
    required this.location,
    required this.creditedAmount,
    required this.leadEmail,
    required this.leadContact,
    required this.leadHandler,
    required this.chat,

    /// 👉 NEW
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'leadName': leadName,
      'leadLogo': leadLogo,
      'firmName': firmName,
      'marketerId': marketerId,
      'marketerName': marketerName,
      'serviceName': serviceName,
      'statusHistory': statusHistory,
      'reference': reference,
      'createTime': createTime,
      'leadScore': leadScore,
      'location': location,
      'creditedAmount': creditedAmount.map((e) => e.toMap()).toList(),
      'leadEmail': leadEmail,
      'leadContact': leadContact,
      'leadHandler': leadHandler.map((e) => e.toMap()).toList(),
      'chat': chat.map((e) => e.toMap()).toList(),

      /// 👉 NEW
      'type': type,
    };
  }

  factory ServiceLeadModel.fromMap(Map<String, dynamic> map) {
    return ServiceLeadModel(
      leadName: map['leadName'] ?? '',
      leadLogo: map['leadLogo'] ?? '',
      firmName: map['firmName'] ?? '',
      marketerId: map['marketerId'] ?? '',
      marketerName: map['marketerName'] ?? '',
      serviceName: map['serviceName'] ?? '',
      statusHistory: List<Map<String, dynamic>>.from(map['statusHistory'] ?? []),
      reference: map['reference'],
      createTime: (map['createTime'] as Timestamp).toDate(),
      leadScore: map['leadScore'] ?? 0,
      location: map['location'] ?? '',
      creditedAmount: (map['creditedAmount'] as List<dynamic>? ?? [])
          .map((e) => PaymentModel.fromMap(e))
          .toList(),
      leadEmail: map['leadEmail'] ?? '',
      leadContact: map['leadContact'] ?? 0,
      leadHandler: (map['leadHandler'] as List<dynamic>? ?? [])
          .map((e) => SalesPersonModel.fromMap(e))
          .toList(),
      chat: (map['chat'] as List<dynamic>? ?? [])
          .map((e) => ChatModel.fromMap(e))
          .toList(),

      /// 👉 NEW
      type: map['type'] ?? '',
    );
  }

  ServiceLeadModel copyWith({
    String? leadName,
    String? leadLogo,
    String? firmName,
    String? marketerId,
    String? marketerName,
    String? serviceName,
    List<Map<String, dynamic>>? statusHistory,
    DocumentReference? reference,
    DateTime? createTime,
    int? leadScore,
    String? location,
    List<PaymentModel>? creditedAmount,
    String? leadEmail,
    int? leadContact,
    List<SalesPersonModel>? leadHandler,
    List<ChatModel>? chat,

    /// 👉 NEW
    String? type,
  }) {
    return ServiceLeadModel(
      leadName: leadName ?? this.leadName,
      leadLogo: leadLogo ?? this.leadLogo,
      firmName: firmName ?? this.firmName,
      marketerId: marketerId ?? this.marketerId,
      marketerName: marketerName ?? this.marketerName,
      serviceName: serviceName ?? this.serviceName,
      statusHistory: statusHistory ?? this.statusHistory,
      reference: reference ?? this.reference,
      createTime: createTime ?? this.createTime,
      leadScore: leadScore ?? this.leadScore,
      location: location ?? this.location,
      creditedAmount: creditedAmount ?? this.creditedAmount,
      leadEmail: leadEmail ?? this.leadEmail,
      leadContact: leadContact ?? this.leadContact,
      leadHandler: leadHandler ?? this.leadHandler,
      chat: chat ?? this.chat,

      /// 👉 NEW
      type: type ?? this.type,
    );
  }
}
