import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/custom-appBar.dart';
import 'package:refrr_admin/Core/common/custom-text-field.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';
import 'package:refrr_admin/Core/common/search-query.dart';
import 'package:refrr_admin/Core/common/snackbar.dart';
import 'package:refrr_admin/Core/common/textEditingControllers.dart';
import 'package:refrr_admin/Core/constants/color-constnats.dart';
import 'package:refrr_admin/Core/theme/pallet.dart';
import 'package:refrr_admin/Feature/Login/Controller/lead-controllor.dart';
import 'package:refrr_admin/Feature/pipeline/Controller/industry-controler.dart';
import 'package:refrr_admin/Feature/website/controller/firm-controller.dart';
import 'package:refrr_admin/models/affiliate-model.dart';
import 'package:refrr_admin/models/contact-person-model.dart';
import 'package:refrr_admin/models/firm-model.dart';
import 'package:refrr_admin/models/leads_model.dart';

class AddFirmScreen extends ConsumerStatefulWidget {
  final LeadsModel? leads;
  final AffiliateModel? affiliate;

  const AddFirmScreen({super.key, this.leads, this.affiliate,
  });

  @override
  ConsumerState<AddFirmScreen> createState() => _AddFirmScreenState();
}

class _AddFirmScreenState extends ConsumerState<AddFirmScreen> {
  // Contact person data
  List<ContactPersonModel> contactPerson = [];
  List<TextEditingController> contactPersonNameControllers = [];
  List<TextEditingController> contactPersonPhoneControllers = [];
  List<TextEditingController> contactPersonEmailControllers = [];

  // Selected services
  List<String> selectedServices = [];
  String? selectedIndustry;

  // ✅ Add switch state for Firm/Person
  bool isFirm = true; // true = Firm, false = Person

