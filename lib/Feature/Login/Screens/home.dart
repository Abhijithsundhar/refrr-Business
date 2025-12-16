import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';
import 'package:refrr_admin/Feature/Services/Screens/service-home.dart';
import 'package:refrr_admin/Feature/business/screens/business-home.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:refrr_admin/Feature/Account/screens/account-home.dart';
import 'package:refrr_admin/Feature/pipeline/Screens/pipeline/funnel-home.dart';
import 'package:refrr_admin/Feature/Team/screens/team-home.dart';

class HomeScreen extends StatefulWidget {
  final LeadsModel? lead;
  final int? index;
  const HomeScreen({super.key, this.lead,  this.index});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
@override
  void initState() {
  _currentIndex = widget.index ?? 0;
      super.initState();
  }
  Widget buildNavItem({
    required int index,
    required String label,
    required String icon,
  }) {
    final bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: width*.1,
            height: height*.035,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF00E0FF) : Colors.transparent,
              borderRadius: BorderRadius.circular(30),
            ),
            child: SvgPicture.asset(icon,
              width: 10,
              height: 10,
              color: isSelected ? Colors.white : const Color(0xFF6E7C87),
            ),
          ),
         SizedBox( height: height*.002,),
          Text(label,
            style: GoogleFonts.dmSans(
              color: isSelected ? Colors.black : const Color(0xFF6E7C87),
              fontSize: width*.031,
              fontWeight: FontWeight.w500,
            ),
          )
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      FunnelHome(currentFirm: widget.lead),
      // ServiceListScreenHome(currentFirm: widget.lead),
      BusinessScreen(),
      TeamHome(currentFirm: widget.lead),
      AccountScreen(currentFirm: widget.lead),
    ];

    return Scaffold(
      body: screens[_currentIndex],
        bottomNavigationBar:Container(
      height: height*.08,
      padding:  EdgeInsets.only(left: width*.03,right: width*.03,),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          buildNavItem(
            index: 0,
            label: "Pipeline",
            icon: _currentIndex == 0
                ? "assets/svg/piplineWhite.svg"
                : "assets/svg/pipelineGrey.svg",
          ),
          buildNavItem(
            index: 1,
            label: "Business",
            icon: _currentIndex == 1
                ? "assets/svg/businessWhite.svg"
                : "assets/svg/businessGrey.svg",
          ),
          buildNavItem(
            index: 2,
            label: "Team",
            icon: _currentIndex == 2
                ? "assets/svg/teamWhite.svg"
                : "assets/svg/teamGrey.svg",
          ),
          buildNavItem(
            index: 3,
            label: "Account",
            icon: _currentIndex == 3
                ? "assets/svg/accountWhite.svg"
                : "assets/svg/accountGrey.svg",
          ),
        ],
      ),
    ),
    );
  }
}