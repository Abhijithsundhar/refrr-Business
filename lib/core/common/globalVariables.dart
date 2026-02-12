
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:refrr_admin/Core/common/image-picker.dart';
import 'package:refrr_admin/models/admin-model.dart';
import 'package:refrr_admin/models/affiliate-model.dart';
import 'package:refrr_admin/models/job-history-model.dart';

///screen size
double width = 0;
double height = 0;

final adminProvider = StateProvider<AdminModel?>((ref) {
  return null;
});

late List<Map<String, dynamic>> contactPersons;

File? pickedImage;
List<Map<String, dynamic>> pdfs = [];
double w = width;
double h = height;


String selectedCategoryId = 'All';
String searchQuery = '';

bool loading = false;
bool creatives = true;
bool isLoading = true;

// 🔹 Filter State Variables
final selectedCountryProvider = StateProvider<String>((ref) => '');
final locationSearchProvider = StateProvider<String>((ref) => '');
String? selectedFilter = 'All';
String? selectedLocation;
String? selectedIndustry;

const double fieldHeight = 55.0; // Consistent height for all fields



DateTime? selectedOfferEndDate;
String? selectedMode;
PickedImage? pickedProfile;
// ============= SELECTION VARIABLES =============
String? selectedGender;
String? selectedCountry;
String? selectedLanguage;
String? selectedQualification;
String? selectedJobTitle;
String? selectedJobType;
String? selectedExp;
String? selectedRole;
List<String> selectedIndustries = [];
String? selectedCurrentJobType;
String? selectedPreviousIndustry;

// ============= IMAGE VARIABLES =============
String? uploadedImageUrl;
bool isImageUploading = false;

// ============= JOB HISTORY =============
List<JobHistory> jobHistoryList = [];
final DateTime sheduleDate  = DateTime.now();
bool hasText = false;

final List<String> genderList = ["Male", "Female", "Other"];
final List<String> languageList = ["English", "Hindi", "Tamil", "Malayalam"];
final List<String> countryList = [
  "india",
  "Bahrain",
  "Kuwait",
  "Oman",
  "Qatar",
  "Saudi Arabia",
  "UAE"
];

bool isSelectionMode = false;
bool isUploading = false;
bool isHiring = false;
final Set<String> selectedIds = {};
final List<AffiliateModel> selectedAffiliates = [];

String affId(AffiliateModel a) => a.id ?? a.reference?.id ?? '';


