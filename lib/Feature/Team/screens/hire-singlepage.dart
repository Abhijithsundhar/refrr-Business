import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:refrr_admin/Model/affiliate-model.dart';
import '../../../Core/common/global variables.dart';

class HireSinglePage extends StatelessWidget {
  final AffiliateModel affiliate;
  const HireSinglePage({super.key, required this.affiliate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          // No margin, full width
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
          decoration: const BoxDecoration(
            color: Colors.white,
            // You can keep borderRadius if you want rounded corners
            // borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [

              // Profile image
              CircleAvatar(
                radius: 55,
                backgroundImage: affiliate.profile.isEmpty?NetworkImage(
                  "https://images.pexels.com/photos/1130626/pexels-photo-1130626.jpeg",
                ):NetworkImage(affiliate.profile),
                backgroundColor: Colors.grey[300],
              ),
              const SizedBox(height: 18),
              // Details
              _profileRow("Name", affiliate.name),
              _profileRow("Location", affiliate.zone),
              _profileRow("Phone NO", affiliate.phone),
              _profileRow("Email ID", affiliate.mailId),
              _profileRow("Lead Quality", "80%"),
              _profileRow("Total leads added", "12"),
              _profileRow("Industry", "Education\nFood\nConstruction"),
              _profileRow("Qualification", "BCA"),
              _profileRow("Experience", "4 Years"),
              _profileRow("More Info",
                "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the best of all is this.",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: value.contains('\n') || value.length > 40
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              "$label",
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ),
          const Text(
            " : ",
            style: TextStyle(fontSize: 15, color: Colors.black87),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}