import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Feature/Login/Controller/lead-controllor.dart';
import 'package:refrr_admin/Core/common/alertBox.dart';
import '../../../Core/common/custom-dropDown.dart';
import '../../../Core/common/global variables.dart';
import '../../../Core/common/image-picker.dart';
import '../../../Core/common/loadings.dart';
import '../../../Core/common/multiple-select-dropdown.dart';
import '../../../Core/common/search-query.dart';
import '../../../Core/common/snackbar.dart';
import '../../../Core/common/textEditingControllers.dart';
import 'package:refrr_admin/Core/constants/color-constnats.dart';
import 'package:refrr_admin/models/contact-person-model.dart';
import 'package:refrr_admin/models/firm-model.dart';
import 'package:refrr_admin/models/industry-model.dart';
import '../../../models/affiliate-model.dart';
import 'package:refrr_admin/models/leads_model.dart';
import '../Controller/industry-controler.dart';

class AddFirmScreen extends StatefulWidget {
  final LeadsModel? leads;
  final AffiliateModel? affiliate;
  const AddFirmScreen({super.key, this.leads, this.affiliate});

  @override
  State<AddFirmScreen> createState() => _AddFirmScreenState();
}

class _AddFirmScreenState extends State<AddFirmScreen> {
  late List<ContactPersonModel> contactPerson = [];
  List<TextEditingController> contactPersonNameControllers = [];
  List<TextEditingController> contactPersonPhoneControllers = [];
  List<TextEditingController> contactPersonEmailControllers = [];

  late final List<FocusNode> focusNodes = [];
  void _addTextField() {
    contactPerson.add(ContactPersonModel(personName: '', phoneNumber: '', mailId: ''));
    contactPersonNameControllers.add(TextEditingController());
    contactPersonPhoneControllers.add(TextEditingController());
    contactPersonEmailControllers.add(TextEditingController());
    setState(() {});
  }
  void _removeTextField(int index) {
    contactPerson.removeAt(index);
    contactPersonNameControllers.removeAt(index);
    contactPersonPhoneControllers.removeAt(index);
    contactPersonEmailControllers.removeAt(index);
    setState(() {});
  }

  String? uploadedPdfUrl;
  String? pdfFileName;
  String? pdfSize;
  bool isUploading = false;
  PickedImage? pickedProfile;

  // Add image upload variables
  String? uploadedImageUrl;
  bool isUploadingImage = false;

  // Add method to upload image to Firebase
  Future<void> uploadImageToFirebase(File imageFile) async {
    try {
      setState(() {
        isUploadingImage = true;
      });

      // Create a reference to Firebase Storage
      final ref = FirebaseStorage.instance
          .ref()
          .child('logos/${DateTime.now().toIso8601String()}_logo.jpg');

      // Upload the file
      final uploadTask = await ref.putFile(imageFile);

      // Get the download URL
      final downloadUrl = await ref.getDownloadURL();

      setState(() {
        uploadedImageUrl = downloadUrl;
        isUploadingImage = false;
      });

      print("Image uploaded: $uploadedImageUrl");
    } catch (e) {
      setState(() {
        isUploadingImage = false;
      });
      print("Error uploading image: $e");
      showCommonSnackbar(context, 'Error uploading image: ${e.toString()}');
    }
  }

