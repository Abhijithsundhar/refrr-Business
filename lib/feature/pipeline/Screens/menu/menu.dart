import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/alertBox.dart';
import 'package:refrr_admin/Core/common/globalVariables.dart';
import 'package:refrr_admin/Core/common/snackbar.dart';
import 'package:refrr_admin/Feature/Login/Screens/contact-us.dart';
import 'package:refrr_admin/Feature/Login/Screens/login-page.dart';
import 'package:refrr_admin/Feature/pipeline/Screens/menu/view-profile.dart';
import 'package:refrr_admin/Feature/pipeline/Screens/menu/privacy-policy.dart';
import 'package:refrr_admin/Feature/pipeline/Screens/menu/settings.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuBottomSheet extends ConsumerWidget {
   final String appBarTitle;
   final LeadsModel currentFirm;
  const MenuBottomSheet({super.key, required this.appBarTitle, required this.currentFirm});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    return Container(
      padding: EdgeInsets.only(
        left: width * .04,
        right: width * .04,
        top: width * .04,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top drag handle
          Container(
            width: 50,
            height: 4,
            decoration: BoxDecoration(
              color: Color(0xFF49454F),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          SizedBox(height: height * 0.02),

          // Welcome text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT SIDE
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1 → SVG + Welcome
                  Row(
                    children: [
                      SvgPicture.asset(
                        "assets/svg/waving-hand.svg",
                        height: width * 0.05,
                        width: width * 0.05,
                      ),
                      SizedBox(width: 6),
                      Text(
                        "Welcome,",
                        style: GoogleFonts.dmSans(
                          fontSize: width * 0.04,
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  // Row 2 → Company name
                  Padding(
                    padding: EdgeInsets.only(left: width * .035),
                    child: Text(appBarTitle.length > 24
                          ? appBarTitle.substring(0, 24) : appBarTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSans(
                        fontSize: width * 0.055,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),

              // RIGHT SIDE BUTTONS
              Padding(
                padding:  EdgeInsets.only(right: width*.01,top: height*.01),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: CircleAvatar(
                        radius: width * .04,
                        backgroundColor: const Color(0xFFF3F3F3),
                        child: const Icon(Icons.close, size: 18),
                      ),
                    ),
                    SizedBox(width: width * 0.01),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: height * .02),

          /// Options List
          // buildMenuItem(
          //   label: "Account",
          //   url:'assets/svg/accountGrey.svg',
          //   context: context,
          //   onTap: () {
          //     Navigator.push(context, MaterialPageRoute(builder: (context) => AccountScreen(currentFirm: currentFirm)));
          //   },
          // ),
          buildMenuItem(
            label: "Profile",
            url:'assets/svg/personEdit.svg',
            context: context, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ViewProfile( currentFirm: currentFirm,),));
          },
          ),
          buildMenuItem(
            label: "Contact Us",
            url: 'assets/svg/blackphone.svg',
            context: context, onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ContactUs(),));
          },
          ),
          buildMenuItem(
            label: "Privacy Policy",
            url: 'assets/svg/privacy.svg',
            context: context, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => PrivacyPolicy()));

          },
          ),
          buildMenuItem(
            label: "Settings",
            url: 'assets/svg/settings.svg',
            context: context, onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen(currentFirm: currentFirm,),));
          },
          ),
          buildMenuItem(
            label: "Logout",
            url: 'assets/svg/logOut.svg',
            context: context,
            onTap: () {
              showLogoutDialog(context, () async {
                // ‼️ 2.  Clear login/session flag
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();         // or remove only the login key if you have one

                // ‼️ 3.  Navigate to LoginPage  (remove all previous routes)
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => LoginPage()), (route) => false,);
                }
                // ‼️ 4.  Show confirmation
                if (context.mounted) {
                  showCommonSnackbar(context, 'Logged out successfully');
                }
              });
            },
          ),
        ],
      ),
    );
  }

   Widget buildMenuItem({
     required String label,
     required String url,
     required BuildContext context,
     required VoidCallback onTap,
   }) {
     return Column(
       children: [
         SizedBox(height: height*.005),
         ListTile(
           contentPadding: EdgeInsets.zero,
           leading: Container(
             width: width * .11,
             height: width * .11,
             decoration: BoxDecoration(
               color: const Color(0xFFE5FBFF),
               borderRadius: BorderRadius.circular(40),
               border: Border.all(color: const Color(0xFF00E0FF)),
             ),
             child: Center(
               child: SvgPicture.asset(
                 url,
                 width: width * .05,
                 height: width * .05,
                 color: Colors.black,
               ),
             ),
           ),
           title: Text(
             label,
             style: GoogleFonts.dmSans(
               fontSize: width * .042,
               fontWeight: FontWeight.w500,
             ),
           ),
           trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
           onTap: onTap,   // ← USE THE PASSED CALLBACK
         ),
         SizedBox(height: height*.005),
         Divider(
           thickness: 0.7,
           height: 0,
           color: Color(0xFFE5E9EB),
         ),
       ],
     );
   }
}
