
import 'package:flutter/cupertino.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';

TextEditingController searchController=TextEditingController();
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
final TextEditingController offerDescriptionController = TextEditingController();
final TextEditingController offerCurrencyController = TextEditingController();
final TextEditingController offerEndDateController = TextEditingController();
final TextEditingController offerStartDateController = TextEditingController();
final TextEditingController offerModeController = TextEditingController();


///chat bot section
final TextEditingController msgController = TextEditingController();
final TextEditingController amountController = TextEditingController();
final TextEditingController remarksController = TextEditingController();
final TextEditingController remarksSheduleController = TextEditingController();
final TextEditingController eventController = TextEditingController();
final TextEditingController salesPersonName = TextEditingController();
final TextEditingController salesPersonNumber = TextEditingController();
final TextEditingController salesPersonEmail = TextEditingController();
final TextEditingController salesPersonProfile = TextEditingController();

///product
final TextEditingController productNameController = TextEditingController();
final TextEditingController productDescriptionController = TextEditingController();
final TextEditingController productPriceController = TextEditingController();
final TextEditingController productOfferPriceController = TextEditingController();
final TextEditingController productCommissionController = TextEditingController();
final TextEditingController productKeyPointsController = TextEditingController();
final TextEditingController productCategoryController = TextEditingController();
final TextEditingController brandController = TextEditingController();

///service
final TextEditingController serviceNameController = TextEditingController();
final TextEditingController serviceDescriptionController = TextEditingController();
final TextEditingController serviceCommissionController = TextEditingController();
final TextEditingController serviceStartingPriceController = TextEditingController();
final TextEditingController serviceEndingPriceController = TextEditingController();
final TextEditingController serviceCategoryController = TextEditingController();


///marketer
// ============= TEXT CONTROLLERS =============
final TextEditingController marketerNameController = TextEditingController();
final TextEditingController marketerGenderController = TextEditingController();
final TextEditingController marketerCountryController = TextEditingController();
final TextEditingController marketerPhoneNOController = TextEditingController();
final TextEditingController marketerEmailController = TextEditingController();
final TextEditingController marketerAgeController = TextEditingController();
final TextEditingController marketerQualificationController = TextEditingController();
final TextEditingController marketerCurrentJobTitleController = TextEditingController();
final TextEditingController marketerCurrentJobTypeController = TextEditingController();
final TextEditingController marketerJobHistoryController = TextEditingController();
final TextEditingController marketerExpireanceController = TextEditingController();
final TextEditingController marketerIAmAnController = TextEditingController();
final TextEditingController marketerPrefferdIndustryController = TextEditingController();
final TextEditingController marketerPreviousController = TextEditingController();
final TextEditingController marketerLanguageController = TextEditingController();
final TextEditingController marketerUserIdController = TextEditingController();
final TextEditingController marketerPasswordController = TextEditingController();
final TextEditingController marketerPreferenceJobTypeController = TextEditingController();


// ============= CLEAR ALL FUNCTION =============
void clearAllRegistrationData() {
  // Clear text controllers
  marketerNameController.clear();
  marketerGenderController.clear();
  marketerCountryController.clear();
  marketerPhoneNOController.clear();
  marketerEmailController.clear();
  marketerAgeController.clear();
  marketerQualificationController.clear();
  marketerCurrentJobTitleController.clear();
  marketerCurrentJobTypeController.clear();
  marketerJobHistoryController.clear();
  marketerExpireanceController.clear();
  marketerIAmAnController.clear();
  marketerPrefferdIndustryController.clear();
  marketerPreviousController.clear();
  marketerLanguageController.clear();
  marketerUserIdController.clear();
  marketerPasswordController.clear();
  marketerPreferenceJobTypeController.clear();

  // Clear selections
  selectedGender = null;
  selectedCountry = null;
  selectedLanguage = null;
  selectedQualification = null;
  selectedJobTitle = null;
  selectedJobType = null;
  selectedExp = null;
  selectedRole = null;
  selectedIndustries.clear();
  selectedCurrentJobType = null;
  selectedPreviousIndustry = null;

  // Clear image data
  uploadedImageUrl = null;
  isImageUploading = false;

  // Clear job history
  jobHistoryList.clear();
}
// ============= DROPDOWN/INPUT FIELD HEIGHT =============

///website
final TextEditingController websiteNameController = TextEditingController();
final TextEditingController websiteAboutController = TextEditingController();
final TextEditingController websiteNumberController = TextEditingController();
final TextEditingController websiteEmailController = TextEditingController();
final TextEditingController websiteAdressController = TextEditingController();
final TextEditingController websiteImageController = TextEditingController();


///leads
final TextEditingController leadsNameController = TextEditingController();
final TextEditingController leadsContactNoController = TextEditingController();
final TextEditingController leadsIndustryController = TextEditingController();
final TextEditingController leadsCountryController = TextEditingController();
final TextEditingController leadsZoneController = TextEditingController();
final TextEditingController leadsCurrencyController = TextEditingController();
final TextEditingController leadsWebsiteController = TextEditingController();
final TextEditingController leadsEmailController = TextEditingController();
final TextEditingController leadsAddressController = TextEditingController();
final TextEditingController leadsAboutController = TextEditingController();

String? selectedStatus;
DateTime? fromDate;
DateTime? toDate;
String? selectedMarketer;
String searchQuery = '';
int selectedIndex = 0;

final List<Map<String, dynamic>> locations = [];
const String kLocationsPrefsKey = 'funnel_locations_v1';