import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../Core/common/global variables.dart';
import '../../../core/constants/color-constnats.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.primaryColor,
      appBar: AppBar(
        backgroundColor: ColorConstants.primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Column(children: [
          SizedBox(height: height*.02,),
          Padding(
            padding:  EdgeInsets.only(right: width*.49),
            child: Text(
              'Contact Us',
              style: GoogleFonts.roboto(
                fontSize: width * 0.05,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 60),
            width: double.infinity,
            padding: EdgeInsets.only(top: height*.05, left: 16, right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(45)),
            ),
            child: SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: Padding(
                padding:  EdgeInsets.only(bottom: 20,left: width*.03),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ///phone number
                    SizedBox(height: height*.03),
                    Padding(
                      padding:  EdgeInsets.only(left: width*.2),
                      child: Text('Phone Number' ,style: GoogleFonts.roboto(
                          color: Colors.black,fontSize: width*.035,fontWeight: FontWeight.w400),),
                    ),
                    SizedBox(height: height*.01),

                    Row(
                      children: [
                        SizedBox(width: width*.04,),
                        Icon(Icons.phone_forwarded,color: Colors.black87),
                        SizedBox(width: width*.092,),
                        SelectableText('+91 9955510101' ,style: GoogleFonts.roboto(
                            color: Colors.black,fontSize: width*.035,fontWeight: FontWeight.w500),),
                      ],
                    ),
                    Divider(indent: width*.2,),
                    /// email
                    SizedBox(height: height*.02),
                    Padding(
                      padding:  EdgeInsets.only(left: width*.2),
                      child: Text('Email' ,style: GoogleFonts.roboto(
                          color: Colors.black,fontSize: width*.035,fontWeight: FontWeight.w400),),
                    ),
                    SizedBox(height: height*.01),

                    Row(
                      children: [
                        SizedBox(width: width*.04,),
                        Icon(Icons.mail,color: Colors.black87),
                        SizedBox(width: width*.092,),
                        SelectableText('info@icanyon.com' ,style: GoogleFonts.roboto(
                            color: Colors.black,fontSize: width*.035,fontWeight: FontWeight.w500),),
                      ],
                    ),
                    Divider(indent: width*.2,),

                    /// Address
                    SizedBox(height: height*.02),
                    Padding(
                      padding:  EdgeInsets.only(left: width*.2),
                      child: Text('Address' ,style: GoogleFonts.roboto(
                          color: Colors.black,fontSize: width*.035,fontWeight: FontWeight.w400),),
                    ),
                    SizedBox(height: height*.01),

                    Row(
                      children: [
                        SizedBox(width: width*.04,),
                        Icon(Icons.location_pin,color: Colors.black87,),
                        SizedBox(width: width*.092,),
                        SelectableText('i-Canyon technologies,\n7th floor ,T2, Hilite Business Park,\nCalicut- India' ,style: GoogleFonts.roboto(
                            color: Colors.black,fontSize: width*.035,fontWeight: FontWeight.w500),),
                      ],
                    ),
                    Divider(indent: width*.2,),

                    SizedBox(height: height*.4),
                  ],
                ),
              ),
            ),
          ),
        ],),
      ),
    );
  }
}
