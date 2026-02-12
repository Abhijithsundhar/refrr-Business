import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:refrr_admin/Core/common/global%20variables.dart';

class CustomTextFormField extends StatelessWidget {
  final String? initialValue;
  final String? hintText;
  final int maxLines;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;

  const CustomTextFormField({
    super.key,
    this.initialValue,
    this.hintText,
    this.maxLines = 1,
    this.controller,
    this.validator,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: maxLines == 1 ? height*.06 :  height*.2, // Set your desired height here
      decoration: BoxDecoration(
        color: Colors.grey[100], // Match the TextField's fill color
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        initialValue: initialValue,
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: 1,
        readOnly: readOnly,
        onTap: onTap,
        onChanged: onChanged,
        style: TextStyle(
          fontSize: 14,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 14,
          ),
          border: InputBorder.none, // ✅ Remove all borders
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          isDense: true, // Helps reduce vertical space
        ),
      ),
    );
  }
}

///
class CustomReadonlyTextField extends StatelessWidget {
  final String labelText;
  final Color textColor;
  final String moneyValue;

  const CustomReadonlyTextField(
      this.labelText,
      this.textColor,
      this.moneyValue, {
        super.key,
      });

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: GoogleFonts.roboto(
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: height *.06,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            moneyValue,
            style: GoogleFonts.roboto(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}


