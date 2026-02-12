import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:refrr_admin/Core/common/custom-text-field.dart';
import 'package:refrr_admin/Core/common/globalVariables.dart';
import 'package:refrr_admin/Core/common/image-convert-to-url.dart';
import 'package:refrr_admin/Core/common/snackbar.dart';
import 'package:refrr_admin/Core/common/textEditingControllers.dart';
import 'package:refrr_admin/Core/constants/asset.dart';
import 'package:refrr_admin/Core/theme/pallet.dart';
import 'package:refrr_admin/Feature/Team/screens/bottomsheets/add-own-team-bottomsheet2.dart' hide fieldHeight;
import 'package:refrr_admin/models/leads_model.dart';


void registrationBottomSheet(BuildContext context, LeadsModel? currentFirm) {
  final parentContext = context;
  Uint8List? selectedImageBytes;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Pallet.backgroundColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(width * 0.05),
      ),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {

          Future<void> pickAndUploadImage() async {
            try {
              final ImagePicker picker = ImagePicker();
              final XFile? pickedFile =
              await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

              if (pickedFile == null) return;

              // ✅ Correct: use the public Uint8List from dart:typed_data
              final Uint8List bytes = await pickedFile.readAsBytes();

              setState(() {
                selectedImageBytes = bytes;
                isImageUploading = true;
              });

              final uploadedUrl =
              await uploadImage(image: pickedFile, context: context);

              setState(() {
                isImageUploading = false;
                uploadedImageUrl = uploadedUrl;
              });

              if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
                showCommonSnackbar(context, "Image uploaded successfully");
              } else {
                showCommonSnackbar(
                    context, "Image upload failed, but you can continue");
              }
            } catch (e) {
              setState(() => isImageUploading = false);
              showCommonSnackbar(context, "Failed to pick or upload image");
              debugPrint("❌ Image picker error: $e");
            }
          }

          bool validateFields() {
            print("🔍 Starting validation...");

            if (marketerNameController.text.trim().isEmpty) {
              print("❌ Name is empty");
              showCommonSnackbar(context, "Please enter your full name");
              return false;
            }
            print("✅ Name: ${marketerNameController.text}");

            if (selectedGender == null || selectedGender!.isEmpty) {
              print("❌ Gender not selected");
              showCommonSnackbar(context, "Please select your gender");
              return false;
            }
            print("✅ Gender: $selectedGender");

            if (selectedCountry == null || selectedCountry!.isEmpty) {
              print("❌ Country not selected");
              showCommonSnackbar(context, "Please select your country");
              return false;
            }
            print("✅ Country: $selectedCountry");

            if (marketerPhoneNOController.text.trim().isEmpty) {
              print("❌ Phone is empty");
              showCommonSnackbar(context, "Please enter your mobile number");
              return false;
            }
            print("✅ Phone: ${marketerPhoneNOController.text}");

            if (marketerEmailController.text.trim().isEmpty) {
              print("❌ Email is empty");
              showCommonSnackbar(context, "Please enter your email");
              return false;
            }

            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                .hasMatch(marketerEmailController.text.trim())) {
              print("❌ Email format invalid");
              showCommonSnackbar(context, "Please enter a valid email");
              return false;
            }
            print("✅ Email: ${marketerEmailController.text}");

            if (marketerAgeController.text.trim().isEmpty) {
              print("❌ Age is empty");
              showCommonSnackbar(context, "Please enter your age");
              return false;
            }

            int? age = int.tryParse(marketerAgeController.text.trim());
            if (age == null) {
              print("❌ Age is not a valid number");
              showCommonSnackbar(context, "Please enter a valid age");
              return false;
            }
            print("✅ Age: $age");

            if (selectedLanguage == null || selectedLanguage!.isEmpty) {
              print("❌ Language not selected");
              showCommonSnackbar(context, "Please select your language");
              return false;
            }
            print("✅ Language: $selectedLanguage");

            if (marketerUserIdController.text.trim().isEmpty) {
              print("❌ User ID is empty");
              showCommonSnackbar(context, "Please enter your User ID");
              return false;
            }
            print("✅ User ID: ${marketerUserIdController.text}");

            if (marketerPasswordController.text.trim().isEmpty) {
              print("❌ Password is empty");
              showCommonSnackbar(context, "Please enter your password");
              return false;
            }

            if (marketerPasswordController.text.trim().length < 6) {
              print("❌ Password too short");
              showCommonSnackbar(
                  context, "Password must be at least 6 characters");
              return false;
            }
            print("✅ Password: ${marketerPasswordController.text.length} chars");

            print("✅✅✅ All validation passed!");
            return true;
          }

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                left: width * 0.03,
                right: width * 0.03,
                top: width * 0.05,
                bottom:
                MediaQuery.of(context).viewInsets.bottom + width * 0.05,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      height: 4,
                      width: 50,
                      margin: EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  Container(
                    width: width,
                    padding: EdgeInsets.all(width * 0.02),
                    decoration: BoxDecoration(
                      color: Pallet.lightBlue,
                      borderRadius: BorderRadius.circular(width * 0.02),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Personal Information",
                          style: GoogleFonts.dmSans(
                            fontSize: width * 0.04,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: width * 0.02),
                        Row(
                          children: [
                            _stepCircle("1", true),
                            _stepLine(true),
                            _stepCircle("2", false),
                            _stepLine(false),
                            _stepCircle("3", false),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: width * 0.02),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: pickAndUploadImage,
                        child: Container(
                          width: width * 0.3,
                          height: height * 0.15,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: selectedImageBytes != null
                                  ? Pallet.secondaryColor
                                  : Pallet.borderColor,
                              width: selectedImageBytes != null ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(width * 0.02),
                          ),
                          child: selectedImageBytes != null
                              ? ClipRRect(
                            borderRadius:
                            BorderRadius.circular(width * 0.02),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.memory(selectedImageBytes!,
                                  fit: BoxFit.cover,
                                ),
                                if (isImageUploading)
                                  Container(
                                    color: Colors.black45,
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: width * 0.08,
                                            height: width * 0.08,
                                            child:
                                            CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                          SizedBox(height: width * 0.01),
                                          Text(
                                            "Uploading...",
                                            style: GoogleFonts.dmSans(
                                              color: Colors.white,
                                              fontSize: width * 0.025,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                if (!isImageUploading)
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding:
                                      EdgeInsets.all(width * 0.01),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(
                                              width * 0.02),
                                          bottomRight: Radius.circular(
                                              width * 0.02),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                            size: width * 0.035,
                                          ),
                                          SizedBox(width: width * 0.01),
                                          if (uploadedImageUrl != null)
                                            Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                              size: width * 0.035,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          )
                              : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                AssetConstants.upload,
                                width: width * 0.05,
                              ),
                              SizedBox(height: width * 0.005),
                              Text("Upload Image",
                                style: GoogleFonts.dmSans(
                                  fontSize: width * 0.03,
                                  color: Pallet.greyColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: width * 0.02),
                      Expanded(
                        child: Column(
                          children: [
                            SizedBox(
                              height: fieldHeight,
                              child: inputField("Full Name",
                                  marketerNameController, TextInputType.name, SizedBox()),
                            ),
                            SizedBox(height: width * 0.01),
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: fieldHeight,
                                    child: dropdownField<String>(
                                      label: "Gender",
                                      value: selectedGender,
                                      items: genderList
                                          .map(
                                            (e) => DropdownMenuItem<String>(
                                          value: e,
                                          child: Text(e),
                                        ),
                                      )
                                          .toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedGender = value;
                                          marketerGenderController.text =
                                              value ?? "";
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(width: width * 0.01),
                                Expanded(
                                  child: SizedBox(
                                    height: fieldHeight,
                                    child: dropdownField<String>(
                                      label: "Country",
                                      value: selectedCountry,
                                      items: countryList
                                          .map(
                                            (e) => DropdownMenuItem<String>(
                                          value: e,
                                          child: Text(e),
                                        ),
                                      )
                                          .toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedCountry = value;
                                          marketerCountryController.text =
                                              value ?? "";
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: width * 0.02),
                  SizedBox(
                    height: fieldHeight,
                    child: inputField("Mobile Number",
                        marketerPhoneNOController, TextInputType.number, SizedBox()),
                  ),
                  SizedBox(height: width * 0.02),
                  SizedBox(
                    height: fieldHeight,
                    child: inputField("Email", marketerEmailController,
                        TextInputType.emailAddress, SizedBox()),
                  ),
                  SizedBox(height: width * 0.02),
                  SizedBox(
                    height: fieldHeight,
                    child: inputField("Age", marketerAgeController,
                        TextInputType.number, SizedBox()),
                  ),
                  SizedBox(height: width * 0.02),
                  SizedBox(
                    height: fieldHeight,
                    child: dropdownField<String>(
                      label: "Language",
                      value: selectedLanguage,
                      items: languageList
                          .map((e) => DropdownMenuItem<String>(
                        value: e,
                        child: Text(e),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedLanguage = value;
                          marketerLanguageController.text = value ?? "";
                        });
                      },
                    ),
                  ),
                  SizedBox(height: width * 0.02),
                  SizedBox(
                    height: fieldHeight,
                    child: inputField("User ID", marketerUserIdController,
                        TextInputType.text, SizedBox()),
                  ),
                  SizedBox(height: width * 0.02),
                  SizedBox(
                    height: fieldHeight,
                    child: inputField("Password", marketerPasswordController,
                        TextInputType.visiblePassword, SizedBox()),
                  ),
                  SizedBox(height: width * 0.02),
                  SizedBox(
                    width: double.infinity,
                    height: width * 0.13,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Pallet.secondaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(width * 0.02),
                        ),
                      ),
                      onPressed: () {
                        print("🔘 Next button clicked");
                        if (validateFields()) {
                          print("✅ Validation passed, closing sheet...");
                          Navigator.pop(context);
                          print("✅ Opening next sheet...");
                          _showSlideSheet(
                            parentContext,
                            registration2BottomSheet(parentContext, currentFirm),
                          );
                        } else {
                          print("❌ Validation failed");
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Next",
                            style: GoogleFonts.dmSans(
                              color: Colors.white,
                              fontSize: width * 0.04,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: width * 0.01),
                          Icon(
                            Icons.arrow_forward_ios_outlined,
                            color: Colors.white,
                            size: width * 0.04,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

void _showSlideSheet(BuildContext context, Widget sheet) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return sheet;
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      );
    },
  );
}

Widget _stepCircle(String text, bool active) {
  return Container(
    width: width * 0.05,
    height: width * 0.05,
    decoration: BoxDecoration(
      color: active ? const Color(0xFF00C9D7) : Colors.white,
      border: Border.all(
        color: active ? const Color(0xFF00C9D7) : Colors.grey.shade300,
      ),
      shape: BoxShape.circle,
    ),
    child: Center(
      child: Text(
        text,
        style: GoogleFonts.dmSans(
          fontSize: width * 0.03,
          color: active ? Colors.white : Colors.black54,
        ),
      ),
    ),
  );
}

Widget _stepLine(bool active) {
  return Expanded(
    child: Container(
      height: 2,
      color: active ? const Color(0xFF00C9D7) : Colors.grey.shade300,
    ),
  );
}

