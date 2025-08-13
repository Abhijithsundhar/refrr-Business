import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:refrr_admin/Model/total-credit-model.dart';
import 'package:refrr_admin/Model/total-withdrawal-model.dart';
import 'package:refrr_admin/Model/withdrew-requst-model.dart';
import 'balance-amount-model.dart';

class AffiliateModel {
  final String name;
  final String profile;
  final String phone;
  final String zone;
  final String userId;
  final String password;
  final String mailId;
  final String level;
  final int status;
  final bool delete;
  final DateTime createTime;
  final List<dynamic> search;
  final String addedBy;
  final List<WithdrewrequstModel> withdrawalRequest;
  final List<BalanceModel> balance;
  final List<TotalCreditModel> totalCredits;
  final List<TotalWithdrawalsModel> totalWithdrawals;
  final int totalBalance;       // New field
  final int totalCredit;        // New field
  final int totalWithrew;// New field
  final DocumentReference? reference;
  final String? id;
  final String country;
  final String language;

  AffiliateModel({
    required this.name,
    required this.profile,
    required this.phone,
    required this.zone,
    required this.userId,
    required this.password,
    required this.mailId,
    required this.level,
    required this.status,
    required this.delete,
    required this.createTime,
    required this.search,
    required this.addedBy,
    required this.withdrawalRequest,
    required this.balance,
    required this.totalCredits,
    required this.totalWithdrawals,
    required this.totalBalance,     // In constructor
    required this.totalCredit,      // In constructor
    required this.totalWithrew,     // In constructor
    this.reference,
    this.id,
    required this.country,
    required this.language
  });

  AffiliateModel copyWith({
    String? name,
    String? profile,
    String? phone,
    String? zone,
    String? userId,
    String? password,
    String? mailId,
    String? level,
    int? status,
    bool? delete,
    DateTime? createTime,
    List<dynamic>? search,
    String? addedBy,
    List<WithdrewrequstModel>? withdrawalRequest,
    List<BalanceModel>? balance,
    List<TotalCreditModel>? totalCredits,
    List<TotalWithdrawalsModel>? totalWithdrawals,
    int? totalBalance,
    int? totalCredit,
    int? totalWithrew,
    String? id,
    String? country,
    String? language,
    DocumentReference? reference,
  }) {
    return AffiliateModel(
      name: name ?? this.name,
      profile: profile ?? this.profile,
      phone: phone ?? this.phone,
      zone: zone ?? this.zone,
      userId: userId ?? this.userId,
      password: password ?? this.password,
      mailId: mailId ?? this.mailId,
      level: level ?? this.level,
      status: status ?? this.status,
      delete: delete ?? this.delete,
      createTime: createTime ?? this.createTime,
      search: search ?? this.search,
      addedBy: addedBy ?? this.addedBy,
      withdrawalRequest: withdrawalRequest ?? this.withdrawalRequest,
      balance: balance ?? this.balance,
      totalCredits: totalCredits ?? this.totalCredits,
      totalWithdrawals: totalWithdrawals ?? this.totalWithdrawals,
      totalBalance: totalBalance ?? this.totalBalance,
      totalCredit: totalCredit ?? this.totalCredit,
      totalWithrew: totalWithrew ?? this.totalWithrew,
      reference: reference ?? this.reference,
      id: id ?? this.id,
      country: country ?? this.country,
      language: language ?? this.language,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'profile': profile,
      'phone': phone,
      'zone': zone,
      'userId': userId,
      'password': password,
      'mailId': mailId,
      'level': level,
      'status': status,
      'delete': delete,
      'createTime': Timestamp.fromDate(createTime),
      'search': search,
      'addedBy': addedBy,
      'withdrawalRequest': withdrawalRequest.map((e) => e.toMap()).toList(),
      'balance': balance.map((e) => e.toMap()).toList(),
      'totalCredits': totalCredits.map((e) => e.toMap()).toList(),
      'totalWithdrawals': totalWithdrawals.map((e) => e.toMap()).toList(),
      'totalBalance': totalBalance,
      'totalCredit': totalCredit,
      'totalWithrew': totalWithrew,
      'reference': reference,
      'id': id,
      'country': country,
      'language': language,
    };
  }

  factory AffiliateModel.fromMap(Map<String, dynamic> map, {DocumentReference? reference}) {
    return AffiliateModel(
      name: map['name'] as String,
      profile: map['profile'] as String,
      phone: map['phone'] as String,
      zone: map['zone'] as String,
      userId: map['userId'] as String,
      password: map['password'] as String,
      mailId: map['mailId'] as String,
      level: map['level'] as String,
      status: map['status'] ?? 0,
      delete: map['delete'] as bool? ?? false,
      createTime: (map['createTime'] as Timestamp).toDate(),
      search: List<dynamic>.from(map['search'] ?? []),
      addedBy: map['addedBy'] as String,
      withdrawalRequest: (map['withdrawalRequest'] as List<dynamic>)
          .map((e) => WithdrewrequstModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      balance: (map['balance'] as List<dynamic>)
          .map((e) => BalanceModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      totalCredits: (map['totalCredits'] as List<dynamic>)
          .map((e) => TotalCreditModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      totalWithdrawals: (map['totalWithdrawals'] as List<dynamic>)
          .map((e) => TotalWithdrawalsModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      totalBalance: map['totalBalance'] ?? 0,
      totalCredit: map['totalCredit'] ?? 0,
      totalWithrew: map['totalWithrew'] ?? 0,
      reference: map['reference'] as DocumentReference,
      id: map['id'] as String?,
      country: map['country'] as String,
      language: map['language'] as String,
    );
  }
}
