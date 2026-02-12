
class ContactPersonModel {
  final String personName;
  final String phoneNumber;
  final String mailId;

  ContactPersonModel({
    required this.personName,
    required this.phoneNumber,
    required this.mailId,
  });

  ContactPersonModel copyWith({
    String? personName,
    String? phoneNumber,
    String? mailId,
  }) {
    return ContactPersonModel(
      personName: personName ?? this.personName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      mailId: mailId ?? this.mailId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'personName': personName,
      'phoneNumber': phoneNumber,
      'mailId': mailId,
    };
  }

  factory ContactPersonModel.fromMap(Map<String, dynamic> map,) {
    return ContactPersonModel(
      personName: map['personName'] as String,
      phoneNumber: map['phoneNumber'] as String,
      mailId: map['mailId'] as String,
    );
  }
}
