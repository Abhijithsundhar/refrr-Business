import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String? documentId;
  final String name;
  final String image;
  final DateTime? createTime;
  final DocumentReference? reference;

  CategoryModel({
    this.documentId,
    required this.name,
    required this.image,
    this.createTime,
    this.reference,
  });

  /// Convert CategoryModel to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'documentId': documentId,
      'name': name,
      'image': image,
      'createTime': createTime ?? DateTime.now(),
    };
  }

  /// Create CategoryModel from Firestore document map
  factory CategoryModel.fromMap(
      Map<String, dynamic> map, {
        DocumentReference? ref,
      }) {
    return CategoryModel(
      documentId: map['documentId'] as String?,
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      createTime: map['createTime'] is DateTime ? map['createTime'] as DateTime : null,
      reference: ref,
    );
  }

  /// Create a copy with updated fields
  CategoryModel copyWith({
    String? documentId,
    String? name,
    String? image,
    DateTime? createTime,
    DocumentReference? reference,
  }) {
    return CategoryModel(
      documentId: documentId ?? this.documentId,
      name: name ?? this.name,
      image: image ?? this.image,
      createTime: createTime ?? this.createTime,
      reference: reference ?? this.reference,
    );
  }
}
