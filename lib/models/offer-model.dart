import 'package:cloud_firestore/cloud_firestore.dart';

class OfferModel {
  final String name;
  final String amount;
  final DateTime endDate;
  final DateTime createTime;
  final String? id;
  final bool delete;
  final DocumentReference? reference;
  final String? image;
  final String? currency;
  final String description;
  final String? mode;
  final String? affiliate;

  OfferModel({
    required this.name,
    required this.amount,
    required this.endDate,
    required this.createTime,
    this.id,
    required this.delete,
    this.reference,
    this.image,
    this.currency,
    required this.description,
    this.mode,
    this.affiliate,
  });

  OfferModel copyWith({
    String? name,
    String? amount,
    DateTime? endDate,
    DateTime? createTime,
    String? id,
    bool? delete,
    DocumentReference? reference,
    String? image,
    String? currency,
    String? description,
    String? mode,
    String? affiliate,
  }) {
    return OfferModel(
      name: name ?? this.name,
      amount: amount ?? this.amount,
      endDate: endDate ?? this.endDate,
      createTime: createTime ?? this.createTime,
      id: id ?? this.id,
      delete: delete ?? this.delete,
      reference: reference ?? this.reference,
      image: image ?? this.image,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      mode: mode ?? this.mode,
      affiliate: affiliate ?? this.affiliate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'endDate': Timestamp.fromDate(endDate),
      'createTime': Timestamp.fromDate(createTime),
      'id': id,
      'delete': delete,
      'reference': reference,
      'image': image,
      'currency': currency,
      'description': description,
      'mode': mode,
      'affiliate': affiliate,
    };
  }

  factory OfferModel.fromMap(Map<String, dynamic> map, {DocumentReference? reference}) {
    return OfferModel(
      name: map['name'] as String,
      amount: map['amount'] as String,

      /// ✅ Fix: Support both Timestamp and String
      endDate: map['endDate'] is Timestamp
          ? (map['endDate'] as Timestamp).toDate()
          : DateTime.parse(map['endDate']),

      createTime: map['createTime'] is Timestamp
          ? (map['createTime'] as Timestamp).toDate()
          : DateTime.parse(map['createTime']),

      id: map['id'] as String,
      delete: map['delete'] as bool? ?? false,
      reference: reference ?? map['reference'] as DocumentReference?,
      image: map['image'] as String?,
      currency: map['currency'] as String?,
      description: map['description'] as String,
      mode: map['mode'] as String?,
      affiliate: map['affiliate'] as String?,
    );
  }}

