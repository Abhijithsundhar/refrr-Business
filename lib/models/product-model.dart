import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String? id;
  final String name;
  final String description;
  final String price;
  final String offerPrice;
  final String commission;
  final String imageUrl;
  final List<String> keyPoints;
  final String addedBy;
  final String category;
  final String brand; // ✅ NEW FIELD
  final bool delete;
  final DateTime createTime;
  final DocumentReference? reference;

  ProductModel({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.offerPrice,
    required this.commission,
    required this.imageUrl,
    required this.keyPoints,
    required this.addedBy,
    required this.category,
    required this.brand, // ✅
    required this.delete,
    required this.createTime,
    this.reference,
  });

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    String? price,
    String? offerPrice,
    String? commission,
    String? imageUrl,
    List<String>? keyPoints,
    String? addedBy,
    String? category,
    String? brand, // ✅
    bool? delete,
    DateTime? createTime,
    DocumentReference? reference,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      offerPrice: offerPrice ?? this.offerPrice,
      commission: commission ?? this.commission,
      imageUrl: imageUrl ?? this.imageUrl,
      keyPoints: keyPoints ?? this.keyPoints,
      addedBy: addedBy ?? this.addedBy,
      category: category ?? this.category,
      brand: brand ?? this.brand, // ✅
      delete: delete ?? this.delete,
      createTime: createTime ?? this.createTime,
      reference: reference ?? this.reference,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'offerPrice': offerPrice,
      'commission': commission,
      'imageUrl': imageUrl,
      'keyPoints': keyPoints,
      'addedBy': addedBy,
      'category': category,
      'brand': brand, // ✅
      'delete': delete,
      'createTime': createTime,
      'reference': reference,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return ProductModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: map['price'] ?? '',
      offerPrice: map['offerPrice'] ?? '',
      commission: map['commission'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      keyPoints: List<String>.from(map['keyPoints'] ?? []),
      addedBy: map['addedBy'] ?? '',
      category: map['category'] ?? '',
      brand: map['brand'] ?? '', // ✅
      delete: map['delete'] ?? false,
      createTime: (map['createTime'] as Timestamp).toDate(),
      reference: map['reference'] as DocumentReference?,
    );
  }

  @override
  String toString() {
    return 'ProductModel(id: $id, name: $name, description: $description, price: $price, offerPrice: $offerPrice, commission: $commission, imageUrl: $imageUrl, keyPoints: $keyPoints, addedBy: $addedBy, category: $category, brand: $brand, delete: $delete, createTime: $createTime, reference: $reference)';
  }
}
