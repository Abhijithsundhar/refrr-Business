import 'package:cloud_firestore/cloud_firestore.dart';

class CreativeModel {
  final String? id;
  final String url;
  final String addedBy;
  final bool delete;
  final DateTime createTime;
  final DocumentReference? reference;

  CreativeModel({
     this.id,
    required this.url,
    required this.addedBy,
    required this.delete,
    required this.createTime,
    this.reference,
  });

  factory CreativeModel.fromMap(
      Map<String, dynamic> map, {
        required String id,
        DocumentReference? reference,
      }) {
    return CreativeModel(
      id: map['id'] ?? '',
      url: map['url'] ?? '',
      addedBy: map['addedBy'] ?? '',
      delete: map['delete'] ?? false,
      createTime: (map['createTime'] as Timestamp).toDate(),
      reference: map['reference'] ?? DocumentReference,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'addedBy': addedBy,
      'delete': delete,
      'createTime': createTime,
      'id': id,
      'reference': reference,
    };
  }
  CreativeModel copyWith({
    String? id,
    String? url,
    String? addedBy,
    bool? delete,
    DateTime? createTime,
    DocumentReference? reference,
  }) {
    return CreativeModel(
      id: id ?? this.id,
      url: url ?? this.url,
      addedBy: addedBy ?? this.addedBy,
      delete: delete ?? this.delete,
      createTime: createTime ?? this.createTime,
      reference: reference ?? this.reference,
    );
  }
}
