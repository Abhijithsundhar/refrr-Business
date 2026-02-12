import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/change-lead-type-sheet.dart';
import 'package:refrr_admin/Core/common/change-sales-person-sheet.dart';
import 'package:refrr_admin/Core/common/chat-screen-support-%20functions.dart';
import 'package:refrr_admin/Core/common/globalVariables.dart';
import 'package:refrr_admin/Core/common/textEditingControllers.dart';
import 'package:refrr_admin/Core/constants/servicelead-color.dart';
import 'package:refrr_admin/Feature/Team/controller/affiliate-controller.dart';
import 'package:refrr_admin/Feature/pipeline/Controller/serviceLead-controllor.dart';
import 'package:refrr_admin/Feature/pipeline/Screens/pipeline/event-shedule-page.dart';
import 'package:refrr_admin/Feature/website/screens/firm-person/firm,person-screen.dart';
import 'package:refrr_admin/core/common/snackbar.dart';
import 'package:refrr_admin/models/add-money-on-lead-model.dart';
import 'package:refrr_admin/models/affiliate-model.dart';
import 'package:refrr_admin/models/chatbox-model.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:refrr_admin/models/serviceLeadModel.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LeadTimelineScreen extends ConsumerStatefulWidget {
  final ServiceLeadModel service;
  final LeadsModel? currentFirm;
  final StatusColors? statuscolor;
  final AffiliateModel? marketer;
  const LeadTimelineScreen({
    super.key,
    required this.service,
    this.currentFirm,
    this.statuscolor,
    required this.marketer,
  });

  @override
  ConsumerState<LeadTimelineScreen> createState() => _LeadTimelineScreenState();
}

class _LeadTimelineScreenState extends ConsumerState<LeadTimelineScreen> {
  late ServiceLeadModel service;
  late LeadsModel? currentFirm;
  late AffiliateModel? marketer;
  String? handlerProfile;

  // ✅ ScrollController and first load flag
  final ScrollController _scrollController = ScrollController();
  bool _isFirstLoad = true;

  // ✅ ADD: Track latest chat list from stream
  List<ChatModel> _latestChatList = [];