  // ✅ Loading state
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _addContactPersonField();
  }

  @override
  void dispose() {
    _disposeContactControllers();
    super.dispose();
  }

  // Initialize form controllers
  void _initializeControllers() {
    firmNameController.clear();
    firmAddressController.clear();
    firmPhoneNoController.clear();
    firmEmailController.clear();
    firmWebsiteController.clear();
    firmLocationController.clear();
    firmRequirementsController.clear();
    firmIndustryController.clear();
    selectedIndustry = null;
  }

  // Add new contact person field
  void _addContactPersonField() {
    setState(() {
      contactPerson.add(ContactPersonModel(
        personName: '',
        phoneNumber: '',
        mailId: '',
      ));
      contactPersonNameControllers.add(TextEditingController());
      contactPersonPhoneControllers.add(TextEditingController());
      contactPersonEmailControllers.add(TextEditingController());
    });
  }

  // Remove contact person field
  void _removeContactPersonField(int index) {
    if (contactPerson.length <= 1) return;

    setState(() {
      contactPerson.removeAt(index);
      contactPersonNameControllers[index].dispose();
      contactPersonPhoneControllers[index].dispose();
      contactPersonEmailControllers[index].dispose();
      contactPersonNameControllers.removeAt(index);
      contactPersonPhoneControllers.removeAt(index);
      contactPersonEmailControllers.removeAt(index);
    });
  }

  // Dispose all contact controllers
  void _disposeContactControllers() {
    for (var controller in contactPersonNameControllers) {
      controller.dispose();
    }
    for (var controller in contactPersonPhoneControllers) {
      controller.dispose();
    }
    for (var controller in contactPersonEmailControllers) {
      controller.dispose();
    }
  }

  // Validate form
  bool _validateForm() {
    if (firmNameController.text.trim().isEmpty) {
      showCommonSnackbar(context, 'Please Enter Name');
      return false;
    }

    // ✅ Only validate industry for Firm
    if (isFirm && firmIndustryController.text.trim().isEmpty) {
      showCommonSnackbar(context, 'Please Select Industry Type');
      return false;
    }

    if (firmPhoneNoController.text.trim().isEmpty) {
      showCommonSnackbar(context, 'Please Enter Phone No');
      return false;
    }
    if (firmEmailController.text.trim().isEmpty) {
      showCommonSnackbar(context, 'Please Enter Email');
      return false;
    }
    if (firmLocationController.text.trim().isEmpty) {
      showCommonSnackbar(context, 'Please Enter Location');
      return false;
    }

    // ✅ Only validate contact person for Firm
    if (isFirm) {
      bool hasValidContact = false;
      for (int i = 0; i < contactPerson.length; i++) {
        if (contactPersonNameControllers[i].text.trim().isNotEmpty ||
            contactPersonPhoneControllers[i].text.trim().isNotEmpty ||
            contactPersonEmailControllers[i].text.trim().isNotEmpty) {
          hasValidContact = true;
          break;
        }
      }

      if (!hasValidContact) {
        showCommonSnackbar(context, 'Please add at least one contact person');
        return false;
      }
    }

    return true;
  }

  // ✅ Submit form - FIXED VERSION
  Future<void> _submitForm() async {
    if (!_validateForm()) return;
    if (isSubmitting) return; // Prevent double submission

    // Check if leadId exists
    if (widget.leads?.reference?.id == null) {
      showCommonSnackbar(context, 'Lead ID is missing');
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      // Prepare contact persons data (only for firm)
      final contacts = isFirm
          ? List.generate(
        contactPerson.length,
            (index) => ContactPersonModel(
          personName: contactPersonNameControllers[index].text.trim(),
          phoneNumber: contactPersonPhoneControllers[index].text.trim(),
          mailId: contactPersonEmailControllers[index].text.trim(),
        ),
      )
          : <ContactPersonModel>[];

      // Create search parameters
      final searchString = [
        firmNameController.text.trim(),
        if (isFirm) firmIndustryController.text.trim(),
        firmAddressController.text.trim(),
        firmPhoneNoController.text.trim(),
        firmLocationController.text.trim(),
        firmEmailController.text.trim(),
      ].join(' ').toUpperCase();

      // ✅ Create firm/person model
      final newEntry = AddFirmModel(
        name: firmNameController.text.trim(),
        industryType: isFirm ? firmIndustryController.text.trim() : '',
        address: firmAddressController.text.trim(),
        phoneNo: int.tryParse(firmPhoneNoController.text.trim()) ?? 0,
        email: firmEmailController.text.trim(),
        website: isFirm ? firmWebsiteController.text.trim() : '',
        contactPersons: contacts.map((c) => c.toMap()).toList(),
        logo: '',
        delete: false,
        createTime: DateTime.now(),
        search: setSearchParam(searchString),
        location: firmLocationController.text.trim(),
        requirement: firmRequirementsController.text.trim(),
        type: isFirm ? 'firm' : 'person',
        reference: null, // Will be set by repository
      );

      // ✅ Use the controller to add firm
      await ref.read(firmControllerProvider.notifier).addFirm(
        leadId: widget.leads!.reference!.id,
        firm: newEntry,
        context: context,
      );

      // Invalidate provider
      ref.invalidate(leadControllerProvider);

      // Navigate back
      if (mounted) {
        Navigator.pop(context);
        showCommonSnackbar(
          context,
          isFirm ? 'Firm added successfully' : 'Person added successfully',
        );
      }

      // Clear form
      _clearForm();
    } catch (e) {
      if (mounted) {
        showCommonSnackbar(context, 'Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  // Clear form
  void _clearForm() {
    firmNameController.clear();
    firmIndustryController.clear();
    firmAddressController.clear();
    firmPhoneNoController.clear();
    firmEmailController.clear();
    firmWebsiteController.clear();
    firmLocationController.clear();
    firmRequirementsController.clear();

    setState(() {
      selectedIndustry = null;
      selectedServices.clear();
      _disposeContactControllers();
      contactPerson.clear();
      contactPersonNameControllers.clear();
      contactPersonPhoneControllers.clear();
      contactPersonEmailControllers.clear();
      _addContactPersonField();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'Add New Entry'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Toggle button at top right above name field
            Row(
              children: [
                SizedBox(width: width * 0.02),
                Text(
                  'On adding a person switch',
                  style: GoogleFonts.dmSans(
                    fontSize: width * 0.035,
                    fontWeight: FontWeight.w500,
                    color: Pallet.greyColor,
                  ),
                ),
                SizedBox(width: width * 0.02),
                _buildCompactToggle(),
              ],
            ),
            SizedBox(height: 16),

            // Name *
            inputField(
              'Name *',
              firmNameController,
              TextInputType.name,
              SizedBox(),
            ),
            SizedBox(height: 10),

            // ✅ Industry Type Dropdown (only for Firm)
            if (isFirm) ...[
              _buildIndustryDropdown(),
              SizedBox(height: 10),
            ],

            // Address
            inputField(
              'Address',
              firmAddressController,
              TextInputType.text,
              SizedBox(),
              maxLines: 3,
            ),
            SizedBox(height: 10),

            // Phone Number *
            inputField(
              'Mobile Number *',
              firmPhoneNoController,
              TextInputType.number,
              SizedBox(),
            ),
            SizedBox(height: 10),

            // Email *
            inputField(
              'E-mail *',
              firmEmailController,
              TextInputType.emailAddress,
              SizedBox(),
            ),
            SizedBox(height: 10),

            // ✅ Website (only for Firm)
            if (isFirm) ...[
              inputField(
                'Website Link',
                firmWebsiteController,
                TextInputType.text,
                SizedBox(),
              ),
              SizedBox(height: 10),
            ],

            // Location *
            inputField(
              'Location *',
              firmLocationController,
              TextInputType.text,
              SizedBox(),
            ),
            SizedBox(height: 20),

            // ✅ Contact Persons (only for Firm)
            if (isFirm) ...[
              _buildContactPersonsList(),
              SizedBox(height: 10),
            ],

            // Requirements
            inputField(
              'Requirements',
              firmRequirementsController,
              TextInputType.text,
              SizedBox(),
              maxLines: 4,
            ),
            SizedBox(height: 30),

            // Submit Button with Loading
            _buildSubmitButton(),
            SizedBox(height: height * 0.03),
          ],
        ),
      ),
    );
  }

  // ✅ Build Compact Rounded Toggle Button
  Widget _buildCompactToggle() {
    return Container(
      height: height * 0.04,
      width: width * 0.35,
      padding: EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ColorConstants.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: isSubmitting
                  ? null
                  : () {
                setState(() {
                  isFirm = true;
                  selectedIndustry = null;
                  firmIndustryController.clear();
                });
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                  isFirm ? ColorConstants.primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  'Firm',
                  style: GoogleFonts.dmSans(
                    fontSize: width * 0.03,
                    fontWeight: FontWeight.w500,
                    color: isFirm ? Colors.white : ColorConstants.primaryColor,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 2),
          Expanded(
            child: GestureDetector(
              onTap: isSubmitting
                  ? null
                  : () {
                setState(() {
                  isFirm = false;
                  selectedIndustry = null;
                  firmIndustryController.clear();
                  firmWebsiteController.clear();
                  selectedServices.clear();
                  _disposeContactControllers();
                  contactPerson.clear();
                  contactPersonNameControllers.clear();
                  contactPersonPhoneControllers.clear();
                  contactPersonEmailControllers.clear();
                  _addContactPersonField();
                });
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: !isFirm
                      ? ColorConstants.primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  'Person',
                  style: GoogleFonts.dmSans(
                    fontSize: width * 0.03,
                    fontWeight: FontWeight.w500,
                    color: !isFirm ? Colors.white : ColorConstants.primaryColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build industry dropdown
  Widget _buildIndustryDropdown() {
    return ref.watch(industryStreamProvider('')).when(
      data: (industries) {
        if (industries.isEmpty) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            decoration: BoxDecoration(
              border: Border.all(color: Pallet.borderColor),
              borderRadius: BorderRadius.circular(width * 0.025),
            ),
            child: Text(
              "No industries available",
              style: GoogleFonts.dmSans(
                fontSize: width * 0.035,
                color: Colors.orange,
              ),
            ),
          );
        }

        final List<String> industryNames =
        industries.map((i) => i.name).toList();

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Pallet.borderColor),
            borderRadius: BorderRadius.circular(width * 0.025),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
              value: selectedIndustry,
              dropdownColor: Colors.white,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: width * 0.02,
                  vertical: width * 0.03,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              hint: Text(
                'Industry Type *',
                style: GoogleFonts.dmSans(
                  fontSize: width * 0.035,
                  fontWeight: FontWeight.w500,
                  color: Pallet.greyColor,
                ),
              ),
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.black54),
              items: industryNames.map((String industryName) {
                return DropdownMenuItem<String>(
                  value: industryName,
                  child: Text(
                    industryName,
                    style: GoogleFonts.dmSans(
                      fontSize: width * 0.035,
                      color: Colors.black87,
                    ),
                  ),
                );
              }).toList(),
              onChanged: isSubmitting
                  ? null
                  : (value) {
                if (value != null) {
                  final industry = industries.firstWhere(
                        (i) => i.name == value,
                  );

                  setState(() {
                    selectedIndustry = value;
                    firmIndustryController.text = value;
                    selectedServices.clear();
                  });
                }
              },
              isExpanded: true,
            ),
          ),
        );
      },
      error: (error, stackTrace) {
        print('❌ Error loading industries: $error');
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Pallet.borderColor),
            borderRadius: BorderRadius.circular(width * 0.025),
          ),
          child: Text(
            "Error loading industries",
            style: GoogleFonts.dmSans(
              fontSize: width * 0.035,
              color: Colors.red,
            ),
          ),
        );
      },
      loading: () => Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Pallet.borderColor),
          borderRadius: BorderRadius.circular(width * 0.025),
        ),
        child: Row(
          children: [
            SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Text(
              'Loading industries...',
              style: GoogleFonts.dmSans(
                fontSize: width * 0.035,
                color: Pallet.greyColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build contact persons list
  Widget _buildContactPersonsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: contactPerson.length + 1,
      itemBuilder: (context, index) {
        if (index == contactPerson.length) {
          return _buildAddContactButton();
        }
        return _buildContactPersonItem(index);
      },
    );
  }

  // Build add contact button
  Widget _buildAddContactButton() {
    return GestureDetector(
      onTap: isSubmitting ? null : _addContactPersonField,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: ColorConstants.texFieldColor,
            child: Icon(Icons.add, color: Colors.black54),
          ),
          SizedBox(width: width * 0.02),
          Text(
            'Add another contact person',
            style: TextStyle(
              fontSize: width * 0.045,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  // Build contact person item
  Widget _buildContactPersonItem(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with delete button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Contact Person *: ${index + 1}',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: width * 0.04,
                color: Colors.black54,
              ),
            ),
            if (contactPerson.length > 1)
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed:
                isSubmitting ? null : () => _removeContactPersonField(index),
              ),
          ],
        ),
        SizedBox(height: height * 0.005),

        // Name
        inputField(
          'Name',
          contactPersonNameControllers[index],
          TextInputType.name,
          SizedBox(),
        ),
        SizedBox(height: 10),

        // Phone
        inputField(
          'Mobile Number',
          contactPersonPhoneControllers[index],
          TextInputType.phone,
          SizedBox(),
        ),
        SizedBox(height: 10),

        // Email
        inputField(
          'E-mail',
          contactPersonEmailControllers[index],
          TextInputType.emailAddress,
          SizedBox(),
        ),
        SizedBox(height: height * 0.01),
      ],
    );
  }

  // ✅ Build submit button with loading state
  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: isSubmitting ? null : _submitForm,
      child: Container(
        width: double.infinity,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSubmitting
              ? ColorConstants.buttonColor.withOpacity(0.6)
              : ColorConstants.buttonColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: isSubmitting
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 10),
            Text(
              'Submitting...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        )
            : Text(
          'Submit',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}