import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/core/common/global_variables.dart';
import 'package:refrr_admin/feature/login/screens/contact_us.dart';

class UpgradePlanScreen extends StatelessWidget {
  const UpgradePlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with back button
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
        child: RichText(
          text: TextSpan(
            text: 'To upgrade your plan, ',
            style:  GoogleFonts.roboto(color: Colors.black, fontSize: width*.043,fontWeight: FontWeight.w400),
            children: [
              TextSpan(
                text: 'Contact us.',
                style:  GoogleFonts.roboto(color: Color(0xFF0067B0), fontSize: width*.043,fontWeight: FontWeight.w500),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.push(context,MaterialPageRoute(builder: (context) => ContactUs(),) ) ;
                    print("Contact us tapped");
                  },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
