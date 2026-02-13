import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/core/common/alert_box.dart';
import 'package:refrr_admin/core/common/call_function.dart';
import 'package:refrr_admin/core/common/chat_screen_support_functions.dart';
import 'package:refrr_admin/core/common/custom_round_button.dart';
import 'package:refrr_admin/core/common/global_variables.dart';
import 'package:refrr_admin/core/common/snackbar.dart';
import 'package:refrr_admin/core/common/text_editing_controllers.dart';
import 'package:refrr_admin/core/common/whatsapp_function.dart';
import 'package:refrr_admin/core/constants/asset.dart';
import 'package:refrr_admin/core/constants/firebase_constants.dart';
import 'package:refrr_admin/core/theme/pallet.dart';
import 'package:refrr_admin/feature/team/controller/affiliate_controller.dart';
import 'package:refrr_admin/feature/team/controller/withdrawal_request_controller.dart';
import 'package:refrr_admin/feature/team/screens/career_tab.dart';
import 'package:refrr_admin/feature/team/screens/personal_info_tab.dart';
import 'package:refrr_admin/feature/team/screens/piple_line_tab.dart';
import 'package:refrr_admin/feature/team/screens/prefssonal_tab.dart';
import 'package:refrr_admin/models/affiliate_model.dart';
import 'package:refrr_admin/models/balanceamount_model.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:refrr_admin/models/totalcredit_model.dart';
import 'package:refrr_admin/models/withdrewrequst_model.dart';

class AccountProfileScreen extends ConsumerStatefulWidget {
  final AffiliateModel affiliate;
  final LeadsModel? currentFirm;

  const AccountProfileScreen({
    super.key,
    required this.affiliate,
    this.currentFirm,
  });

  @override
  ConsumerState<AccountProfileScreen> createState() => _AccountProfileScreenState();
}

class _AccountProfileScreenState extends ConsumerState<AccountProfileScreen> {
  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  int selectedTab = 0;
  bool _isAddingMoney = false;

  /// 🔹 Get Affiliate ID
  String get affiliateId => widget.affiliate.id ?? widget.affiliate.reference?.id ?? '';

  /// 🔹 Add Money to Affiliate (Using Riverpod - FIXED)
  Future<void> _addMoneyToAffiliate() async {
    // Validate inputs
    if (amountController.text.trim().isEmpty) {
      showCommonSnackbar(context, "Please enter amount");
      return;
    }

    if (remarksController.text.trim().isEmpty) {
      showCommonSnackbar(context, "Please enter remarks");
      return;
    }

    // Parse amount
    final int? amount = int.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0) {
      showCommonSnackbar(context, "Please enter a valid amount");
      return;
    }

    setState(() => _isAddingMoney = true);

    try {
      if (affiliateId.isEmpty) {
        showCommonSnackbar(context, 'Error: Affiliate ID not found');
        setState(() => _isAddingMoney = false);
        return;
      }

      // Create new TotalCreditModel entry
      final TotalCreditModel newCreditEntry = TotalCreditModel(
        amount: double.parse(amountController.text),
        addedTime: DateTime.now(),
        acceptBy: '',
        currency: widget.currentFirm?.currency ?? '',
        image: '',
        description: remarksController.text,
        moneyAddedBy: widget.currentFirm?.reference?.id ?? '',
      );

      // Create new BalanceModel entry
      final BalanceModel newBalanceEntry = BalanceModel(
        amount: double.parse(amountController.text),
        addedTime: DateTime.now(),
        acceptBy: '',
        currency: widget.currentFirm?.currency ?? '',
      );

      debugPrint('💰 Adding money: $amount');
      debugPrint('💰 Affiliate ID: $affiliateId');

      // Use Riverpod controller to add money (with proper append logic)
      final success = await ref.read(affiliateControllerProvider.notifier).addMoneyToAffiliate(
        affiliateId: affiliateId,
        amount: amount,
        newCreditEntry: newCreditEntry,
        newBalanceEntry: newBalanceEntry,
        context: context,
      );

      if (success) {
        debugPrint('✅ Money added successfully');

        // Close bottom sheet
        if (mounted) {
          Navigator.pop(context);
        }

        // Show success message
        if (mounted) {
          showCommonSnackbar(context, "Amount added successfully");
        }

        // Clear controllers
        amountController.clear();
        remarksController.clear();
      }
    } catch (e) {
      debugPrint('❌ Error adding money: $e');
      if (mounted) {
        showCommonSnackbar(context, 'Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isAddingMoney = false);
      }
    }
  }

