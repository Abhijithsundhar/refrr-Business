import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/core/common/global_variables.dart';

void showHireMarketersDialog(
    BuildContext context, {
      required VoidCallback onGrroTap,
      required VoidCallback onOwnTeamTap,
    }) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= HEADER =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Hire Marketers",
                    style: GoogleFonts.dmSans(
                      fontSize: width * .05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xffF3F3F3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 18),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ================= OPTIONS =================
              Row(
                children: [
                  Expanded(
                    child: _hireOptionCard(
                      svgPath: 'assets/svg/GBlacklogo.svg',
                      label: "From Grro",
                      onTap: () {
                        Navigator.pop(context);
                        onGrroTap();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _hireOptionCard(
                      svgPath:
                      'assets/svg/account-multiple-plus-outline.svg',
                      label: "From Own team",
                      onTap: () {
                        Navigator.pop(context);
                        onOwnTeamTap();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _hireOptionCard({
  required String svgPath,
  required String label,
  required VoidCallback onTap,
}) {
  return InkWell(
    borderRadius: BorderRadius.circular(16),
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Color(0xffF3F3F3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xffE5E9EB)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                svgPath,
                height: 28,
                width: 28,
                colorFilter: const ColorFilter.mode(
                  Colors.black,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: width*.04,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}

