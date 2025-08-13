import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceLeadModel {
  final String leadName;
  final String leadLogo;
  final String firmName;
  final String marketerId;
  final String marketerName;
  final String serviceName;
  final String location;
  final List<Map<String, dynamic>> statusHistory; // New status history list
  final DocumentReference? reference;
  final DateTime createTime;
  final int leadScore;

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
  });

  /// Convert this object into a Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'leadName': leadName,
      'leadLogo': leadLogo,
      'firmName': firmName,
      'marketerId': marketerId,
      'marketerName': marketerName,
      'serviceName': serviceName,
      'statusHistory': statusHistory,
      'reference': reference, // Firestore can store DocumentReference directly
      'createTime': createTime,
      'leadScore': leadScore,
      'location': location,
    };
  }

  /// Create a model from Firestore document
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
    );
  }

  /// Create a copy with updated fields
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
    );
  }
}