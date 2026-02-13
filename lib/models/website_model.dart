import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:refrr_admin/models/product_model.dart';
import 'package:refrr_admin/models/services_model.dart';


class WebsiteModel {
  final String websiteName;
  final String logo;
  final String aboutUs;
  final String phoneNumber;
  final String email;
  final String address;
  final String url;
  final DocumentReference? ref;
  final String marketerId;
  final List<String> productIdList;
  final List<String> serviceIdList;

  WebsiteModel({
    required this.websiteName,
    required this.logo,
    required this.aboutUs,
    required this.phoneNumber,
    required this.email,
    required this.address,
    required this.url,
    this.ref,
    required this.marketerId,
    required this.productIdList,
    required this.serviceIdList,
  });

  Map<String, dynamic> toJson() => {
    'websiteName': websiteName,
    'logo': logo,
    'aboutUs': aboutUs,
    'phoneNumber': phoneNumber,
    'email': email,
    'address': address,
    'url': url,
    'ref': ref,
    'marketerId': marketerId,
    'productIdList': productIdList,
    'serviceIdList': serviceIdList,
  };

  copyWith({
    String? websiteName,
    String? logo,
    String? aboutUs,
    String? phoneNumber,
    String? email,
    String? address,
    String? url,
    DocumentReference? ref,
    String? marketerId,
    List<String>? productIdList,
    List<String>? serviceIdList,
  }) {
    return WebsiteModel(
      websiteName: websiteName ?? this.websiteName,
      logo: logo ?? this.logo,
      aboutUs: aboutUs ?? this.aboutUs,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      url: url ?? this.url,
      ref: ref ?? this.ref,
      marketerId: marketerId ?? this.marketerId,
      productIdList: productIdList ?? this.productIdList,
      serviceIdList: serviceIdList ?? this.serviceIdList,
    );
  }

  factory WebsiteModel.fromMap(Map<String, dynamic> map) {
    return WebsiteModel(
      websiteName: map['websiteName'],
      logo: map['logo'],
      aboutUs: map['aboutUs'],
      phoneNumber: map['phoneNumber'],
      email: map['email'],
      address: map['address'],
      url: map['url'],
      ref: map['ref'],
      marketerId: map['marketerId'],
      productIdList: List<String>.from(map['productIdList'] ?? []),
      serviceIdList: List<String>.from(map['serviceIdList'] ?? []),
    );
  }
}

class WebsiteState {
  final bool isLoading;
  final bool isPublished;
  final WebsiteModel? siteConfig;
  final List<String> productIds;
  final List<String> serviceIds;
  const WebsiteState({
    this.isLoading = false,
    this.isPublished = false,
    this.siteConfig,
    this.productIds = const [],
    this.serviceIds = const [],
  });

  WebsiteState copyWith({
    bool? isLoading,
    bool? isPublished,
    WebsiteModel? siteConfig,
    List<String>? productIds,
    List<String>? serviceIds,
  }) {
    return WebsiteState(
      isLoading: isLoading ?? this.isLoading,
      isPublished: isPublished ?? this.isPublished,
      siteConfig: siteConfig ?? this.siteConfig,
      productIds: productIds ?? this.productIds,
      serviceIds: serviceIds ?? this.serviceIds,
    );
  }
}
class ServiceWithLead {
  final ServiceModel service;
  final LeadsModel? lead;
  const ServiceWithLead({required this.service, this.lead});
}
class ProductWithLead {
  final ProductModel product;
  final LeadsModel? lead;
  const ProductWithLead({required this.product, this.lead});
}
