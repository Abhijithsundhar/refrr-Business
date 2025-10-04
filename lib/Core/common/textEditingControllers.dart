import 'package:flutter/cupertino.dart';
import 'package:refrr_admin/Core/common/image-picker.dart';

///add firms

TextEditingController firmNameController=TextEditingController();
TextEditingController firmIndustryController=TextEditingController();
TextEditingController firmServiceController=TextEditingController();
TextEditingController firmAddressController=TextEditingController();
TextEditingController firmPhoneNoController=TextEditingController();
TextEditingController firmEmailController=TextEditingController();
TextEditingController firmWebsiteController=TextEditingController();
TextEditingController contactPersonNameController=TextEditingController();
TextEditingController contactPersonPhoneController=TextEditingController();
TextEditingController contactPersonemailController=TextEditingController();
TextEditingController firmLocationController=TextEditingController();
TextEditingController firmStatusController=TextEditingController();
TextEditingController firmRequirementsController=TextEditingController();


final TextEditingController offerNameController = TextEditingController();
final TextEditingController offerAmountController = TextEditingController();
final TextEditingController leadsContactNoController = TextEditingController();
final TextEditingController offerDescriptionController = TextEditingController();
final TextEditingController offerCurrencyController = TextEditingController();
final TextEditingController offerEndDateController = TextEditingController();
final TextEditingController offerStartDateController = TextEditingController();
final TextEditingController offerModeController = TextEditingController();
DateTime? selectedOfferEndDate;
String? selectedMode;
PickedImage? pickedProfile;
