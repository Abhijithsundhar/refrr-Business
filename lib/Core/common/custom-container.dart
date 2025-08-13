import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';

Widget customCenteredTextContainer(String text) {
  return Container(
    width: width*.35,
    height: height*.05,// Set a fixed width or use MediaQuery for dynamic
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(6),
      border: Border.all(
        color: Colors.grey,
      ),
    ),
    alignment: Alignment.center,
    child: Text(
      text,
      style: TextStyle(
        color: Colors.black,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      textAlign: TextAlign.center,
    ),
  );
}
