import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:refrr_admin/models/balance-amount-model.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:refrr_admin/models/serviceLeadModel.dart';
import 'package:refrr_admin/models/total-credit-model.dart';
import 'package:refrr_admin/models/total-withdrawal-model.dart';
import 'package:refrr_admin/models/withdrew-requst-model.dart';

class AffiliateModel {
  final String name;
  final String profile;
  final String phone;
  final String zone;
  final String country;
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
  final int totalBalance;
  final int totalCredit;
  final int totalWithrew;
  final String language;
  final String qualification;
  final String experience;
  final String moreInfo;
  final List<String> industry;
  final List<String> jobType;
  final String role;
  final DocumentReference? reference;
  final String? id;
  final double? leadScore;
  final List<LeadsModel> workingFirms;
  final int totalLeads;
  final int qualifiedLeads;
  final List<ServiceLeadModel> generatedLeads;

  AffiliateModel({
    required this.name,
    required this.profile,
    required this.phone,
    required this.zone,
    required this.country,
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
    required this.totalBalance,
    required this.totalCredit,
    required this.totalWithrew,
    required this.language,
    required this.qualification,
    required this.experience,
    required this.moreInfo,
    required this.industry,
    required this.jobType,
    required this.role,
    this.reference,
    this.id,
    required this.leadScore,
    required this.workingFirms,
    required this.qualifiedLeads,
    required this.totalLeads,
    required this.generatedLeads,
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
    String? country,
    String? language,
    String? qualification,
    String? experience,
    String? moreInfo,
    List<String>? industry,
    List<String>? jobType,
    String? role,
    DocumentReference? reference,
    String? id,
    double? leadScore,
    List<LeadsModel>? workingFirms,
    int? totalLeads,
    int? qualifiedLeads,
    List<ServiceLeadModel>? generatedLeads,
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
      country: country ?? this.country,
      language: language ?? this.language,
      qualification: qualification ?? this.qualification,
      experience: experience ?? this.experience,
      moreInfo: moreInfo ?? this.moreInfo,
      industry: industry ?? this.industry,
      jobType: jobType ?? this.jobType,
      role: role ?? this.role,
      reference: reference ?? this.reference,
      id: id ?? this.id,
      leadScore: leadScore ?? this.leadScore,
      workingFirms: workingFirms ?? this.workingFirms,
      qualifiedLeads: qualifiedLeads ?? this.qualifiedLeads,
      totalLeads: totalLeads ?? this.totalLeads,
      generatedLeads: generatedLeads ?? this.generatedLeads,
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
      'country': country,
      'language': language,
      'qualification': qualification,
      'experience': experience,
      'moreInfo': moreInfo,
      'industry': industry,
      'jobType': jobType,
      'role': role,
      'reference': reference,
      'id': id,
      'leadScore': leadScore,
      'workingFirms': workingFirms.map((e) => e.toMap()).toList(),
      'qualifiedLeads': qualifiedLeads,
      'totalLeads': totalLeads,
      'generatedLeads': generatedLeads.map((e) => e.toMap()).toList(),

    };
  }

  factory AffiliateModel.fromMap(Map<String, dynamic> map, {DocumentReference? reference}) {
    return AffiliateModel(
      name: map['name'] ?? '',
      profile: map['profile'] ?? '',
      phone: map['phone'] ?? '',
      zone: map['zone'] ?? '',
      userId: map['userId'] ?? '',
      password: map['password'] ?? '',
      mailId: map['mailId'] ?? '',
      level: map['level'] ?? '',
      status: map['status'] ?? 0,
      delete: map['delete'] ?? false,
      createTime: (map['createTime'] as Timestamp).toDate(),
      search: List<dynamic>.from(map['search'] ?? []),
      addedBy: map['addedBy'] ?? '',
      withdrawalRequest: (map['withdrawalRequest'] as List<dynamic>? ?? [])
          .map((e) => WithdrewrequstModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      balance: (map['balance'] as List<dynamic>? ?? [])
          .map((e) => BalanceModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      totalCredits: (map['totalCredits'] as List<dynamic>? ?? [])
          .map((e) => TotalCreditModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      totalWithdrawals: (map['totalWithdrawals'] as List<dynamic>? ?? [])
          .map((e) => TotalWithdrawalsModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      totalBalance: map['totalBalance'] ?? 0,
      totalCredit: map['totalCredit'] ?? 0,
      totalWithrew: map['totalWithrew'] ?? 0,
      country: map['country'] ?? '',
      language: map['language'] ?? '',
      qualification: map['qualification'] ?? '',
      experience: map['experience'] ?? '',
      moreInfo: map['moreInfo'] ?? '',
      industry: (map['industry'] as List?)?.map((e) => e.toString()).toList() ?? [],
      jobType: (map['jobType'] as List?)?.map((e) => e.toString()).toList() ?? [],
      role: map['role'] ?? '',
      reference: reference ?? map['reference'],
      id: map['id'] ?? '',
      leadScore: (map['leadScore'] ?? 0).toDouble(),
      workingFirms: (map['workingFirms'] as List<dynamic>? ?? [])
          .map((e) => LeadsModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      qualifiedLeads: map['qualifiedLeads'] ?? 0,
      totalLeads: map['totalLeads'] ?? 0,
      generatedLeads: (map['generatedLeads'] as List<dynamic>? ?? [])
          .map((e) => ServiceLeadModel.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
