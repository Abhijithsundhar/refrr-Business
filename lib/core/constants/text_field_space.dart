import 'package:flutter/material.dart';
import 'package:refrr_admin/core/common/global_variables.dart';

Widget buildSection({required List<Widget> children}) {
  return SizedBox(
    width: double.infinity,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var w in children) ...[
          w,
          if (w != children.last) SizedBox(height: height * .02),
        ]
      ],
    ),
  );
}
