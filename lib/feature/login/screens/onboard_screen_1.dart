import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:refrr_admin/core/common/global_variables.dart';
import 'package:refrr_admin/feature/login/screens/login_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}
class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();

  final List<OnboardContent> pages = [
    OnboardContent(
      title1: "Welcome to",
      title2: "Grro",
      subtitle:
      "Access lead info, proposals, invoices, and performance analytics all in one powerful admin panel.",
      imagePath: "assets/svg/sp1.svg",
      buttonText: "Next",
    ),
    OnboardContent(
      title1: "Effortless Lead",
      title2: "Management",
      subtitle:
      "Add, update, and monitor leads in just a few taps and stay in control of your sales flow at all times.",
      imagePath: "assets/svg/sp2.svg",
      buttonText: "Next",
    ),
    OnboardContent(
      title1: "Live Insights,",
      title2: "Smarter Decisions",
      subtitle:
      "Track every lead’s status from first contact to conversion with real-time updates and progress tracking.",
      imagePath: "assets/svg/sp3.svg",
      buttonText: "Get Started",
    ),
  ];

  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          /// PAGE CONTENT
          Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: pages.length,
                  onPageChanged: (index) {
                    setState(() => currentPage = index);
                  },
                  itemBuilder: (_, index) => OnboardScreen(
                    content: pages[index],
                  ),
                ),
              ),

              /// Smooth Page Indicator
              SmoothPageIndicator(
                controller: _controller,
                count: pages.length,
                effect: ExpandingDotsEffect(
                  dotHeight: 8,
                  dotWidth: 8,
                  expansionFactor: 3,
                  activeDotColor: Colors.transparent,
                  dotColor: Colors.transparent,
                ),
              ),

              SizedBox(height: height * 0.03),

              /// NEXT / GET STARTED button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                child: GestureDetector(
                  onTap: () {
                    if (currentPage == pages.length - 1) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                      );
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Container(
                    height: height * 0.065,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          pages[currentPage].buttonText,
                          style: GoogleFonts.dmSans(
                            color: Colors.white,
                            fontSize: width * 0.04,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: width*.0025),
                          child: Icon(Icons.arrow_forward_ios,color: Colors.white,size:width * 0.04,),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: height * 0.05),
            ],
          ),

          /// SKIP button on top right
          Positioned(
            top: height * 0.06,
            right: width * 0.05,
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => LoginPage()));
              },
              child: Padding(
                padding:  EdgeInsets.only(top: height*.01),
                child: Container(
                  height: height*.035,
                  width: width*.17,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color:Color(0xFFE5E9EB) )
                  ),
                  child: Center(
                    child: Text(
                      "Skip",
                      style: GoogleFonts.dmSans(
                        color: Color(0xff6E7C87),
                        fontSize: width * 0.038,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class OnboardScreen extends StatelessWidget {
  final OnboardContent content;

  const OnboardScreen({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: height * .12),

        /// LOGO
        SizedBox(
          height: height * 0.1,
          width: width * .3,
          child: SvgPicture.asset("assets/svg/GRRO-SVG.svg",
            fit: BoxFit.contain,
          ),
        ),

        SizedBox(height: height * 0.055),

        /// IMAGE (BIG)
        SizedBox(
          height: height * 0.31,
          child: SvgPicture.asset(
            content.imagePath,
            fit: BoxFit.contain,
          ),
        ),

        SizedBox(height: height * 0.03),

        /// TITLE (Two Texts One by One)
        Padding(
          padding: EdgeInsets.only(left: width * .06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(content.title1,
                style: GoogleFonts.dmSans(
                  fontSize: width * 0.09,
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(content.title2,
                style: GoogleFonts.dmSans(
                  fontSize: width * 0.09,
                  color: Color(0xFF00BFCA),
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: height * 0.01),

              /// SUBTITLE
              Text(
                content.subtitle,
                textAlign: TextAlign.start,
                style: GoogleFonts.dmSans(
                  fontSize: width * 0.04,
                  color: Colors.black87,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class OnboardContent {
  final String title1;
  final String title2;
  final String subtitle;
  final String imagePath;
  final String buttonText;

  OnboardContent({
    required this.title1,
    required this.title2,
    required this.subtitle,
    required this.imagePath,
    required this.buttonText,
  });
}