  @override
  void initState() {
    super.initState();
    firmNameController.text = '';
    firmAddressController.text = '';
    firmPhoneNoController.text = '';
    firmEmailController.text = '';
    firmWebsiteController.text = '';
    if (contactPerson.isEmpty) {
      _addTextField();
      focusNodes.add(FocusNode());
    }
    // pdfs = [];
    pickedImage = null;
    uploadedImageUrl = null;
    uploadedPdfUrl = null;
    pdfFileName = null;
  }
  List<String> selectedServices = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back_ios_new, color: Colors.black)),
        elevation: 0,
        // toolbarHeight: height*.03,
      ),
      // CHANGED: Removed Stack, made a single scrollable page
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title moved here
            Padding(
              padding: EdgeInsets.only(left: width*.08,),
              child: Text(
                'Add Lead',
                style: GoogleFonts.roboto(
                  fontSize: width * 0.05,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.only( left: 16, right: 16,top: height*.03),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(45)),
              ),
              child: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    children: [
                      /// 1. Name
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: ColorConstants.texFieldColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextFormField(
                          style: TextStyle(color: Colors.black54),
                          controller: firmNameController,
                          decoration: InputDecoration(
                            hintText: 'Name',
                            hintStyle: TextStyle(color: Colors.black54),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),

                      /// 2. Industry type

                      Container(
                        decoration: BoxDecoration(
                          color: ColorConstants.texFieldColor,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        margin: EdgeInsets.only(bottom: 16.0),
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Consumer(
                          builder: (context, ref, _) {
                            final selectedIndustryName = ref.watch(industryModelProvider);

                            return ref.watch(industryStreamProvider('')).when(
                              data: (data) {
                                // Convert list to map: {industryName: IndustryModel}
                                final Map<String, IndustryModel> items = {
                                  for (var a in data) a.industryName: a
                                };

                                // 🟡 Optional: Set services if an industry is already selected
                                if (selectedIndustryName != null && items.containsKey(selectedIndustryName)) {
                                  final industry = items[selectedIndustryName];
                                  final svcs = List<String>.from(industry!.services);
                                  ref.read(listOfServiceProvider.notifier).state = svcs;
                                }

                                return CustomSearchDropDowns(
                                  dropItemList: items.keys.toList(),
                                  hint: "Industry Type",
                                  w: 300,
                                  onChange: (value) {
                                    if (value != null && value.isNotEmpty && items.containsKey(value)) {
                                      final industry = items[value]!;

                                      // Update selected industry name
                                      ref.read(industryModelProvider.notifier).state = selectedIndustryName;

                                      // Update dependent services
                                      final svcs = List<String>.from(industry.services);
                                      ref.read(listOfServiceProvider.notifier).state = svcs;

                                      // Update UI
                                      firmIndustryController.text = value;
                                      setState(() {
                                        selectedServices.clear();
                                      });
                                    }
                                  },
                                );
                              },
                              error: (error, _) => Text("Error loading industries: $error"),
                              loading: () => const CircularProgressIndicator(),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      /// 3. service

                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: ColorConstants.texFieldColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Consumer(builder: (context3, ref, child3) {
                          final listOfservice = ref.watch(listOfServiceProvider); // services for selected industry

                          return listOfservice.isNotEmpty
                              ? MultiSelectDropdown(
                            dropItemList: listOfservice,
                            hint: "Select Services",
                            w: width * .15,
                            onChange: (items) {
                              setState(() {
                                selectedServices = items;
                                // keep your text controller in sync (used elsewhere in your model)
                                firmServiceController.text = items.join(', ');
                              });
                            },
                            decoration: InputDecoration(
                              hintText: "Select Services",
                              hintStyle: TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                              ),
                              contentPadding: EdgeInsets.only(top: height * .015, right: width * .02),
                              border: InputBorder.none,
                              suffixIcon: Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                            ),
                          )
                              : SizedBox();
                        }),
                      ),

                      SizedBox(height: 10),
                      // Display selected services
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: selectedServices.map((service) {
                          return Chip(
                            label: Text(service),
                            deleteIcon: Icon(Icons.close),
                            onDeleted: () {
                              setState(() {
                                selectedServices.remove(service);
                              });
                            },
                          );
                        }).toList(),
                      ),

                      /// 4. Address (more height)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: ColorConstants.texFieldColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextFormField(
                          controller: firmAddressController,
                          style: TextStyle(color: Colors.black54),
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Address',
                            hintStyle: TextStyle(color: Colors.black54, fontSize: width*.045),
                            border: InputBorder.none,
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            alignLabelWithHint: true,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),

                      /// 5. ph-no
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: ColorConstants.texFieldColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextFormField(
                          controller: firmPhoneNoController,
                          style: TextStyle(color: Colors.black54),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Phone No',
                            hintStyle: TextStyle(color: Colors.black54),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),

                      /// 6. mail-id
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: ColorConstants.texFieldColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextFormField(
                          controller: firmEmailController,
                          style: TextStyle(color: Colors.black54),
                          decoration: InputDecoration(
                            hintText: 'Mail ID',
                            hintStyle: TextStyle(color: Colors.black54),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),

                      /// 7. website
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: ColorConstants.texFieldColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextFormField(
                          controller: firmWebsiteController,
                          style: TextStyle(color: Colors.black54),
                          decoration: InputDecoration(
                            hintText: 'Website',
                            hintStyle: TextStyle(color: Colors.black54),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      /// 8. location
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: ColorConstants.texFieldColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextFormField(
                          controller: firmLocationController,
                          style: TextStyle(color: Colors.black54),
                          decoration: InputDecoration(
                            hintText: 'Location',
                            hintStyle: TextStyle(color: Colors.black54),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),

                      /// 9.Contact person details
                      SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: contactPerson.length + 1,
                        itemBuilder: (context, index) {
                          if (index == contactPerson.length) {
                            // Add Button
                            return GestureDetector(
                              onTap: _addTextField,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: ColorConstants.texFieldColor,
                                    child: Icon(Icons.add, color: Colors.black54),
                                  ),
                                  SizedBox(width: width * .02),
                                  Text(
                                    'Add another contact person',
                                    style: TextStyle(
                                      fontSize: width * .045,
                                      color: Colors.black54,
                                    ),
                                  )
                                ],
                              ),
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Serial Number and Delete Button
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Contact Person :${index + 1}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: width * .04,
                                        color: Colors.black54
                                    ),
                                  ),
                                  if (contactPerson.length > 1)
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _removeTextField(index),
                                    ),
                                ],
                              ),
                              SizedBox(height: height * .005),

                              // Name Field
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: ColorConstants.texFieldColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: TextFormField(
                                  controller: contactPersonNameControllers[index],
                                  style: TextStyle(color: Colors.black54),
                                  decoration: InputDecoration(
                                    hintText: 'Name',
                                    hintStyle: TextStyle(color: Colors.black54),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),

                              // Phone Number Field
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: ColorConstants.texFieldColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: TextFormField(
                                  controller: contactPersonPhoneControllers[index],
                                  style: TextStyle(color: Colors.black54),
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    hintText: 'Phone No',
                                    hintStyle: TextStyle(color: Colors.black54),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),

                              // Mail ID Field
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: ColorConstants.texFieldColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: TextFormField(
                                  controller: contactPersonEmailControllers[index],
                                  style: TextStyle(color: Colors.black54),
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    hintText: 'Email',
                                    hintStyle: TextStyle(color: Colors.black54),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              SizedBox(height: height * .01),
                            ],
                          );
                        },
                      ),

                      SizedBox(height: 10),
                      /// 10. requirement
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: ColorConstants.texFieldColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextFormField(
                          controller: firmRequirementsController,
                          style: TextStyle(color: Colors.black54),
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Requirements',
                            hintStyle: TextStyle(color: Colors.black54, fontSize: width*.045),
                            border: InputBorder.none,
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            alignLabelWithHint: true,
                          ),
                        ),
                      ),

                      /// Add logo
                      // SizedBox(height: 10),
                      // GestureDetector(
                      //   onTap: () async {
                      //     final picked = await ImagePickerHelper.pickImage();
                      //     if (picked != null) {
                      //       setState(() {
                      //         pickedProfile = picked;
                      //       });
                      //     } else {
                      //       print("No image selected.");
                      //     }
                      //   },
                      //   child: Container(
                      //     height: height * .2,
                      //     padding: EdgeInsets.symmetric(horizontal: 12),
                      //     decoration: BoxDecoration(
                      //       color: ColorConstants.texFieldColor,
                      //       borderRadius: BorderRadius.circular(10),
                      //     ),
                      //     child: Stack(
                      //       children: [
                      //         Positioned(
                      //           top: 8,
                      //           left: 8,
                      //           child: Text(
                      //             'Add Logo',
                      //             style: TextStyle(
                      //               fontSize: width*.045,
                      //               color: Colors.grey,
                      //             ),
                      //           ),
                      //         ),
                      //         Center(
                      //           child: isUploadingImage
                      //               ? CircularProgressIndicator()
                      //               : pickedImage != null
                      //               ? Stack(
                      //             children: [
                      //               SizedBox(
                      //                 height: height * .15,
                      //                 width: width * .3,
                      //                 child: Image.file(
                      //                   pickedImage!,
                      //                   fit: BoxFit.contain,
                      //                 ),
                      //               ),
                      //               Positioned(
                      //                 top: 0,
                      //                 right: 0,
                      //                 child: GestureDetector(
                      //                   onTap: () {
                      //                     showCustomAlertBox(context, 'Are you sure to delete?', () {
                      //                       setState(() {
                      //                         pickedImage = null;
                      //                         uploadedImageUrl = null;
                      //                       });
                      //                     });
                      //                   },
                      //                   child: CircleAvatar(
                      //                     backgroundColor: Colors.white,
                      //                     radius: width*.03,
                      //                     child: Icon(
                      //                       Icons.delete,
                      //                       color: Colors.red,
                      //                       size: width*.04,
                      //                     ),
                      //                   ),
                      //                 ),
                      //               ),
                      //             ],
                      //           )
                      //               : Icon(Icons.image, color: Colors.grey),
                      //         )
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      //
                      // /// Add File
                      // SizedBox(height: 10),
                      // GestureDetector(
                      //   onTap: () {
                      //     pickAndUploadPdf();
                      //   },
                      //   child: Container(
                      //     height: height * .2,
                      //     padding: EdgeInsets.symmetric(horizontal: 12),
                      //     decoration: BoxDecoration(
                      //       color: ColorConstants.texFieldColor,
                      //       borderRadius: BorderRadius.circular(10),
                      //     ),
                      //     child: Stack(
                      //       children: [
                      //         Positioned(
                      //           top: 8,
                      //           left: 8,
                      //           child: Text(
                      //             'Add File',
                      //             style: TextStyle(
                      //               fontSize: width*.045,
                      //               color: Colors.grey,
                      //             ),
                      //           ),
                      //         ),
                      //         Center(
                      //           child: isUploading
                      //               ? Column(
                      //             mainAxisAlignment: MainAxisAlignment.center,
                      //             children: [
                      //               CircularProgressIndicator(),
                      //               SizedBox(height: 8),
                      //               Text(
                      //                 'Uploading...',
                      //                 style: TextStyle(
                      //                   color: Colors.grey,
                      //                   fontSize: width * 0.035,
                      //                 ),
                      //               ),
                      //             ],
                      //           )
                      //               : uploadedPdfUrl != null && pdfFileName != null
                      //               ? Column(
                      //             mainAxisAlignment: MainAxisAlignment.center,
                      //             children: [
                      //               Icon(Icons.picture_as_pdf,
                      //                   color: Colors.red,
                      //                   size: width * 0.1),
                      //               SizedBox(height: 8),
                      //               Text(
                      //                 pdfFileName!,
                      //                 style: TextStyle(
                      //                   color: Colors.grey,
                      //                   fontSize: width * 0.035,
                      //                   fontWeight: FontWeight.w500,
                      //                 ),
                      //                 textAlign: TextAlign.center,
                      //                 maxLines: 2,
                      //                 overflow: TextOverflow.ellipsis,
                      //               ),
                      //               if (pdfSize != null)
                      //                 Text(
                      //                   pdfSize!,
                      //                   style: TextStyle(
                      //                     color: Colors.grey.shade600,
                      //                     fontSize: width * 0.03,
                      //                   ),
                      //                 ),
                      //             ],
                      //           )
                      //               : Icon(Icons.file_copy, color: Colors.grey),
                      //         ),
                      //         // Delete button for PDF
                      //         if (uploadedPdfUrl != null)
                      //           Positioned(
                      //             top: 8,
                      //             right: 8,
                      //             child: GestureDetector(
                      //               onTap: () {
                      //                 showCustomAlertBox(context, 'Are you sure to delete this file?', () {
                      //                   setState(() {
                      //                     uploadedPdfUrl = null;
                      //                     pdfFileName = null;
                      //                     pdfSize = null;
                      //                     // Remove from pdfs list if needed
                      //                     if (pdfs.isNotEmpty) {
                      //                       pdfs.removeLast();
                      //                     }
                      //                   });
                      //                 });
                      //               },
                      //               child: CircleAvatar(
                      //                 backgroundColor: Colors.white,
                      //                 radius: width*.025,
                      //                 child: Icon(
                      //                   Icons.delete,
                      //                   color: Colors.red,
                      //                   size: width*.035,
                      //                 ),
                      //               ),
                      //             ),
                      //           ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      /// Submit button
                      SizedBox(height: 20),
                      Consumer(
                        builder: (BuildContext context, WidgetRef ref, Widget? child) {
                          return GestureDetector(
                            onTap: () async {
                              if (firmNameController.text.isEmpty) {
                                showCommonSnackbar(context, 'Please Enter Name');
                                return;
                              }
                              if (firmIndustryController.text.isEmpty) {
                                showCommonSnackbar(context, 'Please Select Industry type');
                                return;
                              }
                              if (selectedServices.isEmpty) {
                                showCommonSnackbar(context, 'Please Select Service');
                                return;
                              }
                              if (firmAddressController.text.isEmpty) {
                                showCommonSnackbar(context, 'Please Enter Address');
                                return;
                              }
                              if (firmPhoneNoController.text.isEmpty) {
                                showCommonSnackbar(context, 'Please Enter Phone No');
                                return;
                              }
                              // if (firmEmailController.text.isEmpty) {
                              //   showCommonSnackbar(context, 'Please Enter Mail ID');
                              //   return;
                              // }

                              showCommonAlertBox(context, 'Do you want add this firm?', () async {
                                contactPerson = List.generate(contactPerson.length, (index) {
                                  return ContactPersonModel(
                                    personName: contactPersonNameControllers[index].text.trim(),
                                    phoneNumber: contactPersonPhoneControllers[index].text.trim(),
                                    mailId: contactPersonEmailControllers[index].text.trim(),
                                  );
                                });

                                final firmDocRef = FirebaseFirestore.instance
                                    .collection('leads')
                                    .doc(widget.leads!.reference!.id).collection('firms').doc();
                                // Create a new firm from input
                                final newFirm = AddFirmModel(
                                  name: firmNameController.text.trim(),
                                  industryType: firmIndustryController.text.trim(),
                                  service: firmServiceController.text.trim(),
                                  address: firmAddressController.text.trim(),
                                  phoneNo: int.tryParse(firmPhoneNoController.text) ?? 0,
                                  email: firmEmailController.text.trim(),
                                  website: firmWebsiteController.text.trim(),
                                  contactPersons: contactPerson,
                                  logo: uploadedImageUrl ?? '', // Use the Firebase URL
                                  addFile: uploadedPdfUrl ?? '', // Use the Firebase URL
                                  marketerId: widget.affiliate!.id ?? '',
                                  delete: false,
                                  createTime: DateTime.now(),
                                  search: setSearchParam(
                                    firmNameController.text.trim().toUpperCase() +
                                        ' ' +
                                        firmIndustryController.text.trim().toUpperCase() +
                                        ' ' +
                                        firmServiceController.text.trim().toUpperCase() +
                                        ' ' +
                                        firmAddressController.text.trim().toUpperCase() +
                                        ' ' +
                                        firmPhoneNoController.text.trim().toUpperCase() +
                                        ' ' +
                                        firmLocationController.text.trim().toUpperCase() +
                                        ' ' +
                                        firmEmailController.text.trim().toUpperCase(),
                                  ),
                                  location: firmLocationController.text??'',
                                  status: 'Pending',
                                  requirement: firmRequirementsController.text ??'',
                                  services: [],
                                  reference: firmDocRef,
                                );

                                // Clone the old firms list and add new one
                                final updatedFirms = [...(widget.leads!.firms ?? []), newFirm];

                                // Copy the lead and update the firms list
                                final updatedLead = widget.leads!.copyWith(firms: updatedFirms.cast<AddFirmModel>());

                                // Call the update method
                                await ref.read(leadControllerProvider.notifier)
                                    .updateLead(context: context, leadModel: updatedLead);
                                Navigator.pop(context);
                                // Navigator.push(context, MaterialPageRoute(
                                //   builder: (context) => BottomBarSection(affiliate: widget.affiliate),
                                // ));

                                ref.invalidate(leadControllerProvider);
                                hideLoading(context);

                                // Clear input fields
                                firmNameController.clear();
                                firmIndustryController.clear();
                                firmServiceController.clear();
                                firmAddressController.clear();
                                firmPhoneNoController.clear();
                                firmEmailController.clear();
                                firmWebsiteController.clear();
                                contactPersonNameController.clear();
                                contactPersonPhoneController.clear();
                                contactPersonemailController.clear();
                                firmRequirementsController.clear();
                                firmLocationController.clear();
                              },'Yes');
                            },
                            child: Container(
                              width: double.infinity,
                              height: 50,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: ColorConstants.buttonColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Submit',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: height*.03),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}