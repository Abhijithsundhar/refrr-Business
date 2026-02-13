import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:refrr_admin/core/constants/colorconstnats.dart';
import 'package:refrr_admin/feature/Login/screens/home.dart';
import 'package:refrr_admin/feature/login/Controller/lead_controller.dart';
import 'package:refrr_admin/feature/login/screens/onboard_screen_1.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _keepLogin());
  }

  Future<void> _keepLogin() async {
    await Future.delayed(const Duration(milliseconds: 400));

    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('uid');
    if (!mounted) return;
    if (uid == null || uid.isEmpty) {
      _goToOnboarding();
      return;
    }
    try {
      final LeadsModel? lead =
      await ref.read(leadControllerProvider.notifier).getLead(uid);
      if (!mounted) return;

      if (lead == null) {
        _goToOnboarding();
        return;
      }
      // IMPORTANT: Only set in-memory lead. Do NOT call updateLead here.
      ref.read(leadControllerProvider.notifier).setCurrentLead(lead);
      // Replace Splash with Home
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(builder: (_) => HomeScreen(lead: lead)),
      );
    } catch (e) {
      if (!mounted) return;
      _goToOnboarding();
    }
  }

  void _goToOnboarding() {
    Navigator.of(context).pushReplacement(
      CupertinoPageRoute(builder: (_) => const OnboardingPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.primaryColor,
      body: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.3,
          width: MediaQuery.of(context).size.width * 0.7,
          child: SvgPicture.asset('assets/svg/grroLogoWhite.svg', color: Colors.white,),
          // child: SvgPicture.asset('assets/svg/G-logo.svg'),
          ),
        ),
      );
  }
}
