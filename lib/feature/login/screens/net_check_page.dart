import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NetWorkChecker extends StatelessWidget {
  const NetWorkChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 100,
                color: Color(0xFFBDBDBD),
              ),
              const SizedBox(height: 30),

              // 🔠 Title
              Text(
                'No Internet Connection',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),

              // 📝 Subtitle
              Text(
                'Your Internet connection is down. Please fix it and '
                    'then you can continue using Grro.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
