import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';
import 'package:refrr_admin/Core/constants/asset.dart';
import 'package:refrr_admin/Core/theme/pallet.dart';


class PipelineTab extends StatelessWidget {
  PipelineTab({super.key});

  final List<Map<String, dynamic>> leads = [
    {
      "name": "Vishnu",
      "city": "Kozhikode",
      "status": AssetConstants.hotGreen,
      "days": "2 Days Ago",
      "service": "Web Development",
      "company": "XYZ Technologies",
      "stage": "Completed",
      "color": Colors.green.shade50,
      "headColor": Colors.green.shade100,
      "borderColor": Colors.green.shade100,
    },
    {
      "name": "Abhijith",
      "city": "Malappuram",
      "status": AssetConstants.hotYellow,
      "days": "2 Days Ago",
      "service": "Web Development",
      "company": "XYZ Technologies",
      "stage": "New Lead",
      "color": Colors.blue.shade50,
      "headColor": Colors.blue.shade100,
      "borderColor": Colors.blue.shade100
    },
    {
      "name": "Anshad",
      "city": "Kozhikode",
      "status": AssetConstants.warm,
      "days": "2 Days Ago",
      "service": "Web Development",
      "company": "XYZ Technologies",
      "stage": "Contacted",
      "color": Colors.yellow.shade50,
      "headColor": Colors.yellow.shade100,
      "borderColor": Colors.yellow.shade100
    },
    {
      "name": "Varun",
      "city": "Alappuzha",
      "status": AssetConstants.hotRed,
      "days": "2 Days Ago",
      "service": "Web Development",
      "company": "XYZ Technologies",
      "stage": "New Lead",
      "color": Colors.blue.shade50,
      "headColor": Colors.blue.shade100,
      "borderColor": Colors.blue.shade100
    },
    {
      "name": "Christina",
      "city": "Malappuram",
      "status": AssetConstants.warm,
      "days": "2 Days Ago",
      "service": "Web Development",
      "company": "XYZ Technologies",
      "stage": "Not Qualified",
      "color": Colors.red.shade50,
      "headColor": Colors.red.shade100,
      "borderColor": Colors.red.shade100
    },
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(width * 0.02),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: leads.length * 3, // repeat pattern
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: width * 0.03,
        mainAxisSpacing: width * 0.03,
      ),
      itemBuilder: (context, i) {
        final item = leads[i % leads.length];

        return InkWell(
          onTap: () {
            // Navigator.push(context, MaterialPageRoute(builder: (context) => LeadTimelineScreen(),));
          },
          child: Container(
            padding: EdgeInsets.all(width * 0.02),
            decoration: BoxDecoration(
              color: item["color"],
              borderRadius: BorderRadius.circular(width * 0.03),
              border: Border.all(color: item['borderColor']),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: item['headColor'],
                    borderRadius: BorderRadius.circular(width * 0.015),
                  ),
                  padding: EdgeInsets.all(width * 0.02),
                  child: Row(
                    children: [
                      /// Avatar
                      CircleAvatar(
                        radius: width * 0.042,
                        backgroundColor: Pallet.backgroundColor,
                        child: CircleAvatar(
                          radius: width * 0.04,
                          backgroundImage: NetworkImage(
                              "https://i.pravatar.cc/150?img=${DateTime.now().millisecond}"),
                        ),
                      ),
                      SizedBox(width: width * 0.02),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item["name"],
                              style: GoogleFonts.dmSans(
                                  fontWeight: FontWeight.bold, fontSize: width * 0.04)),
                          Text(item["city"], style: TextStyle(fontSize: width * 0.03)),
                        ],
                      )
                    ],
                  ),
                ),

                SizedBox(height: width * 0.02),

                /// Status
                SvgPicture.asset(item['status'], width: width * 0.15),

                SizedBox(height: width * 0.02),
                Text(item["days"],
                    style: GoogleFonts.dmSans(fontSize: width * 0.03, color: Pallet.greyColor)),
                SizedBox(height: width * 0.02),

                Text(item["service"],
                    style: GoogleFonts.dmSans(
                        fontSize: width * 0.04, fontWeight: FontWeight.bold, color: Pallet.blueColor)),
                SizedBox(height: width * 0.02),

                Text(item["company"],
                    style: TextStyle(fontSize: width * 0.03, fontWeight: FontWeight.bold)),
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
                      style:
                      GoogleFonts.dmSans(fontSize: width * 0.03, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
