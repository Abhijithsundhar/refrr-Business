
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:refrr_admin/Core/common/snackbar.dart';
import 'package:refrr_admin/Feature/Team/repository/affiliate-repository.dart';
import 'package:refrr_admin/models/affiliate-model.dart';


final affiliateRepositoryProvider = Provider((ref) => AffiliateRepository());

/// affilate Stream Provider with search support
final affiliateStreamProvider = StreamProvider.family<List<AffiliateModel>, String>((ref, searchQuery) {
  final repository = ref.watch(affiliateRepositoryProvider);
  return repository.getAffiliate(searchQuery);
});
final affiliateByMarketerProvider = FutureProvider.family<AffiliateModel?, String>((ref, marketerId) async {
  final controller = ref.read(affiliateControllerProvider.notifier);
  return await controller.getAffiliateByMarketerId(marketerId);
});


/// AffiliateController Provider
final affiliateControllerProvider = StateNotifierProvider<AffiliateController, bool>((ref) {
  return AffiliateController(repository: ref.read(affiliateRepositoryProvider));

});


class AffiliateController extends StateNotifier<bool> {final AffiliateRepository _repository;

AffiliateController({required AffiliateRepository repository}): _repository = repository, super(false);

/// Add affiliate
Future<void> addAffiliate({
  required AffiliateModel affiliateModel,
  required BuildContext context,
}) async {
  state = true;
  var snap=await _repository.addAffiliate(affiliateModel);
  state = false;
  snap.fold((l) =>showCommonSnackbar(context,l.failure) , (r) {
    showCommonSnackbar(context,"Affiliate added successfully");
    Navigator.pop(context);
  });
}

///update Affiliate
Future<void> updateAffiliate({
  required AffiliateModel affiliateModel,
  required BuildContext context,
}) async {
  state = true;
  var snap=await _repository.updateAffiliate(affiliateModel);
  state = false;
  snap.fold((l) =>showCommonSnackbar(context,l.failure) , (r) {
    showCommonSnackbar(context,"Affiliate updated successfully");
    Navigator.pop(context);
  });
}

/// affiliate stream
Stream <List<AffiliateModel>>getAffiliate(String searchQuery ){
  return _repository.getAffiliate(searchQuery);
}

Future<AffiliateModel?> getAffiliateByMarketerId(String marketerId) async {
  state = true; // optional loading state
  final result = await _repository.getAffiliateByMarketerId(marketerId);
  state = false;
  return result.fold(
        (l) => null,        // return null if error occurs
        (affiliate) => affiliate, // return AffiliateModel? if found
  );
}
}
