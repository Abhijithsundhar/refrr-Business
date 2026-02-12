import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/globalVariables.dart';
import 'package:refrr_admin/Core/constants/color-constnats.dart';
import 'package:refrr_admin/Core/theme/pallet.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final IconData icon;
  final TextEditingController controller;
  final bool isPassword;
  final VoidCallback? onToggleVisibility;
  final bool hidePassword;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.icon,
    required this.controller,
    this.isPassword = false,
    this.onToggleVisibility,
    this.hidePassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // TextField Container
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon Container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF00D4FF),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),

              // Text Field
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    controller: controller,
                    obscureText: isPassword && hidePassword,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.grey.shade400,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ),

              // Suffix Icon (for password visibility toggle)
              if (isPassword)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: IconButton(
                    icon: Icon(
                      hidePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.black87,
                      size: 24,
                    ),
                    onPressed: onToggleVisibility,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// CUSTOM INPUT FIELD
Widget inputField(
    String hint,
    TextEditingController controller,
    TextInputType? type,
    Widget sufix, {
      bool readOnly = false,
      int maxLines = 1,
    }) {
  return TextField(
    controller: controller,
    readOnly:readOnly,
    maxLines: maxLines,
    keyboardType: type,
    decoration: InputDecoration(
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Pallet.borderColor),
        borderRadius: BorderRadius.circular(width * 0.025),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Pallet.borderColor),
        borderRadius: BorderRadius.circular(width * 0.025),
      ),
      labelText: hint,
      labelStyle: GoogleFonts.dmSans(
        fontSize: width * 0.035,
        fontWeight: FontWeight.w500,
        color: Pallet.greyColor,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: width * 0.02,
        vertical: width * 0.03,
      ),

      // ✅ Proper suffixIcon box
      suffixIcon: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 20,
            maxHeight: 20,
          ),
          child: sufix,
        ),
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(width * 0.02),
        borderSide: BorderSide(color: Pallet.borderColor),
      ),
    ),
  );
}
Widget priceField(String hint, TextEditingController controller,String currency) {
  return Stack(
    children: [
      TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: hint,
          labelStyle: GoogleFonts.dmSans(
            fontSize: width * 0.035,
            fontWeight: FontWeight.w500,
            color: Pallet.greyColor,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: width * 0.04,
            vertical: width * 0.03,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Pallet.borderColor),
            borderRadius: BorderRadius.circular(width * 0.025),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Pallet.borderColor),
            borderRadius: BorderRadius.circular(width * 0.025),
          ),
        ),
      ),
      // AED container at end
      Positioned(
        right: width * 0.02,
        top: 0,
        bottom: 0,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: width * 0.04),
          margin: EdgeInsets.symmetric(vertical: width * 0.03),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey.shade200,
            ),
            borderRadius: BorderRadius.circular(width * 0.15),
          ),
          alignment: Alignment.center,
          child: Text(
            currency,
            style: GoogleFonts.dmSans(
              fontSize: width * 0.03,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    ],
  );
}

Widget keyField(String hint) {
  return Stack(
    children: [
      TextField(
        // controller: controller,
        decoration: InputDecoration(
          labelText: hint,
          labelStyle: GoogleFonts.dmSans(
            fontSize: width * 0.035,
            fontWeight: FontWeight.w500,
            color: Pallet.greyColor,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: width * 0.04,
            vertical: width * 0.03,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Pallet.borderColor),
            borderRadius: BorderRadius.circular(width * 0.025),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Pallet.borderColor),
            borderRadius: BorderRadius.circular(width * 0.025),
          ),
        ),
      ),
      // AED container at end
      Positioned(
        right: width * 0.02,
        top: 0,
        bottom: 0,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: width * 0.04),
          margin: EdgeInsets.symmetric(vertical: width * 0.02),
          decoration: BoxDecoration(
              color: ColorConstants.primaryColor,
            borderRadius: BorderRadius.circular(width * 0.02),
          ),
          alignment: Alignment.center,
          child: Row(
            children: [
              Icon(Icons.add,color: Colors.white,size:width * 0.045 ,),
              Text(
                'Add',
                style: GoogleFonts.dmSans(
                    color: Colors.white,
                  fontSize: width * 0.035,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget dropdownField<T>({
  required String label,
  required T? value,
  required List<DropdownMenuItem<T>> items,
  required ValueChanged<T?> onChanged,
  Widget? suffix,
}) {
  return Container(
    height: height*.055,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(width * 0.025),
    ),
    child: DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down),
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Pallet.borderColor),
          borderRadius: BorderRadius.circular(width * 0.025),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Pallet.borderColor),
          borderRadius: BorderRadius.circular(width * 0.025),
        ),
        labelText: label,
        labelStyle: GoogleFonts.dmSans(
          fontSize: width * 0.035,
          fontWeight: FontWeight.w500,
          color: Pallet.greyColor,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: width * 0.02,
          vertical: width * 0.03,
        ),
        suffix: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(width * 0.02),
          borderSide: BorderSide(color: Pallet.borderColor),
        ),
        filled: true,             // <-- Important: enable filling
        fillColor: Colors.white,  // <-- Also set fill color here (for robustness)
      ),
      style: GoogleFonts.dmSans(
        fontSize: width * 0.035,
        color: Colors.black,
      ),
      items: items,
      onChanged: onChanged,
    ),
  );
}
