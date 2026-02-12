import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  final String? id;
  final String image;
  final String name;
  final String description;
  final int startingPrice;
  final int endingPrice;
  final String commission;
  final int leadsGiven;
  final DateTime createTime;
  final bool delete;
  final String commissionFor;
  final String category; // ✅ NEW
  final String brand; // ✅ NEW
  final String addedBy; // ✅ NEW
  final DocumentReference? reference;

  ServiceModel({
    this.id,
    required this.image,
    required this.name,
    required this.description,
    required this.startingPrice,
    required this.endingPrice,
    required this.commission,
    required this.leadsGiven,
    required this.createTime,
    required this.delete,
    required this.commissionFor,
    required this.category, // ✅
    required this.brand, // ✅
    required this.addedBy, // ✅
    this.reference,
  });

  ServiceModel copyWith({
    String? id,
    String? image,
    String? name,
    String? description,
    int? startingPrice,
    int? endingPrice,
    String? commission,
    int? leadsGiven,
    DateTime? createTime,
    bool? delete,
    String? commissionFor,
    String? category, // ✅
    String? brand, // ✅
    String? addedBy, // ✅
    DocumentReference? reference,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      image: image ?? this.image,
      name: name ?? this.name,
      description: description ?? this.description,
      startingPrice: startingPrice ?? this.startingPrice,
      endingPrice: endingPrice ?? this.endingPrice,
      commission: commission ?? this.commission,
      leadsGiven: leadsGiven ?? this.leadsGiven,
      createTime: createTime ?? this.createTime,
      delete: delete ?? this.delete,
      commissionFor: commissionFor ?? this.commissionFor,
      category: category ?? this.category, // ✅
      brand: brand ?? this.brand, // ✅
      addedBy: addedBy ?? this.addedBy, // ✅
      reference: reference ?? this.reference,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'image': image,
      'name': name,
      'description': description,
      'startingPrice': startingPrice,
      'endingPrice': endingPrice,
      'commission': commission,
      'leadsGiven': leadsGiven,
      'createTime': Timestamp.fromDate(createTime),
      'delete': delete,
      'commissionFor': commissionFor,
      'category': category, // ✅
      'brand': brand, // ✅
      'addedBy': addedBy, // ✅
      'reference': reference,
    };
  }

  factory ServiceModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return ServiceModel(
      id: id,
      image: map['image'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      startingPrice: map['startingPrice'] as int? ?? 0,
      endingPrice: map['endingPrice'] as int? ?? 0,
      commission: map['commission'] as String? ?? '',
      leadsGiven: map['leadsGiven'] as int? ?? 0,
      createTime: (map['createTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      delete: map['delete'] as bool? ?? false,
      commissionFor: map['commissionFor'] as String? ?? '',
      category: map['category'] as String? ?? '', // ✅
      brand: map['brand'] as String? ?? '', // ✅
      addedBy: map['addedBy'] as String? ?? '', // ✅
      reference: map['reference'] as DocumentReference?,
    );
  }

  @override
  String toString() {
    return 'ServiceModel(id: $id, name: $name, description: $description, image: $image, startingPrice: $startingPrice, endingPrice: $endingPrice, commission: $commission, leadsGiven: $leadsGiven, createTime: $createTime, delete: $delete, commissionFor: $commissionFor, category: $category, brand: $brand, addedBy: $addedBy, reference: $reference)';
  }
}
