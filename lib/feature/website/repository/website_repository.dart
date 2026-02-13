import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:refrr_admin/core/constants/failure.dart';
import 'package:refrr_admin/core/constants/firebase_constants.dart';
import 'package:refrr_admin/core/constants/typedef.dart';
import 'package:refrr_admin/models/category_model.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:refrr_admin/models/product_model.dart';
import 'package:refrr_admin/models/services_model.dart';
import 'package:refrr_admin/models/website_model.dart';


final websiteRepositoryProvider = Provider((ref) => WebsiteRepository());

class WebsiteRepository {
  FutureEither<List<CategoryModel>> getCategories() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(FirebaseCollections.categoryCollection)
          .get();

      final categories =
      snapshot.docs.map((doc) => CategoryModel.fromMap(doc.data())).toList();

      return right(categories);
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  /// ✅ Publish website with marketerId as the document ID
  FutureEither<WebsiteModel> publishWebsite({
    required WebsiteModel website,
  }) async {
    try {
      final websitesRef = FirebaseFirestore.instance
          .collection(FirebaseCollections.websitesCollection)
          .doc(website.marketerId); // Use marketerId as document ID

      // 1️⃣ Set document data (overwrite existing if any)
      await websitesRef.set(website.toJson());

      // 2️⃣ Include Firestore reference inside the model
      final updatedWebsite = website.copyWith(ref: websitesRef);

      // 3️⃣ Optionally update again for internal reference fields
      await websitesRef.update(updatedWebsite.toJson());

      return right(updatedWebsite);
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  Future<Either<Failure, void>> updateWebsiteConfig(WebsiteModel config) async {
    try {
      final websitesRef = FirebaseFirestore.instance
          .collection(FirebaseCollections.websitesCollection)
          .doc(config.marketerId); // ✅ Use marketerId for direct path

      await websitesRef.set(
        config.copyWith(ref: websitesRef).toJson(),
        SetOptions(merge: true), // safe merge
      );

      return const Right(null);
    } catch (e) {
      return Left(Failure(failure: e.toString()));
    }
  }

  // ✅ Filter hosted products by marketer id
  Future<List<String>> getHostedProductIds(String affiliateId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection(FirebaseCollections.websitesCollection)
          .where('marketerId', isEqualTo: affiliateId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return [];

      final data = querySnapshot.docs.first.data();
      return List<String>.from(data['productIdList'] ?? []);
    } catch (e) {
      return [];
    }
  }

  // ✅ Fetch website config for current firm only
  Future<WebsiteModel?> getSiteConfig(String affiliateId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(FirebaseCollections.websitesCollection)
          .where('marketerId', isEqualTo: affiliateId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        print("no website found for marketerId=$affiliateId");
        return null;
      }

      final data = snapshot.docs.first.data();
      final ref = snapshot.docs.first.reference;
      return WebsiteModel.fromMap(data).copyWith(ref: ref);
    } catch (e) {
      print("getSiteConfig error ${e.toString()}");
      return null;
    }
  }

  Future<List<ProductWithLead>> getHostedProductsWithLeads(
      String affiliateId) async {
    final productIds = await getHostedProductIds(affiliateId);
    if (productIds.isEmpty) return [];

    final firestore = FirebaseFirestore.instance;

    // ---------------- PRODUCTS ----------------
    final Map<String, ProductModel> products = {};

    for (int i = 0; i < productIds.length; i += 10) {
      final chunk = productIds.skip(i).take(10).toList();

      final snapshot = await firestore
          .collection(FirebaseCollections.affiliatesCollection)
          .doc(affiliateId)
          .collection(FirebaseCollections.productsCollection)
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      if (snapshot.docs.isEmpty) continue;

      for (final doc in snapshot.docs) {
        products[doc.id] = ProductModel.fromMap(doc.data());
      }
    }

    if (products.isEmpty) return [];

    // ---------------- LEADS ----------------
    final leadIds = products.values
        .map((p) => p.addedBy)
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    if (leadIds.isEmpty) {
      return products.values
          .map((p) => ProductWithLead(product: p, lead: null))
          .toList();
    }

    final Map<String, LeadsModel> leads = {};

    for (int i = 0; i < leadIds.length; i += 10) {
      final chunk = leadIds.skip(i).take(10).toList();

      final snapshot = await firestore
          .collection(FirebaseCollections.leadsCollection)
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      if (snapshot.docs.isEmpty) continue;

      for (final doc in snapshot.docs) {
        leads[doc.id] = LeadsModel.fromMap(doc.data());
      }
    }

    // ---------------- MERGE ----------------
    return products.values.map((product) {
      final lead = leads[product.addedBy];
      return ProductWithLead(
        product: product,
        lead: lead,
      );
    }).toList();
  }

  FutureEither<List<ProductWithLead>> getProductsFromWorkingFirms({
    required List<String> workingFirms,
  }) async {
    try {
      if (workingFirms.isEmpty) return right([]);

      final firestore = FirebaseFirestore.instance;

      final snap = await firestore
          .collectionGroup(FirebaseCollections.productsCollection)
          .orderBy('createTime', descending: true)
          .get();

      final List<ProductModel> products = [];
      final Set<String> leadIds = {};

      for (var doc in snap.docs) {
        final parentLeadId = doc.reference.parent.parent?.id;
        if (parentLeadId != null && workingFirms.contains(parentLeadId)) {
          final product = ProductModel.fromMap(doc.data());
          products.add(product);
          leadIds.add(parentLeadId);
        }
      }

      if (products.isEmpty) return right([]);

      // Fetch Leads in chunks of 10
      final Map<String, LeadsModel> leadMap = {};
      final leadList = leadIds.toList();

      for (int i = 0; i < leadList.length; i += 10) {
        final chunk = leadList.skip(i).take(10).toList();
        final leadSnaps = await firestore
            .collection(FirebaseCollections.leadsCollection)
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        for (var doc in leadSnaps.docs) {
          leadMap[doc.id] = LeadsModel.fromMap(doc.data());
        }
      }

      final result = products.map((p) {
        final lead = leadMap[p.addedBy];
        return ProductWithLead(
          product: p,
          lead: lead,
        );
      }).toList();

      return right(result);
    } catch (e) {
      return left(Failure(failure: e.toString()));
    }
  }

  Future<Either<Failure, List<ServiceWithLead>>> getServicesFromWorkingFirms({
    required List<String> workingFirms,
  }) async {
    try {
      if (workingFirms.isEmpty) return right([]);

      final firestore = FirebaseFirestore.instance;

      final snap = await firestore
          .collectionGroup(FirebaseCollections.servicesCollection)
          .orderBy('createTime', descending: true)
          .get();

      final List<ServiceModel> services = [];
      final Set<String> leadIds = {};

      for (var doc in snap.docs) {
        final parentLeadId = doc.reference.parent.parent?.id;
        if (parentLeadId != null && workingFirms.contains(parentLeadId)) {
          final service = ServiceModel.fromMap(doc.data(), id: doc.id);
          services.add(service);
          leadIds.add(parentLeadId);
        }
      }

      if (services.isEmpty) return right([]);

      final Map<String, LeadsModel> leadMap = {};
      final leadList = leadIds.toList();

      for (int i = 0; i < leadList.length; i += 10) {
        final chunk = leadList.skip(i).take(10).toList();
        final leadSnaps = await firestore
            .collection(FirebaseCollections.leadsCollection)
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        for (var doc in leadSnaps.docs) {
          leadMap[doc.id] = LeadsModel.fromMap(doc.data());
        }
      }

      final result = services.map((s) {
        final leadId = s.reference?.parent.parent?.id;
        final lead = leadMap[leadId] ??
            leadMap.values.firstWhere(
                  (l) => l.reference?.id == leadId,
              orElse: () => leadMap.values.first,
            );

        return ServiceWithLead(
          service: s,
          lead: lead,
        );
      }).toList();

      return right(result);
    } catch (e, s) {
      print("stackTrace $s");
      return left(Failure(failure: e.toString()));
    }
  }

  /// ✅ Only check hosted website by marketer id
  Future<bool> checkWebsiteHosted({
    required String parentDocId,
  }) async {
    final snapshot = await FirebaseFirestore.instance
        .collection(FirebaseCollections.websitesCollection)
        .where('marketerId', isEqualTo: parentDocId)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }
}
