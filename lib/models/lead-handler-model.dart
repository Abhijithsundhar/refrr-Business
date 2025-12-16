import 'package:cloud_firestore/cloud_firestore.dart';

class LeadHandlerModel {
  final String leadHandlerId;
  final String changedBy;
  final DateTime changedTime;
  final DocumentReference? reference;

  LeadHandlerModel({
    required this.leadHandlerId,
    required this.changedBy,
    required this.changedTime,
    required this.reference,
  });

  Map<String, dynamic> toMap() {
    return {
      'leadHandlerId': leadHandlerId,
      'changedBy': changedBy,
      'changedTime': changedTime,
      'reference': reference,
    };
  }
  factory LeadHandlerModel.fromMap(Map<String, dynamic> map) {
    return LeadHandlerModel(
      leadHandlerId: map['leadHandlerId'] ?? '',
      changedBy: map['changedBy'] ?? '',
      changedTime: (map['changedTime'] as Timestamp).toDate(),
      reference: map['reference'],
    );
  }

  LeadHandlerModel copyWith({
    String? leadHandlerId,
    String? changedBy,
    DateTime? changedTime,
    DocumentReference? reference,
  }) {
    return LeadHandlerModel(
      leadHandlerId: leadHandlerId ?? this.leadHandlerId,
      changedBy: changedBy ?? this.changedBy,
      changedTime: changedTime ?? this.changedTime,
      reference: reference ?? this.reference,
    );
  }
}