  @override
  void initState() {
    super.initState();
    service = widget.service;
    currentFirm = widget.currentFirm;
    marketer = widget.marketer;
    _latestChatList = List<ChatModel>.from(service.chat);

    msgController.addListener(() {
      setState(() {
        hasText = msgController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        if (animated) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final leadhandlerAsync = ref.watch(leadhandlerProvider(service.reference?.id ?? ''));

    leadhandlerAsync.whenData((handlers) {
      final handler = handlers.where((h) => h.currentHandler == true).firstOrNull;
      if (handler?.profile != null && handler!.profile != handlerProfile) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              handlerProfile = handler.profile ?? '';
            });
          }
        });
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: widget.statuscolor?.bigBackground,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        shape: const Border(
          bottom: BorderSide(
            color: Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        leading: Row(
          children: [
            const SizedBox(width: 7),
            GestureDetector(
              onTap: (){
                Navigator.pop(context);
              },
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                    child: Icon(Icons.arrow_back_ios_new,color: Colors.black,))),
            CircleAvatar(
              radius: 18,
              backgroundImage: CachedNetworkImageProvider(service.leadLogo ?? ''),
            ),
          ],
        ),
        leadingWidth: 90,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(service.serviceName,
                style: GoogleFonts.urbanist(
                    fontSize: 18, fontWeight: FontWeight.w600)),
            Text(
              "${service.firmName.toUpperCase()} | ${service.firmLocation}",
              style: GoogleFonts.urbanist(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade600),
            ),
          ],
        ),
          actions: [
            GestureDetector(
              onTapDown: (details) {
                showHideDeleteMenu(
                  context,
                  details.globalPosition,
                  onDelete: () async {
                    // ✅ FIX: Use different variable name to avoid shadowing
                    final updatedService = service.copyWith(delete: true);

                    // ✅ FIX: Wait for update to complete
                    await ref.read(serviceLeadsControllerProvider.notifier)
                        .updateServiceLeads(serviceLeadsModel: updatedService, context: context,);

                    // ✅ FIX: Check if mounted before using context
                    if (mounted) {
                      showCommonSnackbar(context, 'The lead has been deleted.');
                      Navigator.pop(context);
                    }
                  },
                  onHide: () {
                    // Hide logic here
                    final updatedService = service.copyWith(hide: true);
                    ref.read(serviceLeadsControllerProvider.notifier)
                        .updateServiceLeads(serviceLeadsModel: updatedService, context: context,);
                    if (mounted) {
                      showCommonSnackbar(context, 'The lead has been hidden.');
                    }
                  },
                );
              },
              child: Icon(Icons.more_vert),
            ),
            SizedBox(width: width * .02)
          ],
      ),
      body: Stack(
        children: [
          /// 🔹 Entire Page Scrolls Except AppBar & Bottom Input
          Padding(
            padding: EdgeInsets.only(
              bottom: 50,
            ),
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                SizedBox(height: height * .02),

                // ⭐ TOP CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Color(0xFFF3F3F3),
                    border: Border.all(color: Color(0xFFE5E9EB)),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: width * .08,
                        backgroundImage: CachedNetworkImageProvider(service.leadLogo ?? ''),
                      ),
                      SizedBox(height: height * .005),
                      Text(
                        "${service.marketerName} Added a New Lead",
                        style: GoogleFonts.urbanist(
                            fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: height * .007),
                      Text(
                        formatDateTime(service.createTime),
                        style: GoogleFonts.urbanist(
                            fontSize: 13, color: Colors.grey.shade600),
                      ),
                      SizedBox(height: height * .007),
                      GestureDetector(
                        onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) =>
                            FirmDetailsPage(leadId: widget.currentFirm?.reference?.id ?? '',firmName: service.firmName,),));},
                        child: Container(
                          padding:  EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xff6E7C87)),
                            borderRadius: BorderRadius.circular(20),
                            color: Color(0xff6E7C87),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "View Client Details",
                                style: GoogleFonts.urbanist(fontSize: 12,color: Colors.white),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.arrow_forward_ios,
                                  size: 14, color: Colors.white),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                SizedBox(height: height * .03),

                // ⭐ TIMELINE LIST
                Consumer(
                  builder: (context, ref, _) {
                    final chatAsync = ref.watch(chatProvider(service.reference?.id ?? ''));
                    return chatAsync.when(
                      data: (chatList) {
                        // ✅ UPDATE: Store latest chat list from stream
                        _latestChatList = chatList;

                        // Scroll to bottom on first load
                        if (_isFirstLoad && chatList.isNotEmpty) {
                          _isFirstLoad = false;
                          _scrollToBottom(animated: false);
                        }

                        if (chatList.isEmpty) {
                          return Center(
                            child: Text(
                              "No messages yet",
                              style: TextStyle(color: Colors.grey),
                            ),
                          );
                        }

                        final Map<String, List<ChatModel>> grouped = {};
                        for (var msg in chatList) {
                          final dayKey = formatDateTime(
                              msg.dateLabel ?? DateTime.now(),
                              showTime: false);
                          grouped.putIfAbsent(dayKey, () => []);
                          grouped[dayKey]!.add(msg);
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var entry in grouped.entries) ...[
                              dateLabel(entry.key),
                              for (var msg in entry.value) chatItem(msg),
                              SizedBox(height: 20),
                            ],
                          ],
                        );
                      },
                      loading: () => Center(child: CircularProgressIndicator()),
                      error: (e, st) => Text("Error: $e"),
                    );
                  },
                ),
                SizedBox(height: height * .01),
              ],
            ),
          ),

          /// ⭐ FIXED BOTTOM CHAT INPUT
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: bottomChatInput(
                msgController: msgController,
                profileImageUrl: (handlerProfile?.isEmpty ?? true) ? (currentFirm?.logo ?? "") : (handlerProfile ?? ""),
                onRefreshTap: () => showLeadBottomSheet(context, service, currentFirm!, ref),
                onWalletTap: () {
                  showAddPaymentSheet(
                    context,
                    marketer?.name ?? '',
                    amountController,
                    remarksController,
                    widget.currentFirm,
                        () async {
                      print("Clicked Add Money");
                      if (amountController.text.trim().isEmpty) {
                        showCommonSnackbar(context, "Please enter amount");
                        return;
                      }
                      showHireConfirmation(
                        context,
                        'Are you sure want to Add the Payment',
                            () async {
                          print("Confirm clicked");

                          // ✅ FIX: Close dialogs FIRST before async operation
                          int popCount = 0;
                          Navigator.of(context).popUntil((route) {
                            popCount++;
                            return popCount > 1;
                          });

                          try {
                            final newCreditEntry = PaymentModel(
                              amount: int.parse(amountController.text) ?? 0,
                              date: DateTime.now(),
                              added: currentFirm?.reference?.id ?? "",
                              remarks: remarksController.text,
                              receiver: marketer?.id.toString() ?? '',
                            );

                            final updatedCreditAmount = [
                              ...service.creditedAmount,
                              newCreditEntry,
                            ];

                            final newMessage = ChatModel(
                              type: 'transaction',
                              chatterId: currentFirm?.reference?.id ?? '',
                              imageUrl: currentFirm?.logo ?? '',
                              message: remarksController.text,
                              time: DateTime.now(),
                              dateLabel: DateTime.now(),
                              amount: int.tryParse(amountController.text),
                              description: 'has been added to the account.',
                              requiresAction: false,
                              transactionStatus: '',
                            );

                            final updatedChatList = List<ChatModel>.from(_latestChatList);
                            updatedChatList.add(newMessage);

                            final updateMarketer = marketer?.copyWith(
                              totalCredit: marketer!.totalCredit + int.parse(amountController.text),
                              totalBalance: marketer!.totalBalance + int.parse(amountController.text),
                            );

                            final updatedLead = service.copyWith(
                              creditedAmount: updatedCreditAmount,
                              chat: updatedChatList,
                            );

                            // ✅ Store values before clearing
                            final amount = amountController.text;
                            final remarks = remarksController.text;

                            // ✅ Clear controllers immediately
                            amountController.clear();
                            remarksController.clear();

                            print("Controller executed");
                            await ref
                                .read(serviceLeadsControllerProvider.notifier)
                                .updateServiceLeads(
                              context: context,
                              serviceLeadsModel: updatedLead,
                            )
                                .then(
                                  (value) {
                                ref.read(affiliateControllerProvider.notifier).updateAffiliate(
                                  affiliateModel: updateMarketer!,
                                  context: context,
                                );
                              },
                            );

                            // ✅ Show snackbar after operation
                            if (mounted) {
                              showCommonSnackbar(context, "Amount added successfully");
                            }

                            // ✅ Scroll to bottom
                            _scrollToBottom();

                            print("Firebase Write Success");
                          } catch (e) {
                            print("FIREBASE ERROR ===> $e");
                          }
                        },
                      );
                    },
                  );
                },
                onCalendarTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ScheduledEventsPage(
                          service: service,
                          currentFirm: currentFirm,
                          ref: ref,
                        ))),
                onAvatarTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => ChangeSalesPersonSheet(
                        service: service, currentFirm: currentFirm),
                  );
                },
                onSendTap: () {
                  print('send button pressed ..............................');
                  if (msgController.text.trim().isEmpty) return;

                  // 1️⃣ Create new message
                  final newMessage = ChatModel(
                      type: 'simple',
                      chatterId: currentFirm!.reference!.id,
                      imageUrl: currentFirm?.logo ?? '',
                      message: msgController.text.trim(),
                      time: DateTime.now(),
                      dateLabel: DateTime.now(),
                      amount: 0,
                      description: '',
                      requiresAction: false,
                      transactionStatus: '');

                  // ✅ FIX: Use latest chat list from stream instead of service.chat
                  final updatedChatList = List<ChatModel>.from(_latestChatList);
                  updatedChatList.add(newMessage);

                  // 4️⃣ Create updated service model
                  final updatedService = service.copyWith(
                    chat: updatedChatList,
                  );

                  // 5️⃣ Update in Firebase using your controller
                  ref.read(serviceLeadsControllerProvider.notifier).updateServiceLeads(
                      serviceLeadsModel: updatedService, context: context);

                  // 6️⃣ Clear input
                  msgController.clear();
                  _scrollToBottom();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
