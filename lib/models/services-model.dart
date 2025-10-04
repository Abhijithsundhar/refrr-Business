import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  final String image;
  final String name;
  final int startingPrice;
  final int endingPrice;
  final int commission;
  final int leadsGiven;
  final DateTime createTime;
  final bool delete;
  final String commissionFor;

  ServiceModel({
    required this.image,
    required this.name,
    required this.startingPrice,
    required this.endingPrice,
    required this.commission,
    required this.leadsGiven,
    required this.createTime,
    required this.delete,
    required this.commissionFor,
  });

  ServiceModel copyWith({
    String? image,
    String? name,
    int? startingPrice,
    int? endingPrice,
    int? commission,
    int? leadsGiven,
    DateTime? createTime,
    bool? delete,
    DocumentReference? reference,
    String? commissionFor,
  }) {
    return ServiceModel(
      image: image ?? this.image,
      name: name ?? this.name,
      startingPrice: startingPrice ?? this.startingPrice,
      endingPrice: endingPrice ?? this.endingPrice,
      commission: commission ?? this.commission,
      leadsGiven: leadsGiven ?? this.leadsGiven,
      createTime: createTime ?? this.createTime,
      delete: delete ?? this.delete,
      commissionFor: commissionFor ?? this.commissionFor,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'image': image,
      'name': name,
      'startingPrice': startingPrice,
      'endingPrice': endingPrice,
      'commission': commission,
      'leadsGiven': leadsGiven,
      'createTime': Timestamp.fromDate(createTime),
      'delete': delete,
      'commissionFor': commissionFor,
    };
  }

  factory ServiceModel.fromMap(Map<String, dynamic> map, {DocumentReference? reference}) {
    return ServiceModel(
      image: map['image'] as String,
      name: map['name'] as String,
      startingPrice: map['startingPrice'] as int,
      endingPrice: map['endingPrice'] as int,
      commission: map['commission'] as int,
      leadsGiven: map['leadsGiven'] as int,
      createTime: (map['createTime'] as Timestamp).toDate(),
      delete: map['delete'] as bool? ?? false,
      commissionFor: map['commissionFor'] as String? ?? '',
    );
  }
}
