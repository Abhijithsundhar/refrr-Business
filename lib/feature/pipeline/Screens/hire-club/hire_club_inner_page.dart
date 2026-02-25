import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:refrr_admin/core/alert_dailogs/hire_confirmation_alert.dart';
import 'package:refrr_admin/core/common/chat_screen_support_functions.dart';
import 'package:refrr_admin/core/common/global_variables.dart';
import 'package:refrr_admin/core/utils/call_dailpad_function.dart';
import 'package:refrr_admin/core/utils/whatsapp_open_function.dart';

class SalesProfilePage extends StatelessWidget {
  const SalesProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Color(0xFFE5E9EB)),
              ),
              child: const Center(
                child: Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.black),
              ),
            ),
          ),
        ),
        title: const Text(
          "Hire From Sales Club",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [

             SizedBox(height: height*.01),

            // Profile Avatar
             CircleAvatar(
              radius: width*.09,
              backgroundImage: AssetImage("assets/profile.jpg"),
            ),

            SizedBox(height: height*.01),

            // Name
             Text(
              "Ashique",
              style: TextStyle(
                fontSize: width*.05,
                fontWeight: FontWeight.w700,
              ),
            ),

            SizedBox(height: height*.003),
            // Location Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:  [
                Icon(Icons.location_on_outlined, size: width*.05, color: Colors.black54),
                SizedBox(width: 4),
                Text("Malappuram, Kerala",
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),

            SizedBox(height: height*.02),

            // Conversion & CQ Row
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: height * .11,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0x1A14DFED),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFF14DFED),),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Total Conversion",
                          style: TextStyle(color: Colors.black54, fontSize: width * .03),
                        ),
                        Spacer(), // ⭐ MATCHES FIRST

                        Text(
                          "05",
                          style: TextStyle(fontSize: width * .06, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Container(
                    height: height * .11,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0x1A14DFED),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFF14DFED),),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "CQ",
                          style: TextStyle(color: Colors.black54, fontSize: width * .03), // ⭐ SAME FONT SIZE LOGIC
                        ),
                        Spacer(), // ⭐ MATCHES FIRST
                        Text(
                          "100%",
                          style: TextStyle(
                            fontSize: width * .06, // ⭐ SAME FONT SIZE LOGIC
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),


            const SizedBox(height: 20),

            // Details Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Industry Served",
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                   SizedBox(height: height*.001),
                  const Text(
                    "Digital Marketing",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),

                   SizedBox(height: height*.005),
                  Divider(color: Colors.black12),

                  SizedBox(height: height*.005),
                  const Text(
                    "Phone No",
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                  SizedBox(height: height*.001),
                  const Text(
                    "+91 98787 67876",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),

                  SizedBox(height: height*.005),
                  Divider(color: Colors.black12),

                  SizedBox(height: height*.005),
                  const Text(
                    "Mail ID",
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                  SizedBox(height: height*.001),
                  const Text(
                    "ashique@gmail.com",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),

      // Bottom Buttons
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: const BoxDecoration(color: Colors.white),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                 onTap: (){
                   showHireConfirmation(context,"Are you sure you want to Hire the sales person?",(){});
                 },
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/svg/human-resources 1.svg',
                        height: 20,   // 👈 set the size HERE
                        width: 20,    // 👈 set the size HERE
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 8),
                       Text(
                        "Hire",
                        style: TextStyle(color: Colors.white, fontSize: width*.045, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ),

             SizedBox(width: width*.015),

            // WhatsApp Button
        GestureDetector(
          onTap: (){
            openWhatsApp('+919567099380');
          },
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/svg/whatsapp.svg',
                height: 25,   // 👈 set the size HERE
                width: 25,    // 👈 set the size HERE
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),

            SizedBox(width: width*.015),

            // Call Button
            GestureDetector(
              onTap: (){
                callNumber('+919567099380');
              },
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/svg/phone.svg',
                    height: 20,
                    width: 25,
                    fit: BoxFit.contain,
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
