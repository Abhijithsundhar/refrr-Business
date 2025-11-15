import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';
import 'package:refrr_admin/models/affiliate-model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


Widget buildFilterButton(String text, bool isSelected, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: width * 0.29,
      height: height * 0.043,
      decoration: BoxDecoration(
        // color: isSelected ? Colors.black : const Color(0xFFF3F3F3),
        border: Border.all(color: isSelected ? Colors.black : Colors.grey.shade400),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Center(
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.roboto(
            fontSize: width * 0.03,
            fontWeight: FontWeight.w400,
            color: isSelected ? Colors.black : Colors.grey,
          ),
        ),
      ),
    ),
  );
}


Widget buildCandidateCard({
  required AffiliateModel model,
  required double width,
  required int completedCount,
  required String lqScore,
}) {
  return Stack(
    children: [
      Container(
        height: height * 0.311,
        width: width * 0.9,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[400]!, width: 1.5),
              ),
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[200],
                backgroundImage: model.profile.isNotEmpty
                    ? NetworkImage(model.profile)
                    : AssetImage('assets/image.png'),
              ),
            ),
            SizedBox(height: height * 0.006),

            Text(
              model.name.length > 15
                  ? "${model.name.substring(0, 15)}..."
                  : model.name,
              style: GoogleFonts.roboto(
                fontSize: width * .04,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            Text(
              model.zone,
              style: GoogleFonts.roboto(
                fontSize: width * .03,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),

            SizedBox(height: 10),

            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Total leads: ',
                    style: GoogleFonts.roboto(
                      fontSize: width * .035,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: '$completedCount',
                    style: GoogleFonts.roboto(
                      fontSize: width * .035,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  )
                ],
              ),
            ),

            RichText(
              text: TextSpan(
                text: 'Total credited:',
                style: GoogleFonts.roboto(
                    fontSize: width * .03, color: Colors.black),
                children: [
                  TextSpan(
                    // text: " AED 100",
                    text: " AED${model.totalCredit}",
                    style: GoogleFonts.roboto(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                text: 'Total withdrawn:',
                style: GoogleFonts.roboto(
                    fontSize: width * .03, color: Colors.black),
                children: [
                  TextSpan(
                    text: " AED${model.totalWithrew}",
                    // text: " AED 20",
                    style: GoogleFonts.roboto(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              lqScore.isEmpty ? 'LQ - 0%' : 'LQ - $lqScore %',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.cyan,
              ),
            ),
          ],
        ),
      ),

      // Badge
      model.profile.isNotEmpty ? Positioned(
        top: height * .0182,
        left: width * .25,
        child: Badge.count(
          count: 1,
          backgroundColor: Colors.cyan,
          textColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          padding: const EdgeInsets.all(4),
        ),
      ): Positioned(
        top: height * .0182,
        left: width * .25,
        child: Badge.count(
          count: 1,
          backgroundColor: Colors.transparent,
          textColor: Colors.transparent,
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          padding: const EdgeInsets.all(4),
        ),
      ),
    ],
  );
}

String getLatestStatus(List<Map<String, dynamic>> statusHistory) {
  if (statusHistory.isEmpty) return '';
  statusHistory.sort((a, b) {
    final DateTime dateA = (a['date'] as Timestamp).toDate();
    final DateTime dateB = (b['date'] as Timestamp).toDate();
    return dateB.compareTo(dateA);
  });
  return statusHistory.first['status']?.toString() ?? '';
}

Widget buildCard({
  required AffiliateModel model,
  required double width,
  required int completedCount,
  required String lqScore,
}) {
  return Container(
    width: width*.9,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey[300]!),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey[400]!, width: 1.5),
          ),
          child: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[200],
            backgroundImage: model.profile.isNotEmpty
                ? NetworkImage(model.profile)
                : AssetImage('assets/image.png'),
          ),
        ),
        SizedBox(height: height * 0.006),

        Text(
          model.name.length > 15
              ? "${model.name.substring(0, 15)}..."
              : model.name,
          style: GoogleFonts.roboto(
            fontSize: width * .04,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        Text(
          model.zone,
          style: GoogleFonts.roboto(
            fontSize: width * .03,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
        ),

        SizedBox(height: 10),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Total leads: ',
                style: GoogleFonts.roboto(
                  fontSize: width * .035,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: '$completedCount',
                style: GoogleFonts.roboto(
                  fontSize: width * .035,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              )
            ],
          ),
        ),

        RichText(
          text: TextSpan(
            text: 'Total credited:',
            style: GoogleFonts.roboto(
                fontSize: width * .03, color: Colors.black),
            children: [
              TextSpan(
                // text: " AED 100",
                text: " AED${model.totalCredit}",
                style: GoogleFonts.roboto(
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        RichText(
          text: TextSpan(
            text: 'Total withdrawn:',
            style: GoogleFonts.roboto(
                fontSize: width * .03, color: Colors.black),
            children: [
              TextSpan(
                text: " AED${model.totalWithrew}",
                // text: " AED 20",
                style: GoogleFonts.roboto(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          lqScore.isEmpty ? 'LQ - 0%' : 'LQ - $lqScore %',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.cyan,
          ),
        ),
      ],
    ),
  );
}