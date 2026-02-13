import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/core/common/global_variables.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final bool showBackButton;

  /// ✅ OPTIONAL RIGHT-SIDE WIDGET
  final Widget? actionWidget;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.showBackButton = true,
    this.actionWidget,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,

      title: Padding(
        padding: EdgeInsets.only(left: width * 0.05),
        child: Row(
          children: [
            /// 🔙 BACK BUTTON
            if (showBackButton)
              GestureDetector(
                onTap: onBack ?? () => Navigator.pop(context),
                child: Container(
                  width: width * 0.09,
                  height: width * 0.09,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black12),
                  ),
                  child: const Center(
                    child: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  ),
                ),
              ),

            if (showBackButton) SizedBox(width: width * 0.03),

            /// 🏷 TITLE
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.dmSans(
                  fontSize: width * 0.055,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            /// 👉 RIGHT ACTION (OPTIONAL)
            if (actionWidget != null) actionWidget!,
          ],
        ),
      ),

      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: Colors.black12),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

class BusinessAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double width;
  final String titleText;
  final List<Widget> actions; // 🔥 dynamic actions

  const BusinessAppBar({
    super.key,
    required this.width,
    required this.titleText,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.05),
        child: Row(
          children: [
            Text(
              titleText,
              style: GoogleFonts.dmSans(
                fontSize: width * .05,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),

            const Spacer(),

            Row(children: actions), // 🔥 dynamic buttons
          ],
        ),
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

Widget businessActionButton({
  required double width,
  required double height,
  required String label,
  required String url,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: height * .041,
      margin: EdgeInsets.only(left: width * .01),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SvgPicture.asset(url),
          SizedBox(width: width * .01),
          Text(
            label,
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontSize: width * .03,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}

class SuggestAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final bool showBackButton;
  final Widget? actionWidget;

  const SuggestAppBar({super.key,
    required this.title, this.onBack,
    this.showBackButton = true, this.actionWidget,});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Padding(
        padding: EdgeInsets.only(left: width * 0.05),
        child: Row(
          children: [
            /// 🔙 BACK BUTTON
            if (showBackButton)
              GestureDetector(
                onTap: onBack ?? () => Navigator.pop(context),
                child: Container(
                  width: width * 0.09,
                  height: width * 0.09,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black12),
                  ),
                  child: const Center(
                    child: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  ),
                ),
              ),

            if (showBackButton) SizedBox(width: width * 0.03),

            /// 🏷 TITLE
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.dmSans(
                  fontSize: width * 0.045,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            /// 👉 RIGHT ACTION (OPTIONAL)
            if (actionWidget != null) actionWidget!,
          ],
        ),
      ),

      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: Colors.black12),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
