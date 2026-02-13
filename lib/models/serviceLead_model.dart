import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:refrr_admin/models/addMoney_model.dart';
import 'package:refrr_admin/models/chatbox_model.dart';
import 'package:refrr_admin/models/salesperson_model.dart';


class ServiceLeadModel {
  final String leadName;
  final String leadLogo;

  /// ✅ NEW FIELD
  final String firmId;
  final String firmLocation;

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
  final String type;
  final String leadFor;
  final String marketerLocation;

  /// distinguish between product / service
  final String leadType;

  final bool delete;
  final bool hide;
  final String category;

  ServiceLeadModel({
    required this.leadName,
    required this.leadLogo,
    required this.firmId,
    required this.firmName,
    required this.marketerId,
    required this.marketerName,
    required this.serviceName,
    required this.statusHistory,
    this.reference,
    required this.createTime,
    required this.leadScore,
    required this.location,
    required this.creditedAmount,
    required this.leadEmail,
    required this.leadContact,
    required this.leadHandler,
    required this.chat,
    required this.type,
    required this.leadFor,
    required this.marketerLocation,
    required this.leadType,
    required this.delete,
    required this.hide,
    required this.category,
    required this.firmLocation,
  });

  Map<String, dynamic> toMap() {
    return {
      'leadName': leadName,
      'leadLogo': leadLogo,
      'firmId': firmId,
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
      'type': type,
      'leadFor': leadFor,
      'marketerLocation': marketerLocation,
      'leadType': leadType,
      'delete': delete,
      'hide': hide,
      'category': category,
      'firmLocation': firmLocation,
    };
  }

  factory ServiceLeadModel.fromMap(Map<String, dynamic> map) {
    return ServiceLeadModel(
      leadName: map['leadName'] ?? '',
      leadLogo: map['leadLogo'] ?? '',
      firmId: map['firmId'] ?? '',
      firmName: map['firmName'] ?? '',
      marketerId: map['marketerId'] ?? '',
      marketerName: map['marketerName'] ?? '',
      serviceName: map['serviceName'] ?? '',
      statusHistory:
      List<Map<String, dynamic>>.from(map['statusHistory'] ?? []),
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
      type: map['type'] ?? '',
      leadFor: map['leadFor'] ?? '',
      marketerLocation: map['marketerLocation'] ?? '',
      leadType: map['leadType'] ?? 'service',
      delete: map['delete'] ?? false,
      hide: map['hide'] ?? false,
      category: map['category'] ?? '',
      firmLocation: map['firmLocation'] ?? '',
    );
  }

  ServiceLeadModel copyWith({
    String? leadName,
    String? leadLogo,
    String? firmId,
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
    String? type,
    String? leadFor,
    String? marketerLocation,
    String? leadType,
    bool? hide,
    bool? delete,
    String? category,
    String? firmLocation,
  }) {
    return ServiceLeadModel(
      leadName: leadName ?? this.leadName,
      leadLogo: leadLogo ?? this.leadLogo,
      firmId: firmId ?? this.firmId,
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
      type: type ?? this.type,
      leadFor: leadFor ?? this.leadFor,
      marketerLocation: marketerLocation ?? this.marketerLocation,
      leadType: leadType ?? this.leadType,
      delete: delete ?? this.delete,
      hide: hide ?? this.hide,
      category: category ?? this.category,
      firmLocation: firmLocation ?? this.firmLocation,
    );
  }

  @override
  String toString() {
    return 'ServiceLeadModel(leadName: $leadName, firmId: $firmId, '
        'firmName: $firmName, serviceName: $serviceName, '
        'type: $type, leadFor: $leadFor, location: $location, '
        'marketerLocation: $marketerLocation, leadType: $leadType, '
        'leadScore: $leadScore)';
  }
}
