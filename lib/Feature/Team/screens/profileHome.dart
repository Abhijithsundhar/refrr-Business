import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../Core/common/custom-container.dart';
import '../../../Core/common/custom-text-fields.dart';
import '../../../Core/common/global variables.dart';
import '../../../Model/affiliate-model.dart';

class ProfilePage extends StatefulWidget {
  final AffiliateModel? affiliate;
  const ProfilePage({super.key, this.affiliate});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  final List<RequestData> requests = const [
    RequestData(amount: 'AED 200', date: '02/07/2025', status: RequestStatus.pending),
    RequestData(amount: 'AED 50', date: '04/06/2025', status: RequestStatus.approved),
    RequestData(amount: 'AED 450', date: '01/06/2025', status: RequestStatus.approved),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            color: Colors.white,
            icon: Icon(Icons.more_vert, color: Colors.black),
            onSelected: (String value) {
              if (value == 'Remove') {
                // Do something
              } else if (value == 'Report') {
                // Do something else
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'Remove',
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: MediaQuery.of(context).size.height * 0.06,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      'Remove',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'Report',
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: MediaQuery.of(context).size.height * 0.06,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      'Report',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          /// Profile Header
          Container(
            child: Column(
              children: [
                // Profile Avatar
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                    image: DecorationImage(
                      image: AssetImage('assets/profile_avatar.png'), // Replace with your image
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: ClipOval(
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                SizedBox(height: height*.01),

                // Tab Bar
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                    ),
                  ),
                  child: // Wrap the TabBar in a Container if you have a border now — we’ll remove that
                  Container(
                    // Remove or comment this to get rid of the gray underline
                    // decoration: BoxDecoration(
                    //   border: Border(
                    //     bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                    //   ),
                    // ),
                    child: TabBar(
                      dividerColor:  Colors.transparent,
                      indicatorSize: TabBarIndicatorSize.tab,
                      mouseCursor: SystemMouseCursors.basic, // Use normal arrow cursor
                      overlayColor: MaterialStateProperty.all(Colors.transparent), // Disable hover effect
                      controller: _tabController,
                      tabs: [
                        Tab(child: Text('Account')),
                        Tab(child: Text('Info')),
                      ],
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey[600],

                      // Selected tab text style
                      labelStyle: GoogleFonts.roboto(
                        fontSize: width*.04,
                        fontWeight: FontWeight.w500, // make it bold
                      ),

                      // Unselected tab text style
                      unselectedLabelStyle: GoogleFonts.roboto(
                        fontSize: width*.04,
                        fontWeight: FontWeight.w500, // make it bold
                      ),

                      // Increase size of selected line
                      indicator: UnderlineTabIndicator(
                        borderSide: BorderSide(
                          color: Color(0xFF9DF6FF),
                          width: 4, // increase thickness of blue line
                        ),
                        insets: EdgeInsets.symmetric(horizontal: 30), // control line width
                      ),
                    ),
                  )
                  ,
                ),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Account Tab
                _buildAccountTab(width),

                // Info Tab
                _buildInfoTab(width),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTab(double width) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(height: height*.03,),

          Row(
            children: [
              Text(
                'Lead Quality',
                style: GoogleFonts.roboto(
                  fontSize: width*.04,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(width: width*.3,),
              customCenteredTextContainer('80%')
            ],
          ),
          SizedBox(height: height*.03,),
          Row(
            children: [
              Text(
                'Total Leads Added',
                style: GoogleFonts.roboto(
                  fontSize: width*.04,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(width: width*.19,),
              customCenteredTextContainer('13')
            ],
          ),
          SizedBox(height: height*.05,),
          CustomReadonlyTextField('Total Money Credited', Color(0xFF33A847), 'AED ${widget.affiliate!.totalCredit}'),
          SizedBox(height: height*.03,),

          CustomReadonlyTextField('Total Money Withdrawn', Color(0xFFB41010),'AED ${widget.affiliate!.totalWithrew} ',),
          SizedBox(height: height*.03,),

          CustomReadonlyTextField('Balance Amount', Color(0xFF0073A1),'AED ${widget.affiliate!.balance}',),
          SizedBox(height: height*.05,),

          Row(
            children:  [
              Text('Amount Requested', style: GoogleFonts.roboto(fontWeight: FontWeight.w400, color: Colors.grey)),
              SizedBox(width: width*.26,),

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

  Widget _buildInfoTab(double width) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          // Profile Info Fields
          _buildInfoField('Name', widget.affiliate!.name),
          SizedBox(height: 15),
          _buildInfoField('Location', widget.affiliate!.zone),
          SizedBox(height: 15),
          _buildInfoField('Industry', 'Education, Food, Health'),
          SizedBox(height: 15),
          _buildInfoField('Qualification', 'Bsc Computer Science'),
          SizedBox(height: 15),
          _buildInfoField('Experience', '8 Years'),
          SizedBox(height: 15),
          _buildInfoField('More Info', 'Lorem Ipsum is simply dummy text of the \nprinting and typesetting industry. Lorem Ipsum has been the best.'),

        ],
      ),
    );
  }

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
        SizedBox(height: 8),
        CustomTextFormField(
          initialValue: value,
          maxLines: label == 'More Info' ? 3 : 1,
        ),
      ],
    );
  }

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