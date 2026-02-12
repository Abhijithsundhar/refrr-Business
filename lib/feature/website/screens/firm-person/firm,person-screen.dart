import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:collection/collection.dart';
import 'package:refrr_admin/Core/common/call-function.dart';
import 'package:refrr_admin/Core/common/chat-screen-support-%20functions.dart';
import 'package:refrr_admin/Core/common/custom-round-button.dart';
import 'package:refrr_admin/Feature/website/controller/firm-controller.dart';

class FirmDetailsPage extends ConsumerWidget {
  final String leadId;
  final String firmName;
  const FirmDetailsPage({
    super.key,
    required this.leadId,
    required this.firmName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncFirmList = ref.watch(firmsStreamProvider(leadId));

    return asyncFirmList.when(
      data: (firms) {
        // 🔍 Match firm by name (case-insensitive)
        final firm = firms.firstWhereOrNull((f) => (f.name.toLowerCase().trim() ?? '') == firmName.toLowerCase().trim(),
        );

        if (firm == null) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Text('No firm found with name "$firmName"'),
            ),
          );
        }

        final type = firm.type.toLowerCase() ?? '';

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: const Color(0xffF3F3F3),
            elevation: 1,
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            title: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 12, left: 16),
                  child: CircleIconButton(
                    icon: Icons.arrow_back_ios_new,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        firm.name ?? 'Company',
                        style: GoogleFonts.urbanist(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 16, color: Colors.black),
                          const SizedBox(width: 4),
                          Text(
                            firm.location ?? '',
                            style: GoogleFonts.urbanist(
                              fontSize: 13,
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            children: [
              const SizedBox(height: 8),

              // ✅ Industry Section (only when type != person)
              if (type != 'person')
                buildSingleInfoSection(
                  title: "Industry",
                  value: firm.industryType ?? 'Not specified',
                ),

              if (type != 'person') const SizedBox(height: 10),

              // ✅ Grouped Info Section
              buildGroupedInfoSection([
                {"title": "Address", "value": firm.address ?? 'Not specified'},
                {"title": "Phone No", "value": firm.phoneNo.toString() ?? 'Not specified'},
                {"title": "Mail ID", "value": firm.email ?? 'Not specified'},
                {"title": "Website", "value": firm.website ?? 'Not specified'},
              ]),

              const SizedBox(height: 14),

              // ✅ Contact Persons Section (only when type != person)
              if (type != 'person' && firm.contactPersons.isNotEmpty == true)
                buildContactPersonsSection(firm.contactPersons),

              if (type != 'person') const SizedBox(height: 16),

              // ✅ Requirements
              buildSingleInfoSection(
                title: "Requirements",
                value: firm.requirement.isNotEmpty == true
                    ? firm.requirement : 'Not specified',
              ),
            ],
          ),
          bottomNavigationBar: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: buildBottomButton(
                    icon: 'assets/svg/phone.svg',
                    onTap: () => openDialer(firm.phoneNo.toString() ?? ''),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: buildBottomButton(
                    icon: 'assets/svg/whatsappBlaack.svg',
                    onTap: () => openWhatsApp(firm.phoneNo.toString() ?? ''),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  /// 🟢 Single info (Industry, Requirements)
  Widget buildSingleInfoSection({
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xffF8F8F8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.urbanist(
                  fontSize: 13.5,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text(value,
              style: GoogleFonts.urbanist(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
        ],
      ),
    );
  }

  /// 🟢 Grouped Info Section (Address / Phone / Mail / Website)
  Widget buildGroupedInfoSection(List<Map<String, String>> items) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xffF8F8F8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(items.length, (index) {
          final title = items[index]["title"] ?? "";
          final value = items[index]["value"] ?? "";
          final isLast = index == items.length - 1;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.urbanist(
                            fontSize: 13.5,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text(value,
                        style: GoogleFonts.urbanist(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87)),
                  ],
                ),
              ),
              if (!isLast)
                Divider(
                    color: Colors.grey[300], thickness: 0.8, height: 0),
            ],
          );
        }),
      ),
    );
  }

  /// 🟢 Contact Persons Section
  Widget buildContactPersonsSection(List<Map<String, dynamic>> people) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xffF8F8F8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Contact Persons",
              style: GoogleFonts.urbanist(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black)),
          const SizedBox(height: 10),
          for (int i = 0; i < people.length; i++) ...[
            buildContactItem(
              name: people[i]["name"] ?? "",
              phone: people[i]["phone"] ?? "",
              email: people[i]["email"] ?? "",
            ),
            if (i != people.length - 1)
              Divider(color: Colors.grey[300], thickness: 0.8, height: 10),
          ],
        ],
      ),
    );
  }

  /// 🟢 Single Contact Person Item
  Widget buildContactItem({
    required String name,
    required String phone,
    required String email,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name,
              style: GoogleFonts.urbanist(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Colors.black)),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(phone,
                  style: GoogleFonts.urbanist(
                      fontSize: 14, color: Colors.grey[700])),
              const SizedBox(width: 6),
              Text("|", style: TextStyle(color: Colors.grey[500])),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  email,
                  style: GoogleFonts.urbanist(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🟢 Bottom buttons (Call / WhatsApp)
  Widget buildBottomButton({
    required String icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xffE5E9EB)),
          color: const Color(0xFFF3F3F3),
        ),
        child: Center(
          child: SvgPicture.asset(
            icon,
            color: const Color(0xFF49454F),
            width: 20,
            height: 18,
          ),
        ),
      ),
    );
  }
}