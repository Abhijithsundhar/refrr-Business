import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/custom-appBar.dart';
import 'package:refrr_admin/Core/common/globalVariables.dart';
import 'package:refrr_admin/Core/constants/asset.dart';
import 'package:refrr_admin/Core/theme/pallet.dart';

class LeadGrandedScreen extends StatefulWidget {
  const LeadGrandedScreen({super.key});

  @override
  State<LeadGrandedScreen> createState() => _LeadGrandedScreenState();
}

class _LeadGrandedScreenState extends State<LeadGrandedScreen> {

  final List<Map<String, dynamic>> leads = [
    {
      "name": "Vishnu",
      "city": "Kozhikode",
      "status": AssetConstants.hotGreen,
      "days": "2 Days Ago",
      "service": "Web Development",
      "company": "XYZ Technologies",
      "stage": "Completed",
      "color": Colors.green,
      "headColor": Colors.green,
      "borderColor": Colors.green,
    },
    {
      "name": "Abhijith",
      "city": "Malappuram",
      "status": AssetConstants.hotYellow,
      "days": "2 Days Ago",
      "service": "Web Development",
      "company": "XYZ Technologies",
      "stage": "New Lead",
      "color": Colors.blue,
      "headColor": Colors.blue,
      "borderColor": Colors.blue,
    },
    {
      "name": "Anshad",
      "city": "Kozhikode",
      "status": AssetConstants.warm,
      "days": "2 Days Ago",
      "service": "Web Development",
      "company": "XYZ Technologies",
      "stage": "Contacted",
      "color": Colors.yellow,
      "headColor": Colors.yellow,
      "borderColor": Colors.yellow,
    },
    {
      "name": "Varun",
      "city": "Alappuzha",
      "status": AssetConstants.hotRed,
      "days": "2 Days Ago",
      "service": "Web Development",
      "company": "XYZ Technologies",
      "stage": "New Lead",
      "color": Colors.blue,
      "headColor": Colors.blue,
      "borderColor": Colors.blue,
    },
    {
      "name": "Christina",
      "city": "Malappuram",
      "status": AssetConstants.warm,
      "days": "2 Days Ago",
      "service": "Web Development",
      "company": "XYZ Technologies",
      "stage": "Not Qualified",
      "color": Colors.red,
      "headColor": Colors.red,
      "borderColor": Colors.red,
    },
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Pallet.backgroundColor,
      appBar: CustomAppBar(title: 'Leads Granted'),

      body: SingleChildScrollView(
        child: Column(
          children: [

            SizedBox(height: width * 0.03),

            GridView.builder(
              padding: EdgeInsets.all(width * 0.02),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: leads.length * 3,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: width * 0.03,
                mainAxisSpacing: width * 0.03,
              ),
              itemBuilder: (context, index) {
                final item = leads[index % leads.length];

                return InkWell(
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.all(width * 0.02),
                    decoration: BoxDecoration(
                      color: item["color"].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(width * 0.03),
                      border: Border.all(color: item['borderColor']),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        /// Header Section
                        Container(
                          decoration: BoxDecoration(
                            color: item['headColor'].withOpacity(0.2),
                            borderRadius: BorderRadius.circular(width * 0.015),
                          ),
                          padding: EdgeInsets.all(width * 0.02),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: width * 0.042,
                                backgroundColor: Colors.grey,
                                child: CircleAvatar(
                                  radius: width * 0.04,
                                  backgroundImage: NetworkImage(
                                    "https://i.pravatar.cc/150?img=${DateTime.now().millisecond}",
                                  ),
                                ),
                              ),
                              SizedBox(width: width * 0.02),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item["name"],
                                    style: GoogleFonts.dmSans(
                                      fontWeight: FontWeight.bold,
                                      fontSize: width * 0.04,
                                    ),
                                  ),
                                  Text(
                                    item["city"],
                                    style: TextStyle(fontSize: width * 0.03),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: width * 0.02),

                        /// Status
                        SvgPicture.asset(
                          item['status'],
                          width: width * 0.15,
                        ),

                        SizedBox(height: width * 0.02),
                        Text(
                          item["days"],
                          style: GoogleFonts.dmSans(
                            fontSize: width * 0.03,
                            color: Colors.grey,
                          ),
                        ),

                        SizedBox(height: width * 0.02),

                        Text(
                          item["service"],
                          style: GoogleFonts.dmSans(
                            fontSize: width * 0.04,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),

                        SizedBox(height: width * 0.02),

                        Text(
                          item["company"],
                          style: TextStyle(
                            fontSize: width * 0.03,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: width * 0.02),

                        /// Stage Label
                        Container(
                          width: width * 0.3,
                          height: width * 0.08,
                          decoration: BoxDecoration(
                            border: Border.all(color: item['borderColor']),
                            borderRadius: BorderRadius.circular(width * 0.02),
                          ),
                          child: Center(
                            child: Text(
                              item["stage"],
                              style: GoogleFonts.dmSans(
                                fontSize: width * 0.03,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