  /// 🔹 Show Add Money Confirmation
  void _showAddMoneyConfirmation() {
    showHireConfirmation(
      context,
      'Are you sure you want to add ${widget.currentFirm?.currency ?? ''} ${amountController.text} to ${widget.affiliate.name} account?',
          () async {
        Navigator.pop(context); // Close confirmation dialog
        await _addMoneyToAffiliate();
      },
    );
  }

  /// 🔹 Remove Affiliate Directly with Firestore
  Future<void> _removeAffiliateFromTeam() async {
    final String? firmId = widget.currentFirm?.reference?.id;

    debugPrint('🔍 Firm ID: $firmId');
    debugPrint('🔍 Affiliate ID: $affiliateId');

    if (firmId == null || firmId.isEmpty) {
      showCommonSnackbar(context, 'Error: Firm ID not found');
      return;
    }

    if (affiliateId.isEmpty) {
      showCommonSnackbar(context, 'Error: Affiliate ID not found');
      return;
    }

    try {
      final firestore = FirebaseFirestore.instance;
      final docSnapshot = await firestore.collection('leads').doc(firmId).get();

      if (!docSnapshot.exists) {
        showCommonSnackbar(context, 'Error: Firm document not found');
        return;
      }

      List<dynamic> teamMembers = docSnapshot.data()?['teamMembers'] ?? [];

      teamMembers.removeWhere((member) {
        if (member is String) {
          return member == affiliateId;
        } else if (member is DocumentReference) {
          return member.id == affiliateId;
        } else if (member is Map) {
          return member['id'] == affiliateId ||
              member['affiliateId'] == affiliateId ||
              member['uid'] == affiliateId;
        }
        return false;
      });

      await firestore.collection(FirebaseCollections.leadsCollection).doc(firmId).update({
        'teamMembers': teamMembers,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        showCommonSnackbar(context, '${widget.affiliate.name} removed from team');
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('❌ Error: $e');
      if (mounted) {
        showCommonSnackbar(context, 'Error: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double w = width;
    double h = height;

    // 🔹 Watch the affiliate stream for real-time updates
    final affiliateStream = ref.watch(affiliateByIdStreamProvider(affiliateId));

    return Scaffold(
      backgroundColor: Pallet.backgroundColor,
      body: affiliateStream.when(
        data: (affiliate) {
          // Use streamed affiliate data, fallback to widget.affiliate if null
          final currentAffiliate = affiliate ?? widget.affiliate;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== HEADER =====
                _buildHeader(currentAffiliate, w, h),

                SizedBox(height: w * 0.02),

                // ===== STAT CARDS =====
                Padding(
                  padding: EdgeInsets.only(top: w * 0.03, left: width * .04),
                  child: Row(
                    children: [
                      _statBox("Total Leads", "${currentAffiliate.totalLeads}"),
                      SizedBox(width: width * .005),
                      _statBox("LQ", "${currentAffiliate.leadScore?.toInt()} %"),
                      SizedBox(width: width * .005),
                      _statBox("Total Agents", "0"),
                      SizedBox(width: width * .02),
                    ],
                  ),
                ),
                SizedBox(height: h * 0.02),

                // ===== TAB BAR =====
                Padding(
                  padding: EdgeInsets.only(
                    left: w * 0.04,
                    right: w * 0.01,
                    top: w * 0.01,
                    bottom: w * 0.01,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      height: w * 0.1,
                      width: h * 0.76,
                      decoration: BoxDecoration(
                        color: Pallet.lightBlue,
                        borderRadius: BorderRadius.circular(w * 0.05),
                      ),
                      child: Row(
                        children: [
                          _tabItem("account", 0),
                          _tabItem("Pipeline", 1),
                          _tabItem("Personal Info", 2),
                          _tabItem("Professional Info", 3),
                          _tabItem("Career Preference", 4),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: h * 0.02),

                // ===== TAB CONTENT =====
                _buildTabContent(currentAffiliate),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          debugPrint('❌ Stream Error: $error');
          return _buildMainContent(widget.affiliate);
        },
      ),
      // floatingActionButton: selectedTab == 0
      //     ? SizedBox(
      //   height: height * .05,
      //   width: width * 0.35,
      //   child: InkWell(
      //     borderRadius: BorderRadius.circular(width * 0.02),
      //     onTap: () {
      //       amountController.clear();
      //       remarksController.clear();
      //       showAddPaymentSheet(
      //         context,
      //         widget.affiliate.name,
      //         amountController,
      //         remarksController,
      //         widget.currentFirm,
      //             () {
      //           // Validate before showing confirmation
      //           if (amountController.text.trim().isEmpty) {
      //             showCommonSnackbar(context, "Please enter amount");
      //             return;
      //           }
      //
      //           if (remarksController.text.trim().isEmpty) {
      //             showCommonSnackbar(context, "Please enter remarks");
      //             return;
      //           }
      //
      //           final int? amount = int.tryParse(amountController.text.trim());
      //           if (amount == null || amount <= 0) {
      //             showCommonSnackbar(context, "Please enter a valid amount");
      //             return;
      //           }
      //           // Show confirmation
      //           _showAddMoneyConfirmation();
      //         },
      //       );
      //     },
      //     child: Container(
      //       padding: EdgeInsets.symmetric(vertical: width * 0.025),
      //       decoration: BoxDecoration(
      //         color: Pallet.primaryColor,
      //         borderRadius: BorderRadius.circular(width * 0.02),
      //       ),
      //       child: Row(
      //         mainAxisAlignment: MainAxisAlignment.center,
      //         children: [
      //           SvgPicture.asset(
      //             AssetConstants.add,
      //             width: width * 0.055,
      //             color: Colors.white,
      //           ),
      //           SizedBox(width: width * 0.01),
      //           Text('Add Money',
      //             style: GoogleFonts.dmSans(
      //               color: Colors.white,
      //               fontSize: width * 0.037,
      //               fontWeight: FontWeight.w600,
      //             ),
      //           ),
      //         ],
      //       ),
      //     ),
      //   ),
      // ) : const SizedBox(),
    );
  }

  /// 🔹 Build Main Content (Fallback)
  Widget _buildMainContent(AffiliateModel affiliate) {
    double w = width;
    double h = height;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(affiliate, w, h),
          SizedBox(height: w * 0.02),
          Padding(
            padding: EdgeInsets.only(top: w * 0.03, left: width * .04),
            child: Row(
              children: [
                _statBox("Total Leads", "${affiliate.totalLeads}"),
                SizedBox(width: width * .005),
                _statBox("LQ", "${affiliate.leadScore?.toInt()} %"),
                SizedBox(width: width * .005),
                _statBox("Total Agents",affiliate.agentCount ==0 ?'0':affiliate.agentCount.toString()),
                SizedBox(width: width * .02),
              ],
            ),
          ),
          SizedBox(height: h * 0.02),
          Padding(
            padding: EdgeInsets.only(
              left: w * 0.04,
              right: w * 0.01,
              top: w * 0.01,
              bottom: w * 0.01,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                height: w * 0.1,
                width: h * 0.76,
                decoration: BoxDecoration(
                  color: Pallet.lightBlue,
                  borderRadius: BorderRadius.circular(w * 0.05),
                ),
                child: Row(
                  children: [
                    _tabItem("account", 0),
                    _tabItem("Pipeline", 1),
                    _tabItem("Personal Info", 2),
                    _tabItem("Professional Info", 3),
                    _tabItem("Career Preference", 4),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: h * 0.02),
          _buildTabContent(affiliate),
        ],
      ),
    );
  }

  /// 🔹 Build Header
  Widget _buildHeader(AffiliateModel affiliate, double w, double h) {
    return SizedBox(
      height: h * 0.23,
      child: Stack(
        children: [
          Container(
            height: h * 0.15,
            decoration: BoxDecoration(
              color: const Color(0xFFE9FCFE),
              border: Border.all(
                color: const Color(0xFFE5E9EB),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                SizedBox(width: width * .05),
                CircleIconButton(
                  size: width * .08,
                  icon: Icons.arrow_back_ios_new,
                  onTap: () => Navigator.pop(context),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => openDialer(affiliate.phone ?? ''),
                  child: CircleSvgButton(
                    size: width * .08,
                    child: SvgPicture.asset(
                      'assets/svg/blackphone.svg',
                      width: w * 0.04,
                    ),
                  ),
                ),
                SizedBox(width: w * 0.025),
                GestureDetector(
                  onTap: () => openWhatsAppChat(affiliate.phone),
                  child: CircleSvgButton(
                    size: width * .08,
                    child: SvgPicture.asset(
                      'assets/svg/whatsappBlaack.svg',
                      width: w * 0.05,
                    ),
                  ),
                ),
                SizedBox(width: w * 0.025),
                GestureDetector(
                  onTapDown: (TapDownDetails details) {
                    showDeleteMenu(context, details.globalPosition, () {
                      showCommonAlertBox(
                        context,
                        'Are you sure you want to remove ${affiliate.name} from your team?',
                            () {
                          Navigator.pop(context);
                          _removeAffiliateFromTeam();
                        },
                        'Confirm',
                      );
                    });
                  },
                  child: CircleSvgButton(
                    size: width * .08,
                    child: SvgPicture.asset(
                      'assets/svg/more.svg',
                      width: w * 0.04,
                    ),
                  ),
                ),
                SizedBox(width: width * .06),
              ],
            ),
          ),
          Positioned(
            left: w * 0.07,
            top: w * 0.21,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: h * 0.061,
                  backgroundColor: Pallet.backgroundColor,
                  child: CircleAvatar(
                    radius: h * 0.055,
                    backgroundImage: NetworkImage(affiliate.profile ?? ''),
                  ),
                ),
                SizedBox(width: w * 0.03),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: w * 0.06),
                    Text(
                      affiliate.name,
                      style: GoogleFonts.dmSans(
                        fontSize: w * 0.045,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      children: [
                        SvgPicture.asset(
                          AssetConstants.location,
                          width: width * .03,
                        ),
                        SizedBox(width: w * 0.005),
                        Text(
                          "${affiliate.zone} ${affiliate.country}",
                          style: GoogleFonts.dmSans(
                            fontSize: w * 0.025,
                            color: Pallet.greyColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Build Tab Content
  Widget _buildTabContent(AffiliateModel affiliate) {
    switch (selectedTab) {
      case 0:
        return _buildAccountTab(affiliate);
      case 1:
        return PipelineTab(affiliate: affiliate,currentFirm:widget.currentFirm);
      case 2:
        return PersonalInfoTab(affiliate: affiliate);
      case 3:
        return ProfessionalInfoTab(affiliate: affiliate);
      case 4:
        return CareerTab(affiliate: affiliate);
      default:
        return _buildAccountTab(affiliate);
    }
  }

  /// 🔹 account Tab Content (UPDATED - Fetches from subcollection)
  Widget _buildAccountTab(AffiliateModel affiliate) {
    double w = width;
    double h = height;

    // 👇 Create filter for withdrawal requests
    final filter = WithdrawalRequestFilter(affiliateId: affiliateId, isFirmRequest: true,statusFilter: 0);

    // 👇 Watch the withdrawal requests provider
    final withdrawalRequestsAsync = ref.watch(withdrawalRequestsProvider(filter));

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(w * 0.02),
          child: Row(
            children: [
              SizedBox(width: width * .027),
              Expanded(
                child: _amountCard(
                  "Amount Credited",
                  "${widget.currentFirm?.currency ?? ''} ${affiliate.totalCredit} ",
                  Colors.green,
                ),
              ),
              SizedBox(width: w * 0.02),
              Expanded(
                child: _amountCard(
                  "Amount Withdrawn",
                  "${widget.currentFirm?.currency ?? ''} ${affiliate.totalWithrew}",
                  Colors.red,
                ),
              ),
              SizedBox(width: width * .027),
            ],
          ),
        ),

        // ===== MONEY REQUESTS HEADER =====
        Padding(
          padding: EdgeInsets.all(w * 0.02),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: width * .027),
              Text("Money Requests",
                style: GoogleFonts.dmSans(
                  fontSize: w * 0.045,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              // 👇 Show "View All" based on fetched data
              withdrawalRequestsAsync.when(
                data: (requests) {
                  if (requests.length >= 4) {
                    return GestureDetector(
                      onTap: () {
                        // Navigate to view all requests
                      },
                      child: Container(
                        width: w * 0.2,
                        height: w * 0.07,
                        decoration: BoxDecoration(
                          border: Border.all(color: Pallet.borderColor),
                          borderRadius: BorderRadius.circular(w * 0.05),
                        ),
                        child: Center(
                          child: Text(
                            "View All",
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w700,
                              fontSize: w * 0.03,
                              color: Pallet.greyColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),
              SizedBox(width: width * .027),
            ],
          ),
        ),

        // ===== MONEY REQUESTS LIST (FROM SUBCOLLECTION) =====
        withdrawalRequestsAsync.when(
          data: (requests) {
            debugPrint('📦 Fetched ${requests.length} withdrawal requests');

            if (requests.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: h * 0.03),
                child: Center(
                  child: Text("No pending requests",
                    style: GoogleFonts.dmSans(
                      fontSize: w * 0.035,
                      fontWeight: FontWeight.w500,
                      color: Pallet.greyColor,
                    ),
                  ),
                ),
              );
            }

            return ListView.builder(
              itemCount: requests.length,
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final request = requests[index];
                return _moneyRequestItem(request,"${widget.currentFirm?.currency ?? 'AED'} ${request.amount.toInt()}",
                  _formatDate(request.requstTime),
                );
              },
            );
          },
          loading: () => Padding(
            padding: EdgeInsets.symmetric(vertical: h * 0.05),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) {
            debugPrint('❌ Error fetching withdrawal requests: $error');
            return Padding(
              padding: EdgeInsets.symmetric(vertical: h * 0.03),
              child: Center(
                child: Text("Failed to load requests",
                  style: GoogleFonts.dmSans(
                    fontSize: w * 0.035,
                    fontWeight: FontWeight.w500,
                    color: Pallet.greyColor,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ===== HELPER WIDGETS =====

  Widget _statBox(String title, String value) {
    return Container(
      width: width * 0.3,
      height: height * 0.09,
      margin: EdgeInsets.only(right: width * 0.01),
      decoration: BoxDecoration(
        color: Pallet.lightGreyColor,
        borderRadius: BorderRadius.circular(width * 0.03),
        border: Border.all(color: const Color(0xFFE5E9EB), width: 1),
      ),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: height * .015),
            Text(
              title,
              style: GoogleFonts.dmSans(
                fontSize: width * 0.04,
                fontWeight: FontWeight.w400,
                color: Pallet.greyColor,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.dmSans(
                fontSize: width * 0.045,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabItem(String title, int index) {
    bool active = selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = index),
      child: Container(
        width: width * 0.3,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(width * 0.05),
          border: active
              ? Border.all(color: Pallet.primaryColor, width: 1.5)
              : null,
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: width * 0.032,
              fontWeight: FontWeight.w500,
              color: active ? Pallet.secondaryColor : Pallet.greyColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _amountCard(String title, String value, Color color) {
    return Container(
      height: height * .1113,
      padding: EdgeInsets.only(left: width * 0.03, top: height * 0.025),
      decoration: BoxDecoration(
        color: Pallet.backgroundColor,
        borderRadius: BorderRadius.circular(width * 0.02),
        border: Border.all(color: Pallet.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(
                title,
                style: GoogleFonts.dmSans(
                  fontSize: width * 0.032,
                  fontWeight: FontWeight.w500,
                  color: Pallet.greyColor,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w500,
                  fontSize: width * 0.055,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ///UPDATED: Accept/Reject withdrawal request with request model
  Widget _moneyRequestItem(WithdrewrequstModel request, String amount, String date) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.04),
      child: Container(
        margin: EdgeInsets.only(bottom: width * 0.02),
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.02,
          vertical: width * 0.035,
        ),
        decoration: BoxDecoration(
          color: Pallet.lightGreyColor,
          borderRadius: BorderRadius.circular(width * 0.02),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              amount,
              style: GoogleFonts.dmSans(
                fontSize: width * 0.045,
                fontWeight: FontWeight.w600,
                color: Pallet.greyColor,
              ),
            ),
            SizedBox(height: width * 0.02),
            Row(
              children: [
                Text(
                  date,
                  style: GoogleFonts.dmSans(
                    fontSize: width * 0.03,
                    color: Pallet.greyColor,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    // 👇 Handle Reject
                    _handleRejectRequest(request);
                  },
                  child: Text(
                    "Reject",
                    style: GoogleFonts.dmSans(
                      color: Pallet.redColor,
                      fontWeight: FontWeight.bold,
                      fontSize: width * 0.03,
                    ),
                  ),
                ),
                SizedBox(width: width * 0.03),
                GestureDetector(
                  onTap: () {
                    // 👇 Handle Accept
                    _handleAcceptRequest(request);
                  },
                  child: Text(
                    "Accept",
                    style: GoogleFonts.dmSans(
                      color: Pallet.greenColor,
                      fontWeight: FontWeight.bold,
                      fontSize: width * 0.03,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ///Handle Accept Request
  void _handleAcceptRequest(WithdrewrequstModel request) {
    showCommonAlertBox(
      context,
      'Are you sure you want to accept this withdrawal request of '
          '${widget.currentFirm?.currency ?? 'AED'} ${request.amount.toInt()}?',
          () async {
        Navigator.pop(context); // Close dialog

        try {
          // ✅ Create updated request with copyWith
          final updatedRequest = request.copyWith(
            status: 1,
            acceptBy: widget.currentFirm?.reference?.id ?? '',
            acceptedTime: DateTime.now(),
          );

          final success = await ref
              .read(walletMutationsProvider.notifier)
              .acceptWithdrawalRequest(
            request: updatedRequest,
            affiliateId: affiliateId,
            currency: widget.currentFirm?.currency ?? 'AED',
          );

          if (success) {
            debugPrint('✅ Request accepted: ${request.amount}');
            showCommonSnackbar(context, 'Request accepted successfully');
          } else {
            showCommonSnackbar(context, 'Failed to accept request');
          }
        } catch (e) {
          debugPrint('❌ Error accepting request: $e');
          showCommonSnackbar(context, 'Failed to accept request');
        }
      },
      'Accept',
    );
  }
  ///Handle Reject Request
  void _handleRejectRequest(WithdrewrequstModel request) {
    showCommonAlertBox(
      context,
      'Are you sure you want to reject this withdrawal request of ${widget.currentFirm?.currency ?? 'AED'} ${request.amount.toInt()}?',
          () async {
        Navigator.pop(context); // Close dialog

        try {
          // ✅ Call with correct parameters (newStatus is int, not model)
          final success = await ref.read(walletMutationsProvider.notifier)
              .rejectWithdrawalRequest(request: request, affiliateId: affiliateId);

          if (success) {
            debugPrint('❌ Request rejected: ${request.amount}');
            showCommonSnackbar(context, 'Request rejected successfully');
          } else {
            showCommonSnackbar(context, 'Failed to reject request');
          }
        } catch (e) {
          debugPrint('❌ Error rejecting request: $e');
          showCommonSnackbar(context, 'Failed to reject request');
        }
      },
      'Reject',
    );
  }

}
