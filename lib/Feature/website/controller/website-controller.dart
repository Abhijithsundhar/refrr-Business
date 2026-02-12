import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:refrr_admin/Core/common/snackbar.dart';
import 'package:refrr_admin/Feature/website/repository/website-repository.dart';
import 'package:refrr_admin/models/website-model.dart';


final websiteControllerProvider = NotifierProvider<WebsiteController, WebsiteState>(() => WebsiteController(),);

class WebsiteController extends Notifier<WebsiteState> {
  late final WebsiteRepository _repo;

  @override
  WebsiteState build() {
    _repo = WebsiteRepository();
    return const WebsiteState();
  }

  // 1. EXISTING: Create website
  Future<String> publishWebsite({
    required WebsiteModel website,
    required BuildContext context,
  }) async {
    // optional: instant optimistic update
    state = state.copyWith(isLoading: true, isPublished: true, siteConfig: website);

    final res = await _repo.publishWebsite(website: website);

    return res.fold(
          (failure) {
        state = state.copyWith(isLoading: false);
        throw Exception(failure.failure);
      },
          (publishedSite) {
        state = state.copyWith(
          isLoading: false,
          isPublished: true,
          productIds: publishedSite.productIdList,
          serviceIds: publishedSite.serviceIdList,
          siteConfig: publishedSite,
        );

        Navigator.of(context).pop();
        showCommonSnackbar(context, "Website added successfully");
        return publishedSite.url ?? '';
      },
    );
  }
  // 3. Check if website is hosted/published
  Future<void> checkHostedStatus(String affiliateId) async {
    state = state.copyWith(isLoading: true);

    final websiteIsHosted =
    await _repo.checkWebsiteHosted(parentDocId: affiliateId);
    final isPublished = websiteIsHosted;
    print("is hosted $isPublished");

    if (isPublished) {
      print("website is hosted");

      final config = await _repo.getSiteConfig(affiliateId);
      print("config fetch success: $config");
      state = state.copyWith(
        isLoading: false,
        isPublished: true,
        siteConfig: config,
      );
    } else {
      print("website is not hosted ");

      state = state.copyWith(isLoading: false, isPublished: false);
    }
  }

  // 4. Update site config (logo, name)
  Future<void> updateSiteConfig({
    required String affiliateId,
    String? logoUrl,
    String? siteName,
  }) async {
    state = state.copyWith(isLoading: true);

    final currentConfig = state.siteConfig;
    if (currentConfig == null) throw Exception('No published site');

    final updatedConfig = currentConfig.copyWith(
      url: logoUrl ?? currentConfig.url,
      websiteName: siteName ?? currentConfig.websiteName,
    );

    final res = await _repo.updateWebsiteConfig(updatedConfig);

    state = state.copyWith(
      isLoading: false,
      siteConfig: res.isRight() ? updatedConfig : currentConfig,
    );
  }

  Future<List<ProductWithLead>> getHostedProducts(String affiliateId) async {
    state = state.copyWith(isLoading: true);
    final products = await _repo.getHostedProductsWithLeads(affiliateId);
    state = state.copyWith(isLoading: false);
    return products;
  }

  Future<List<ProductWithLead>> getProductsFromWorkingFirms(
      List<String> workingFirms) async {
    final res =
    await _repo.getProductsFromWorkingFirms(workingFirms: workingFirms);
    return res.fold(
          (l) => throw Exception(l.failure),
          (r) => r,
    );
  }

  Future<List<ServiceWithLead>> getServicesFromWorkingFirms(
      List<String> workingFirms) async {
    final res =
    await _repo.getServicesFromWorkingFirms(workingFirms: workingFirms);
    return res.fold(
          (l) => throw Exception(l.failure),
          (r) => r,
    );
  }
}