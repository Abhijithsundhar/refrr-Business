import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../Core/common/global variables.dart';
import 'login-page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();

  final List<OnboardContent> pages = [
    OnboardContent(
      title: 'Add Firms, Grow Your Wealth',
      subtitle1: 'Expand your portfolio and unlock greater',
      subtitle2: 'financial opportunities.',
      imagePath: 'assets/images/firstImage.png',
    ),
    OnboardContent(
      title: 'Earn Money Effortlessly',
      subtitle1: 'Earn money effortlessly by turning smart ',
      subtitle2: ' strategies into steady income. ',
      imagePath: 'assets/images/secondimage.png',
    ),
    OnboardContent(
      title: 'Track Your Growth in Real-Time',
      subtitle1: 'Track your growth in real-time and stay ahead ',
      subtitle2: 'with instant insights and progress updates.',
      imagePath: 'assets/images/thridImage.png',
    ),
  ];

  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
    children: [
    Column(
    children: [
      /// Onboarding Screens with stacked dots
      Expanded(
      child: Stack(
      alignment: Alignment.bottomCenter,
      children: [
        PageView.builder(
          controller: _controller,
          itemCount: pages.length,
          onPageChanged: (index) {
            setState(() => currentPage = index);
          },
          itemBuilder: (_, index) => OnboardScreen(content: pages[index]),
        ),
        Positioned(
          bottom: height * 0.12,
          child: SmoothPageIndicator(
            controller: _controller,
            count: pages.length,
            effect: CustomizableEffect(
              activeDotDecoration: DotDecoration(
                width: 20,
                height: 10,
                color: Color.fromRGBO(189, 189, 189, 1),
                borderRadius: BorderRadius.circular(10),
              ),
              dotDecoration: DotDecoration(
                width: 10,
                height: 10,
                color: Color.fromRGBO(217, 217, 217, 1),
                borderRadius: BorderRadius.circular(50),
              ),
              spacing: 8.0,
            ),
          ),
        )
      ],
    ),
    ),

    /// Next Button
    Padding(
    padding: EdgeInsets.only(left: width * .02),
    child: GestureDetector(
    onTap: () {
    if (currentPage == pages.length - 1) {
    Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => LoginPage()),
    );
    } else {
    _controller.nextPage(
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeIn,
    );
    }
    },
    child: Container(
    width: width * .9,
    height: height * .07,
    decoration: BoxDecoration(
    color: Colors.black,
    border: Border.all(
    color: Colors.black,
    width: width * .004,
    ),
    borderRadius: BorderRadius.circular(width * .03),
    ),
    child: Center(
    child: Text(
    'Next',
    style: GoogleFonts.roboto(
    fontSize: width * .034,
    color: Colors.white,
    fontWeight: FontWeight.w500,
    ),
    ),
    ),
    ),
    ),
    ),
    SizedBox(height: height * .04),
    ],
    ),

    /// Skip Button Positioned Top-Right
    Positioned(
    top: height * 0.06,
    right: width * 0.05,
    child: GestureDetector(
    onTap: () {
    Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => LoginPage()),
    );
    },
    child: Container(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
    color: Colors.white,
    border: Border.all(color: Colors.white),
    borderRadius: BorderRadius.circular(width * .01),
    ),
    child: Text(
    'Skip',
    style: GoogleFonts.roboto(
    fontSize: width * .034,
    color: Colors.black,
    fontWeight: FontWeight.w400,
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

class OnboardContent {
  final String title;
  final String subtitle1;
  final String subtitle2;
  final String imagePath;

  OnboardContent({
    required this.title,
    required this.subtitle1,
    required this.subtitle2,
    required this.imagePath,
  });
}

class OnboardScreen extends StatelessWidget {
  final OnboardContent content;

  const OnboardScreen({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.05),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: height * .2), // Top spacing

          /// Heading
          Text(
            content.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: width * .05,
            ),
          ),
          SizedBox(height: height * .015),

          /// Subtitles
          Text(
            content.subtitle1,
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              color: Colors.black,
              fontWeight: FontWeight.w300,
              fontSize: width * .04,
            ),
          ),
          Text(
            content.subtitle2,
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              color: Colors.black,
              fontWeight: FontWeight.w300,
              fontSize: width * .04,
            ),
          ),

          /// Image
          Container(
            height: height * .55,
            width: double.infinity,
            child: Image.asset(
              content.imagePath,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
