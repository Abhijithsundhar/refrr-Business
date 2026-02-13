import 'package:flutter/material.dart';
import 'package:refrr_admin/core/common/global_variables.dart';
import 'package:refrr_admin/feature/pipeline/screens/hire-club/hire_club_inner_page.dart';

class HireFromSalesClubPage extends StatelessWidget {
  final List<String> locations = ["Location", "Kozhikode", "Kochi"];
  final List<String> industries = ["Industry", "IT", "Sales"];

  HireFromSalesClubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: height*.01,
              width: width*.01,
              padding: EdgeInsets.all(2), // Border thickness
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Color(0xFFE5E9EB),  // Grey border
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: Colors.black,
              ),
            )
            ,
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
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // FILTER ROW
            Row(
              children: [
                Expanded(child: _dropdown(locations)),
                const SizedBox(width: 10),
                Expanded(child: _dropdown(industries)),
                const SizedBox(width: 10),

                // Search Box
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.search, color: Colors.white),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // GRID INSIDE SCROLL VIEW
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 10,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.90,
              ),
              itemBuilder: (context, index) {
                return _userCard(context);
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // DROPDOWN
  Widget _dropdown(List<String> items) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E9EB)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.first,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: items
              .map((e) => DropdownMenuItem(
            value: e,
            child: Text(e),
          ))
              .toList(),
          onChanged: (_) {},
        ),
      ),
    );
  }

  // USER CARD UI
  Widget _userCard(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => SalesProfilePage(),));
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E9EB)),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: width * .08,
              backgroundImage: const AssetImage("assets/profile.jpg"),
            ),

            SizedBox(height: height * .002),

            Text(
              "Ashique",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: width * .04,
              ),
            ),

            SizedBox(height: height * .002),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: Colors.black54),
                Text(
                  "Malappuram, Kerala",
                  style: TextStyle(fontSize: width * .03, color: Colors.black54),
                ),
              ],
            ),

            SizedBox(height: height * .002),

            RichText(
              text: TextSpan(
                text: "Total Conversion: ",
                style: TextStyle(fontSize: width * .03, color: Colors.black54),
                children: const [
                  TextSpan(
                    text: "05",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ],
              ),
            ),

            SizedBox(height: height * .008),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: RichText(
                text: TextSpan(
                  text: "CQ: ",
                  style: TextStyle(
                    fontSize: width * .035,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                  children: const [
                    TextSpan(
                      text: "100%",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
