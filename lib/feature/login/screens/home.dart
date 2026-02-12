import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:refrr_admin/Core/common/globalVariables.dart';
import 'package:refrr_admin/models/leads_model.dart';

import 'package:refrr_admin/Feature/pipeline/Screens/pipeline/funnel-home.dart';
import 'package:refrr_admin/Feature/website/screens/website/web-home-screen.dart';
import 'package:refrr_admin/Feature/Team/screens/team-home.dart';
import 'package:refrr_admin/Feature/promote/screens/promote-home.dart';

class HomeScreen extends StatefulWidget {
  final LeadsModel? lead;
  final int? index;

  const HomeScreen({
    super.key,
    this.lead,
    this.index,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;
  late DateTime _screenStartTime;

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.index ?? 0;
    _screenStartTime = DateTime.now();

    /// ✅ Move SystemChrome here (not in build)
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    /// ✅ Measure first screen load time
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loadTime = DateTime.now().difference(_screenStartTime).inMilliseconds;
      debugPrint('HomeScreen loaded in ${loadTime}ms');
    });
  }

  void _onTabChange(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required String icon,
  }) {
    final bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTabChange(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: width * .1,
            height: height * .035,
            child: SvgPicture.asset(
              icon,
              color: isSelected
                  ? Colors.black
                  : const Color(0xffd8d8d8),
            ),
          ),
          SizedBox(height: height * .002),
          Text(
            label,
            style: GoogleFonts.dmSans(
              color: isSelected
                  ? Colors.black
                  : const Color(0xffd8d8d8),
              fontSize: width * .031,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// ✅ IndexedStack = screens load once, state preserved
      body: IndexedStack(
        index: _currentIndex,
        children: [
          FunnelHome(currentFirm: widget.lead),
          WebsiteHomeScreen(currentFirm: widget.lead),
          TeamHome(currentFirm: widget.lead),
          PromoteScreen(currentFirm: widget.lead),
        ],
      ),

      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: height * .08,
          padding: EdgeInsets.symmetric(horizontal: width * .03),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                label: "Pipeline",
                icon: _currentIndex == 0
                    ? "assets/svg/piplineWhite.svg"
                    : "assets/svg/pipelineGrey.svg",
              ),
              _buildNavItem(
                index: 1,
                label: "Website",
                icon: _currentIndex == 1
                    ? "assets/svg/businessWhite.svg"
                    : "assets/svg/businessGrey.svg",
              ),
              _buildNavItem(
                index: 2,
                label: "team",
                icon: _currentIndex == 2
                    ? "assets/svg/teamWhite.svg"
                    : "assets/svg/teamGrey.svg",
              ),
              _buildNavItem(
                index: 3,
                label: "Promote",
                icon: "assets/svg/promote.svg",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
