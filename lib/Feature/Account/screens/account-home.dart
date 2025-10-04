import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';
import 'package:refrr_admin/Feature/Account/screens/upgradePlan-page.dart';
import 'package:refrr_admin/models/leads_model.dart';


// Transaction model
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

class AccountHome extends ConsumerStatefulWidget {
  final LeadsModel? currentFirm;

  const AccountHome({super.key, required this.currentFirm});

  @override
  ConsumerState<AccountHome> createState() => _AccountHomeState();
}

class _AccountHomeState extends ConsumerState<AccountHome> {
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

  // Use double for money
  // late double totalCreditsSum;
  // // Use int for count of pending requests
  // late int totalWithdrawalPending;

  @override
  void initState() {
    super.initState();
    // totalCreditsSum = calculateTotalCredits();
    // totalWithdrawalPending = calculateTotalWithdrawalPending();
  }

  @override
  void didUpdateWidget(covariant AccountHome oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentFirm != widget.currentFirm) {
      setState(() {
        // totalCreditsSum = calculateTotalCredits();
        // totalWithdrawalPending = calculateTotalWithdrawalPending();
      });
    }
  }

  /// Total pending requests across all team members.
  /// withdrawalRequest can be int/num/String OR a List (e.g., List<WithdrewrequstModel>).
  // int calculateTotalWithdrawalPending() {
  //   final team = widget.currentFirm?.teamMembers ?? [];
  //   int sum = 0;
  //
  //   for (final member in team) {
  //     final pending = member.withdrawalRequest;
  //
  //     if (pending == null) continue;
  //
  //     // If it's a number or string containing number
  //     if (pending is int) {
  //       sum += pending;
  //     } else if (pending is num) {
  //       sum += pending.toInt();
  //     } else if (pending is String) {
  //       sum += int.tryParse(pending) ?? 0;
  //     } else if (pending is List) {
  //       // If it's a list of requests, count pending items (or all if no status field)
  //       sum += _pendingCountFromList(pending);
  //     }
  //     // else: unknown type -> ignore
  //   }
  //
  //   return sum;
  // }

  /// Count "pending" items in a list of requests.
  /// Tries to detect status fields; if none, counts all items.
  int _pendingCountFromList(List list) {
    int count = 0;
    for (final item in list) {
      // Map shape: {status: 'pending'} or {isPending: true}
      if (item is Map) {
        final status = (item['status'] ?? item['state'])?.toString().toLowerCase();
        final isPendingBool = item['isPending'] == true;
        if (isPendingBool || status == 'pending') {
          count++;
        } else if (status == null) {
          // No status field, assume it's a pending entry
          count++;
        }
        continue;
      }

      // model shape: item.status / item.state / item.isPending
      try {
        final dynamic dyn = item;
        final dynamicStatus = dyn.status ?? dyn.state;
        final statusStr = dynamicStatus?.toString().toLowerCase();
        final isPending = dyn.isPending == true;
        if (isPending || statusStr == 'pending') {
          count++;
        } else if (dynamicStatus == null) {
          // No status field, assume pending
          count++;
        }
      } catch (_) {
        // Unknown shape, count it
        count++;
      }
    }
    return count;
  }

  /// Total credited money across all team members.
  /// totalCredits can be num/String OR a List<TotalCreditModel>/List<Map>/List<dynamic>.
  // double calculateTotalCredits() {
  //   final firm = widget.currentFirm;
  //   if (firm == null || firm.teamMembers.isEmpty) return 0;
  //
  //   double sum = 0;
  //
  //   for (final member in firm.teamMembers) {
  //     final creditsObj = member.totalCredits;
  //     if (creditsObj == null) continue;
  //
  //     if (creditsObj is num) {
  //       sum += creditsObj.toDouble();
  //       continue;
  //     }
  //     if (creditsObj is String) {
  //       sum += double.tryParse(creditsObj) ?? 0;
  //       continue;
  //     }
  //
  //     if (creditsObj is List) {
  //       for (final item in creditsObj) {
  //         sum += _creditAmountDouble(item);
  //       }
  //     }
  //     // else: unknown type -> ignore
  //   }
  //
  //   return sum;
  // }

  /// Extract a double amount from one credit entry.
  /// If you know your model, replace with (item as TotalCreditModel).amount?.toDouble() ?? 0;
  double _creditAmountDouble(dynamic item) {
    if (item == null) return 0;

    // Primitive cases
    if (item is num) return item.toDouble();
    if (item is String) return double.tryParse(item) ?? 0;

    // Map case
    if (item is Map) {
      final v = item['amount'] ?? item['value'] ?? item['credits'] ?? item['total'];
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0;
      return 0;
    }

    // model case with dynamic getters
    try {
      final v = (item as dynamic).amount;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0;
    } catch (_) {}
    try {
      final v = (item as dynamic).value;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0;
    } catch (_) {}
    try {
      final v = (item as dynamic).credits;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0;
    } catch (_) {}
    try {
      final v = (item as dynamic).total;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0;
    } catch (_) {}

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    // Format money for display (no decimals; change to 2 if needed)
    // final creditsDisplay = totalCreditsSum.toStringAsFixed(0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          widget.currentFirm?.name ?? '',
          style: GoogleFonts.bebasNeue(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: width * .055,
          ),
        ),
        actions: [
          Icon(Icons.menu),
          SizedBox(width: width * .03),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(top: height * .01),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dashboard Cards
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    StatCard(
                      count: '08',
                      label: "Withdrawal request\npending",
                      imagePath: 'assets/images/account4.png',
                    ),
                    StatCard(
                      count: "AED 25",
                      label: "Money Credited",
                      imagePath: 'assets/images/account3.png',
                    ),
                    StatCard(
                      count: widget.currentFirm?.teamMembers.length.toString() ?? '0',
                      label: "Marketers Added",
                      imagePath: 'assets/images/account2.png',
                    ),
                    const StatCard(
                      count: "56",
                      label: "Leads Granted",
                      imagePath: 'assets/images/account1.png',
                    ),
                  ],
                ),
              ),

              SizedBox(height: height * 0.03),

              // Plan Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * .05),
                child: Text(
                  "Plan",
                  style: GoogleFonts.roboto(fontSize: width * .045, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 12),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * .05),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 4,
                        color: Colors.grey.shade400,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Plan title
                      Text(
                        "Basic Plan",
                        style: GoogleFonts.roboto(
                          fontSize: width * .045,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF00A0AB),
                        ),
                      ),
                      const Divider(),

                      const SizedBox(height: 6),
                      Text.rich(
                        TextSpan(
                          text: 'Maximum ',
                          style: GoogleFonts.roboto(fontSize: width * .035, fontWeight: FontWeight.w400),
                          children: [
                            TextSpan(
                              text: '10',
                              style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: ' marketers can be added.',
                              style: GoogleFonts.roboto(fontSize: width * .035, fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Country Row
                      Row(
                        children: [
                          Text(
                            "Country :   ",
                            style: GoogleFonts.roboto(fontSize: width * .035, fontWeight: FontWeight.w400),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "UAE",
                              style: GoogleFonts.roboto(fontSize: width * .04, fontWeight: FontWeight.w400),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Upgrade Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF04C7D6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => UpgradePlanScreen()),
                            );
                          },
                          child: Text(
                            "Upgrade",
                            style: GoogleFonts.roboto(
                              fontSize: width * .04,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: height * 0.05),

              // Transaction History
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * .05),
                child: Text(
                  "Transaction History",
                  style: GoogleFonts.roboto(fontSize: width * .045, fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(height: height * .01),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * .05),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: transactions.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
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
                              style: GoogleFonts.roboto(
                                fontSize: width * 0.035,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(width: width * .15),
                          SizedBox(
                            width: width * 0.22,
                            child: Text(
                              tx.type,
                              style: GoogleFonts.roboto(
                                fontSize: width * 0.035,
                                color: Colors.black87,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          const Spacer(),
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
              SizedBox(
                height: (height * 0.25) / 2,
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
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
                      count, // always a String
                      style: TextStyle(
                        fontSize: width * 0.07,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF04C7D6),
                      ),
                    ),
                  ],
                ),
              ),
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
                        fontWeight: FontWeight.w500,
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