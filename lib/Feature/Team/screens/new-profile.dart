import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/custom-container.dart';
import 'package:refrr_admin/Core/common/custom-text-fields.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';
import 'package:refrr_admin/models/affiliate-model.dart';

class NewProfile extends StatefulWidget {
  final AffiliateModel? affiliate;
  const NewProfile({super.key, this.affiliate});

  @override
  State<NewProfile> createState() => _NewProfileState();
}

class _NewProfileState extends State<NewProfile> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Example request data (same idea as your original)
  final List<RequestData> requests = const [
    RequestData(amount: 'AED 200', date: '02/07/2025', status: RequestStatus.pending),
    RequestData(amount: 'AED 50', date: '04/06/2025', status: RequestStatus.approved),
    RequestData(amount: 'AED 450', date: '01/06/2025', status: RequestStatus.approved),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Safe getters
  String get avatarUrl => widget.affiliate?.profile ?? '';
  String get name => widget.affiliate?.name ?? 'Agent';
  String get location => widget.affiliate?.zone ?? 'Location';
  String get totalCredit => (widget.affiliate?.totalCredit ?? 0).toString();
  String get totalWithdraw => (widget.affiliate?.totalWithrew ?? 0).toString();
  String get balance => (widget.affiliate?.balance ?? 0).toString();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: width * .025),
            child: SvgPicture.asset('assets/svg/settings.svg', height: 22, width: 22),
          ),
        ],
      ),

      // Bottom bar with contact row
      bottomNavigationBar: Container(
        height: 65,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side: profile + name + location
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                    child: avatarUrl.isEmpty
                        ? const CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('assets/accountProfileImage.png'),
                    )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.roboto(
                          fontSize: width * .04,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        location,
                        style: GoogleFonts.roboto(
                          fontSize: width * .035,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Right side: WhatsApp + Phone icons
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      // TODO: open WhatsApp
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0x1A0FDCEA),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/svg/whatsapp.svg',
                          width: 22,
                          height: 22,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      // TODO: start phone call
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0x1A0FDCEA),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/svg/phonecall.svg',
                          width: 22,
                          height: 22,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // Profile section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(left: width * .04, right: width * .04),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile image card
                  Container(
                    width: width * .27,
                    height: height * .2,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: avatarUrl.isNotEmpty
                          ? Image.network(avatarUrl, fit: BoxFit.cover)
                          : Image.asset('assets/accountProfileImage.png', fit: BoxFit.fill),
                    ),
                  ),
                  SizedBox(width: width * .02),

                  // Name + location + stats
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: width * .055,
                          ),
                        ),
                        Text(
                          location,
                          style: GoogleFonts.roboto(
                            color: Colors.grey,
                            fontWeight: FontWeight.w400,
                            fontSize: width * .04,
                          ),
                        ),
                        SizedBox(height: height * .03),
                        Row(
                          children: [
                            _statBox(widget.affiliate!.totalLeads.toString(), 'Total\nLeads'),
                            SizedBox(width: width * .015),
                            _statBox('${widget.affiliate!.leadScore!.toInt().toString()}%', 'Lead\nQuality'),
                            SizedBox(width: width * .015),
                            _statBox(widget.affiliate!.totalBalance.toString(), 'Balance\n(AED)'),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),

          // Spacer
          SliverToBoxAdapter(child: SizedBox(height: height * .03)),

          // Sticky TabBar
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              child: Container(
                height: 48,
                width: double.infinity,
                color: Colors.grey[100],
                child: TabBar(
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: GoogleFonts.roboto(
                    fontSize: width * .037,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: GoogleFonts.roboto(
                    fontSize: width * .035,
                    fontWeight: FontWeight.w400,
                  ),
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicator: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    ),
                  ),
                  labelPadding: EdgeInsets.symmetric(horizontal: width * 0.04),
                  tabs: const [
                    Tab(text: 'Account'),
                    Tab(text: 'Personal info'),
                    Tab(text: 'Professional info'),
                    Tab(text: 'Career preference'),
                  ],
                ),
              ),
            ),
          ),
        ],

        // Tab content
        body: TabBarView(
          controller: _tabController,
          children: [
            // Account tab: reuse your content
            _buildAccountTab(),

            // Personal info tab: reuse your info fields
            _buildInfoTab(),

            // Professional info - placeholder
            _buildPlaceholderTab(
              'Professional Info',
              'Add professional details here (experience, skills, certifications, etc).',
            ),

            // Career preference - placeholder
            _buildPlaceholderTab(
              'Career Preference',
              'Add preferred industries, roles, locations, and other preferences.',
            ),
          ],
        ),
      ),
    );
  }

  // Stat box like the sample UI
  Widget _statBox(String value, String label) {
    return Container(
      width: width * .2,
      height: height * .1,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: width * .002),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: GoogleFonts.roboto(
              color: Colors.blue[800],
              fontSize: width * .06,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              fontSize: width * .03,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6F6F6F),
            ),
          ),
        ],
      ),
    );
  }

  // Account tab (your previous UI reused)
  Widget _buildAccountTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(height: height * .03),

          Row(
            children: [
              Text(
                'Lead Quality',
                style: GoogleFonts.roboto(
                  fontSize: width * .04,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              SizedBox(width: width * .3),
              customCenteredTextContainer('${widget.affiliate!.leadScore!.toInt().toString()}%'),
            ],
          ),
          SizedBox(height: height * .03),

          Row(
            children: [
              Text(
                'Total Leads Added',
                style: GoogleFonts.roboto(
                  fontSize: width * .04,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              SizedBox(width: width * .19),
              customCenteredTextContainer(widget.affiliate!.totalLeads.toString()),
            ],
          ),
          SizedBox(height: height * .05),

          CustomReadonlyTextField('Total Money Credited', const Color(0xFF33A847), 'AED $totalCredit'),
          SizedBox(height: height * .03),

          CustomReadonlyTextField('Total Money Withdrawn', const Color(0xFFB41010), 'AED $totalWithdraw'),
          SizedBox(height: height * .03),

          CustomReadonlyTextField('Balance Amount', const Color(0xFF0073A1), 'AED ${widget.affiliate!.totalBalance}'),
          SizedBox(height: height * .05),

          Row(
            children: [
              Text('Amount Requested', style: GoogleFonts.roboto(fontWeight: FontWeight.w400, color: Colors.grey)),
              SizedBox(width: width * .26),
              Text('Date', style: GoogleFonts.roboto(fontWeight: FontWeight.w400, color: Colors.grey)),
            ],
          ),

          // Data rows
          ...requests.map((data) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: RequestRow(data: data),
          )),
        ],
      ),
    );
  }

  // Personal info tab (your previous UI reused)
  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildInfoField('Name', name),
          const SizedBox(height: 15),
          _buildInfoField('Location', location),
          const SizedBox(height: 15),
          _buildInfoField('Industry',  widget.affiliate!.industry.join(', ')),
          const SizedBox(height: 15),
          _buildInfoField('Qualification', widget.affiliate!.qualification),
          const SizedBox(height: 15),
          _buildInfoField('Experience', widget.affiliate!.experience),
          const SizedBox(height: 15),
          _buildInfoField('More Info',widget.affiliate!.moreInfo),
        ],
      ),
    );
  }

  // Reusable info field using your CustomTextFormField
  Widget _buildInfoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextFormField(
          initialValue: value,
          maxLines: label == 'More Info' ? 3 : 1,
        ),
      ],
    );
  }

  // Placeholder tabs (replace with your actual content later)
  Widget _buildPlaceholderTab(String title, String subtitle) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(width * .04),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
              style: GoogleFonts.roboto(
                fontSize: width * .045,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            Text(subtitle,
              style: GoogleFonts.roboto(
                fontSize: width * .035,
                fontWeight: FontWeight.w400,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Sticky TabBar delegate
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _SliverTabBarDelegate({required this.child});

  @override
  double get minExtent => 48.0;
  @override
  double get maxExtent => 48.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => child != oldDelegate.child;
}

enum RequestStatus { pending, approved }

class RequestData {
  final String amount;
  final String date;
  final RequestStatus status;

  const RequestData({
    required this.amount,
    required this.date,
    required this.status,
  });
}

class RequestRow extends StatelessWidget {
  final RequestData data;

  const RequestRow({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final isPending = data.status == RequestStatus.pending;

    final borderColor = isPending ? Colors.orange : Colors.green;
    final icon = isPending
        ? const Icon(Icons.hourglass_top, color: Colors.orange, size: 20)
        : const Icon(Icons.check_circle, color: Colors.green, size: 20);

    return Row(
      children: [
        // Amount + status icon
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(data.amount, style: GoogleFonts.roboto(fontWeight: FontWeight.w500, color: Colors.black)),
                icon,
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Date
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(data.date, style: GoogleFonts.roboto(fontWeight: FontWeight.w500, color: Colors.black)),
            ),
          ),
        ),
      ],
    );
  }
}