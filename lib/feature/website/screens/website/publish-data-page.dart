import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:refrr_admin/Core/common/alertBox.dart';
import 'package:refrr_admin/Core/common/custom-appBar.dart';
import 'package:refrr_admin/Core/common/custom-text-field.dart';
import 'package:refrr_admin/Core/common/globalVariables.dart';
import 'package:refrr_admin/Core/common/loader.dart';
import 'package:refrr_admin/Core/common/snackbar.dart';
import 'package:refrr_admin/Core/common/textEditingControllers.dart' hide pickedImage;
import 'package:refrr_admin/Feature/website/controller/website-controller.dart';
import 'package:refrr_admin/Feature/website/screens/website/web-home-screen.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:refrr_admin/models/website-model.dart';

class PublishSitePage extends ConsumerStatefulWidget {
  final LeadsModel currentFirm;
  final List<String> productIds;
  final List<String> serviceIds;
  const PublishSitePage({
    super.key,
    required this.currentFirm,
    required this.productIds,
    required this.serviceIds,
  });

  @override
  ConsumerState<PublishSitePage> createState() => _PublishSitePageState();
}

class _PublishSitePageState extends ConsumerState<PublishSitePage> {

  @override
  void initState() {
    websiteNameController.text = widget.currentFirm.name;
    websiteImageController.text = widget.currentFirm.logo;
    websiteAboutController.text = widget.currentFirm.aboutFirm;
    websiteNumberController.text = widget.currentFirm.contactNo;
    websiteEmailController.text = widget.currentFirm.mail;
    websiteAdressController.text = widget.currentFirm.address;
    super.initState();
  }
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        pickedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> uploadImageToStorage() async {
    if (pickedImage == null) return null;
    final fileName = 'website_logo_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = FirebaseStorage.instance.ref().child('website_logos/$fileName');
    final uploadTask = await ref.putFile(pickedImage!);
    return await uploadTask.ref.getDownloadURL();
  }

  bool validateFields() {
    if (websiteNameController.text.isEmpty ||
        websiteAboutController.text.isEmpty ||
        websiteNumberController.text.isEmpty ||
        websiteEmailController.text.isEmpty ||
        websiteAdressController.text.isEmpty) {
      showCommonSnackbar(context, 'Please fill in all the fields to continue.');
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final currentFirm = widget.currentFirm;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'Publish Your Site'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(children: [
              inputField('Website Name', websiteNameController,
                  TextInputType.text, const SizedBox()),
              // LOGO pick / preview
              inputField(
                'Logo',
                readOnly: true,
                websiteImageController,
                TextInputType.text,
                GestureDetector(
                  onTap: pickImage,
                  child: buildUploadIcon(),
                ),
              ),
              if (pickedImage != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    pickedImage!,
                    height: 100,
                    width: 300,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              inputField('About Us', websiteAboutController, TextInputType.text,
                  const SizedBox(),
                  maxLines: 3),
            ]),
            const SizedBox(height: 20),
            _buildSection(children: [
              Padding(
                padding: EdgeInsets.only(right: width * .46),
                child: Text(
                  'Contact Details',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              inputField('Mobile Number', websiteNumberController,
                  TextInputType.number, const SizedBox()),
              inputField('E‑mail', websiteEmailController,
                  TextInputType.emailAddress, const SizedBox()),
              inputField('Address', websiteAdressController,
                  TextInputType.streetAddress, const SizedBox()),
            ]),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                onPressed: () async {
                  if (!validateFields()) return;

                  commonAlert(
                    context,
                    'Publish',
                    'Are you sure you want to publish this Website?',
                    'Yes',
                        () async {
                      setState(() => loading = true);

                      try {
                        final logoUrl = await uploadImageToStorage();

                        final websiteModel = WebsiteModel(
                          websiteName: websiteNameController.text,
                          logo: logoUrl ?? '',
                          aboutUs: websiteAboutController.text,
                          phoneNumber: websiteNumberController.text,
                          email: websiteEmailController.text,
                          address: websiteAdressController.text,
                          url:
                          'https://grro.ai/4u/${currentFirm.reference!.id}/',
                          marketerId: currentFirm.reference!.id,
                          productIdList: widget.productIds,
                          serviceIdList: widget.serviceIds,
                        );

                        // ✅ this must return a non‑empty string like the doc ID or URL
                        final success = await ref
                            .read(websiteControllerProvider.notifier)
                            .publishWebsite(
                          website: websiteModel,
                          context: context,
                        );

                        setState(() => loading = false);

                        if (success.isNotEmpty && mounted) {
                          Navigator.of(context, rootNavigator: true).pop();
                          publishSuccessAlertDialog(
                            context: context,
                            title: 'Website Published Successfully',
                            subtitle: 'Your Website is now live and accessible to visitors',
                            websiteUrl: success,
                            onTapClose: () {
                              Navigator.of(context, rootNavigator: true).pop();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => WebsiteHomeScreen(currentFirm: currentFirm),
                                ),
                              );
                            },
                          );
                        } else {
                          showCommonSnackbar(context,
                              'Something went wrong while publishing.');
                        }
                      } catch (e, st) {
                        debugPrint('Publish error: $e\n$st');
                        setState(() => loading = false);
                        Navigator.pop(context); // close alert
                        showCommonSnackbar(context,
                            'Error while publishing. Please check your network.');
                      }
                    },
                  );
                },
                child: loading
                    ? CommonLoader()
                    : Text(
                  'Publish Your Site',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- helpers ----------
  Widget _buildSection({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var w in children) ...[
            w,
            if (w != children.last) SizedBox(height: height * .02),
          ]
        ],
      ),
    );
  }

  Widget buildUploadIcon({double size = 18, Color color = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: SvgPicture.asset(
        'assets/svg/upload.svg',
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      ),
    );
  }
}
