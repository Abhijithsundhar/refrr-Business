import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Feature/Account/upgradePlan-page.dart';
import '../../Core/common/global variables.dart';
import '../../Model/leads-model.dart';

// Transaction Model
class Transaction {
  final String date;
  final String type;
  final String amount;
  final bool isCredited;

  Transaction({
    required this.date,
    required this.type,
    required this.amount,
    required this.isCredited,
  });
}

class AccountHome extends StatefulWidget {
  final LeadsModel currentFirm;

  const AccountHome({super.key, required this.currentFirm});

  @override
  State<AccountHome> createState() => _AccountHomeState();
}

class _AccountHomeState extends State<AccountHome> {
  final List<Transaction> transactions = [
    Transaction(date: "06-06-2025", type: "Credited", amount: "AED 150", isCredited: true),
    Transaction(date: "30-05-2025", type: "Withdrawn", amount: "AED 250", isCredited: false),
    Transaction(date: "25-05-2025", type: "Credited", amount: "AED 250", isCredited: true),
    Transaction(date: "24-05-2025", type: "Credited", amount: "AED 100", isCredited: true),
    Transaction(date: "18-05-2025", type: "Credited", amount: "AED 300", isCredited: true),
    Transaction(date: "12-05-2025", type: "Withdrawn", amount: "AED 100", isCredited: false),
    Transaction(date: "07-05-2025", type: "Credited", amount: "AED 170", isCredited: true),
    Transaction(date: "06-05-2025", type: "Credited", amount: "AED 300", isCredited: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.only(top: height * .035),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header (logo and menu)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * .05),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/images/refrrTextLogo.png',
                      width: width * .2,
                      height: 50,
                    ),
                    IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              /// Search bar
              Padding(
                padding: EdgeInsets.only(
                  top: 12,
                  bottom: 8,
                  left: width * .05,
                  right: width * .05,
                ),
                child: Container(
                  height: height * .06,
                  width: width * .9,
                  padding: EdgeInsets.symmetric(horizontal: width * .05),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F3F3),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(color: Colors.grey),
                      suffixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),

              /// === Dashboard Cards ===
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                    children: const [
                      StatCard(
                        count: "4",
                        label: "Withdrawal request\npending",
                        imagePath: 'assets/images/account4.png',
                      ),
                      StatCard(
                        count: "AED 100",
                        label: "Money Credited",
                        imagePath: 'assets/images/account3.png',
                      ),
                      StatCard(
                        count: "23",
                        label: "Marketers Added",
                        imagePath: 'assets/images/account2.png',
                      ),
                      StatCard(
                        count: "56",
                        label: "Leads Granted",
                        imagePath: 'assets/images/account1.png',
                      ),
                    ],

                ),
              ),

              SizedBox(height: height * 0.03),

              /// Plan
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * .05),
                child: Text(
                  "Plan",
                  style: GoogleFonts.roboto(fontSize: width*.045, fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(height: 12),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * .05),
                child: Container(
                  padding: EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 4,
                        color: Colors.grey.shade400,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Plan title
                      Text(
                        "Basic Plan",
                        style: GoogleFonts.roboto(fontSize: width*.045, fontWeight: FontWeight.w500,color: Color(0xFF00A0AB)),
                      ),
                      Divider(),

                      /// Maximum marketers
                      SizedBox(height: 6),
                      Text.rich(
                        TextSpan(
                          text: 'Maximum ',
                          style: GoogleFonts.roboto(fontSize: width*.035, fontWeight: FontWeight.w400),
                          children: [
                            TextSpan(
                              text: '10',
                              style:  GoogleFonts.roboto(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: ' marketers can be added.',
                              style: GoogleFonts.roboto(fontSize: width*.035, fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 12),

                      /// Country Row
                      Row(
                        children: [
                          Text(
                            "Country :   ",
                            style: GoogleFonts.roboto(fontSize: width*.035, fontWeight: FontWeight.w400),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text("Dubai",style: GoogleFonts.roboto(fontSize: width*.04, fontWeight: FontWeight.w400),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16),

                      /// Upgrade Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF04C7D6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(context,MaterialPageRoute(builder: (context) => UpgradePlanScreen(),) ) ;
                          },
                          child: Text("Upgrade",style: GoogleFonts.roboto(fontSize: width*.04, fontWeight: FontWeight.w500,color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: height * 0.05),

              /// Transaction History Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * .05),
                child: Text(
                  "Transaction History",
                  style: GoogleFonts.roboto(fontSize: width*.045, fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(height: height*.01),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * .05),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: transactions.length,
                  separatorBuilder: (context, index) => Divider(height: 1),
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4),
                      child: Row(
                        children: [
                          SizedBox(
                            width: width * 0.23,
                            child: Text(
                              tx.date,
                              style: GoogleFonts.roboto(fontSize: width * 0.035, color: Colors.grey[700],fontWeight: FontWeight.w500,),
                            ),
                          ),
                          SizedBox(width: width*.15),
                          SizedBox(
                            width: width * 0.22,
                            child: Text(
                              tx.type,
                              style: GoogleFonts.roboto(fontSize: width * 0.035, color: Colors.black87,fontWeight: FontWeight.w400,),
                            ),
                          ),
                          Spacer(),
                          Text(
                            tx.amount,
                            style: GoogleFonts.roboto(
                              fontSize: width * 0.037,
                              fontWeight: FontWeight.w500,
                              color: tx.isCredited ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: height * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dashboard Card Widget
class StatCard extends StatelessWidget {
  final String count;
  final String label;
  final String imagePath;

  const StatCard({
    super.key,
    required this.count,
    required this.label,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: height * 0.2,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Column(
            children: [
              // Half-height image with overlay text
              SizedBox(
                height: (height * 0.25) / 2,
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Text(
                      count,
                      style: TextStyle(
                        fontSize: width * 0.07,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF04C7D6),
                      ),
                    ),
                  ],
                ),
              ),

              // Label section
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.03,
                    vertical: height * 0.01,
                  ),
                  child: Center(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                        fontSize: width * 0.03,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
