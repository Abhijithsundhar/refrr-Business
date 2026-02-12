import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/alertBox.dart';
import 'package:refrr_admin/Core/common/download-image.dart';
import 'package:refrr_admin/Core/common/share-image.dart';
import 'package:refrr_admin/Core/common/snackbar.dart';
import 'package:refrr_admin/Core/theme/pallet.dart';
import 'package:refrr_admin/Core/constants/asset.dart';
import 'package:refrr_admin/Core/common/globalVariables.dart';
import 'package:refrr_admin/Feature/promote/controller/creative-controller.dart';
import 'package:refrr_admin/Feature/promote/screens/creatives/add-creatives.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:cached_network_image/cached_network_image.dart';


class CreativeScreen extends StatefulWidget {
  final LeadsModel? currentFirm;
  const CreativeScreen({super.key, this.currentFirm});

  @override
  State<CreativeScreen> createState() => _CreativeScreenState();
}

class _CreativeScreenState extends State<CreativeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallet.backgroundColor,
      body: Stack(
        children: [
          /// MAIN CONTENT
          Column(
            children: [
              SizedBox(height: width * 0.02),
              /// LIST
              Expanded(
                child: Consumer(
                  builder: (BuildContext context, WidgetRef ref, Widget? child) {
                    final creatives = ref.watch(
                      creativesStreamProvider(
                        widget.currentFirm?.reference?.id ?? '',
                      ),
                    );

                    return creatives.when(
                      data: (data) {
                        if (data.isEmpty) {
                          return const Center(
                            child: Text('No creatives added'),
                          );
                        }

                        return ListView.builder(
                          padding: EdgeInsets.fromLTRB(
                            width * 0.01,
                            width * 0.01,
                            width * 0.01,
                            height * 0.15,
                          ),
                          itemCount: data.length,
                          itemBuilder: (_, i) {
                            final creative = data[i];

                            return Padding(
                              padding: EdgeInsets.all(width * 0.02),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border:
                                  Border.all(color: Pallet.borderColor),
                                  borderRadius: BorderRadius.circular(
                                    width * 0.05,
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(width * 0.02),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          width * 0.03,
                                        ),
                                        child: CachedNetworkImage(
                                            imageUrl: creative.url??'',
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(height: width * 0.02),

                                      /// ACTION BUTTONS
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          /// SHARE
                                          GestureDetector(
                                            onTap: () {
                                              print('share button tapped');
                                              shareImageFromUrl(creative.url);
                                            },
                                            child: Container(
                                              width: height * 0.175,
                                              height: width * 0.12,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    width * 0.02),
                                                color:
                                                Pallet.secondaryColor,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.center,
                                                children: [
                                                  SvgPicture.asset(
                                                    AssetConstants.share,
                                                    width: width * 0.045,
                                                  ),
                                                  SizedBox(
                                                      width: width * 0.02),
                                                  Text(
                                                    "Share",
                                                    style:
                                                    GoogleFonts.dmSans(
                                                      color: Pallet
                                                          .backgroundColor,
                                                      fontSize:
                                                      width * 0.035,
                                                      fontWeight:
                                                      FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: width * 0.02),

                                          /// DOWNLOAD
                                          GestureDetector(
                                            onTap: () {
                                              commonAlert(
                                                context,
                                                'Download Creative',
                                                'Are you sure want to Download this creative',
                                                'Download',
                                                    () async {
                                                  Navigator.pop(context);

                                                  try {
                                                    await downloadImageToAppDir(creative.url);
                                                    showCommonSnackbar(context, 'Image downloaded successfully');
                                                  } catch (e) {
                                                    showCommonSnackbar(context, 'Download failed');
                                                  }
                                                },
                                              );
                                            },
                                            child: Container(
                                              width: height * 0.175,
                                              height: width * 0.12,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    width * 0.02),
                                                color:
                                                Pallet.borderColor,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.center,
                                                children: [
                                                  SvgPicture.asset(
                                                    AssetConstants.download,
                                                    width: width * 0.05,
                                                  ),
                                                  SizedBox(
                                                      width: width * 0.02),
                                                  Text("Download",
                                                    style:
                                                    GoogleFonts.dmSans(
                                                      color:
                                                      Pallet.greyColor,
                                                      fontSize:
                                                      width * 0.035,
                                                      fontWeight:
                                                      FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: width * 0.02),

                                          /// DELETE
                                          GestureDetector(
                                            onTap: () {
                                              commonAlert(context, 'Delete Creative',
                                                'Are you sure want to Delete this creative', 'Delete',
                                                    () {
                                                  ref.read(creativeControllerProvider.notifier)
                                                      .deleteCreative(leadId: widget.currentFirm?.reference?.id ?? '',
                                                    creativeId:
                                                    creative.id ?? '',
                                                    context: context,
                                                  );
                                                  Navigator.pop(context);
                                                },
                                              );
                                            },
                                            child: Container(
                                              width: height * 0.06,
                                              height: width * 0.12,
                                              padding: EdgeInsets.all(
                                                  width * 0.02),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    width * 0.02),
                                                color:
                                                Pallet.borderColor,
                                              ),
                                              child: const Icon(
                                                CupertinoIcons.delete,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      loading: () =>
                      const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text(e.toString())),
                    );
                  },
                ),
              ),
            ],
          ),

          /// ADD CREATIVE BUTTON (FIXED POSITION)
          Positioned(
            bottom: width * 0.04,
            right: width * 0.04,
            child: ElevatedButton(
              onPressed: () {
                addCreativePopUp(context, widget.currentFirm);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Pallet.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(width * 0.02),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.04,
                  vertical: width * 0.02,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    AssetConstants.add,
                    width: width * 0.045,
                  ),
                  SizedBox(width: width * 0.01),
                  Text(
                    "Add Creative",
                    style: GoogleFonts.dmSans(
                      color: Pallet.backgroundColor,
                      fontSize: width * 0.035,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
