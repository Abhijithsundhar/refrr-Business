
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:refrr_admin/Core/common/alertBox.dart';
import 'package:refrr_admin/Feature/promote/repository/offers-repository.dart';
import 'package:refrr_admin/core/common/snackbar.dart';
import 'package:refrr_admin/models/offer-model.dart';

final offerRepositoryProvider = Provider((ref) => OfferRepository());

/// offer Stream Provider with search support
final offerStreamProvider =
StreamProvider.family<List<OfferModel>, String>((ref, searchQuery) {
  final repository = ref.watch(offerRepositoryProvider);
  return repository.getOffer(searchQuery);
});

/// offerController Provider
final offerControllerProviders = StateNotifierProvider<OfferController, bool>((ref) {
  return OfferController(repository: ref.read(offerRepositoryProvider));

});


class OfferController extends StateNotifier<bool> {final OfferRepository _repository;

OfferController({required OfferRepository repository}): _repository = repository, super(false);

/// Add offer
Future<void> addOffer({
  required OfferModel offerModel,
  required BuildContext context, // rootContext
}) async {
  if (state) return;
  state = true;

  try {
    final result = await _repository.addOffer(offerModel);

    result.fold(
          (failure) {
        showCommonSnackbar(context, failure.failure);
      },
          (success) {
        /// ✅ SUCCESS ALERT
        showSuccessAlertDialog(
          context: context,
          title: 'Offer Added Successful',
          subtitle: 'You have successfully added your Offer',
          onTap: () {
            Navigator.pop(context); // alert
            Navigator.pop(context); // bottom sheet
            Navigator.pop(context); // page (optional)
          },
        );
      },
    );
  } catch (e) {
    showCommonSnackbar(context, 'Failed to add offer');
  } finally {
    state = false;
  }
}


///update Offer
Future<void> updateOffer({
  required OfferModel offerModel,
  required BuildContext context,
}) async {
  state = true;
  var snap=await _repository.updateOffer(offerModel);
  state = false;
  snap.fold((l) =>showCommonSnackbar(context,l.failure) , (r) {
    showCommonSnackbar(context,"Offer updated successfully");
    Navigator.pop(context);
  });
}

/// offer stream
Stream <List<OfferModel>>getOffer(String searchQuery ){
  return _repository.getOffer(searchQuery);
}

}
