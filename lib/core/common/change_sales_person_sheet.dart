import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:refrr_admin/Core/common/snackbar.dart';
import 'package:refrr_admin/core/alert_dailogs/hire_confirmation_alert.dart';
import 'package:refrr_admin/core/common/chat_screen_support_functions.dart';
import 'package:refrr_admin/core/common/global_variables.dart';
import 'package:refrr_admin/core/common/image_picker.dart';
import 'package:refrr_admin/core/common/text_editing_controllers.dart';
import 'package:refrr_admin/core/constants/colorconstnats.dart';
import 'package:refrr_admin/feature/pipeline/controller/sales_person_controller.dart';
import 'package:refrr_admin/feature/pipeline/controller/service_lead_controller.dart';
import 'package:refrr_admin/feature/pipeline/screens/hire-club/hire_club.dart';
import 'package:refrr_admin/models/chatbox_model.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:refrr_admin/models/salesperson_model.dart';
import 'package:refrr_admin/models/serviceLead_model.dart';


///profile change
class ChangeSalesPersonSheet extends StatefulWidget {
  final ServiceLeadModel service;
  final LeadsModel? currentFirm;
  const ChangeSalesPersonSheet({super.key, required this.service, this.currentFirm});

  @override
  State<ChangeSalesPersonSheet> createState() => _ChangeSalesPersonSheetState();
}
class _ChangeSalesPersonSheetState extends State<ChangeSalesPersonSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> slideAnimation;

  int selectedIndex = -1;
  int? tempSelectedIndex;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    slideAnimation = Tween(begin: const Offset(0, 1), end: Offset.zero).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
    );

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: slideAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Change Sales Person",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: CircleAvatar(
                    radius: width * .04,
                    backgroundColor: const Color(0xFFF3F3F3),
                    child: const Icon(Icons.close, size: 18),
                  ),
                ),
              ],
            ),

            SizedBox(height: height * .02),

            Consumer(
              builder: (context, ref, child) {
                final handlerAsync = ref.watch(
                  leadhandlerProvider(widget.service.reference!.id),
                );

                return handlerAsync.when(
                  data: (handlers) {
                    final sortedHandlers = handlers.reversed.toList();

                    // -----------------------------------------------------------
                    // PRESELECT CURRENT HANDLER (VERY IMPORTANT)
                    // -----------------------------------------------------------
                    if (tempSelectedIndex == null) {
                      for (int i = 0; i < sortedHandlers.length; i++) {
                        if (sortedHandlers[i].currentHandler == true) {
                          tempSelectedIndex = i;
                          break;
                        }
                      }
                    }
                    // -----------------------------------------------------------

                    return Column(
                      children: [
                        GridView.count(
                          crossAxisCount: 4,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 0.8,
                          children: [
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (_) => AddSalesPersonAlert(
                                        currentFirm: widget.currentFirm,
                                        service: widget.service,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 58,
                                    height: 58,
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.black, width: 2),
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.person_add_outlined,
                                          size: 24, color: Colors.white),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  "Add New",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                )
                              ],
                            ),

                            ...List.generate(sortedHandlers.length, (index) {
                              final handler = sortedHandlers[index];

                              return Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        tempSelectedIndex = index;
                                      });
                                    },
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Container(
                                          width: 58,
                                          height: 58,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                          ),
                                          child: ClipOval(
                                            child: Image.network(
                                              handler.profile ?? '',
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                              const Icon(Icons.person,
                                                  size: 40,
                                                  color: Colors.grey),
                                            ),
                                          ),
                                        ),

                                        if (tempSelectedIndex == index)
                                          Positioned(
                                            left: 2,
                                            top: 2,
                                            child: Container(
                                              padding:
                                              const EdgeInsets.all(1),
                                              decoration:
                                              const BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.check_circle,
                                                color: Colors.cyan,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    handler.name,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: GestureDetector(
                            onTap: () {
                              if (tempSelectedIndex == null) {
                                showCommonSnackbar(context, "Select a handler first");
                                return;
                              }

                              final selectedHandler = sortedHandlers[tempSelectedIndex!];

                              showHireConfirmation(
                                context,
                                "Do you want to change the salesperson in charge to ${selectedHandler.name}?",
                                    () async {
                                  // Show loading indicator
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (_) => const Center(
                                      child: CircularProgressIndicator(
                                        color: ColorConstants.primaryColor,
                                      ),
                                    ),
                                  );

                                  // Get the original handlers list
                                  final originalHandlers = widget.service.leadHandler;

                                  // Update all handlers: set currentHandler to true for selected, false for others
                                  final updatedHandlers = originalHandlers.map((handler) {
                                    // Compare by leadHandlerId (unique identifier)
                                    bool isNewCurrent = handler.leadHandlerId == selectedHandler.leadHandlerId;

                                    return handler.copyWith(
                                      currentHandler: isNewCurrent,
                                      changedBy: widget.currentFirm?.reference?.id ?? '',
                                      changedTime: DateTime.now(),
                                    );
                                  }).toList();
                                  final newMessage = ChatModel(
                                      type:'sales',
                                      chatterId: widget.currentFirm?.reference!.id ??'',
                                      imageUrl: widget.currentFirm?.logo??'',
                                      message:'The lead has been assigned to ${selectedHandler.name}. ',
                                      time: DateTime.now(),
                                      dateLabel: DateTime.now(),
                                      amount: 0,
                                      description: '',
                                      requiresAction: false,
                                      transactionStatus: ''
                                  );
                                  // 2️⃣ Copy existing chat list
                                  final updatedChatList = List<ChatModel>.from(widget.service.chat??[]);
                                  // 3️⃣ Add new message
                                  updatedChatList.add(newMessage);
                                  // Create updated service with new handlers list
                                  final updatedService = widget.service.copyWith(
                                    leadHandler: updatedHandlers,chat: updatedChatList
                                  );

                                  // Save to database
                                  await ref.read(serviceLeadsControllerProvider.notifier)
                                      .updateServiceLeads(serviceLeadsModel: updatedService, context: context,);
                                  // Close loading dialog
                                  Navigator.pop(context);
                                  // Close bottom sheet
                                  Navigator.pop(context);

                                  showCommonSnackbar(context, "Sales person charge assigned to ${selectedHandler.name}",);
                                },
                              );
                            },
                            child: Container(
                              padding:
                              const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                "Change",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (e, _) => Center(
                    child: Text("Error loading handlers: $e"),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

///add person alert box
class AddSalesPersonAlert extends StatelessWidget {
  final LeadsModel? currentFirm;
  final ServiceLeadModel? service;
  const AddSalesPersonAlert({super.key, this.currentFirm, this.service});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Row: Title + Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Add Sales Person",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                CircleAvatar(
                  radius: width * .04,
                  backgroundColor: const Color(0xFFF3F3F3),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Two Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _optionCard(
                  width: width,
                  icon: Icons.person_add_outlined,
                  title: "From Own team",
                  onTap: () {
                    showAddSalesPersonSheet(context,currentFirm,service);
                  },
                ),
                _optionCard(
                  width: width,
                  icon: Icons.group_add_outlined,
                  title: "From Sales Club",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => HireFromSalesClubPage(),),);
                  },
                ),
              ],
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _optionCard({
    required double width,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width * 0.36,
        padding: const EdgeInsets.symmetric(vertical: 26),
        decoration: BoxDecoration(
          color: Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Color(0xFFE5E9EB)),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: width * .065,
              backgroundColor:Colors.white,
              child: Icon(
                icon,
                size: 23,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

///add sales person
void showAddSalesPersonSheet(BuildContext context, LeadsModel? leadsModel,ServiceLeadModel? service) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return SlideUpAlertBox(currentFirm: leadsModel,service:service);
    },
  );
}
class SlideUpAlertBox extends StatefulWidget {
  final LeadsModel? currentFirm;
  final ServiceLeadModel? service;
  const SlideUpAlertBox( {super.key,this.currentFirm, this.service,});

  @override
  State<SlideUpAlertBox> createState() => _SlideUpAlertBoxState();
}

class _SlideUpAlertBoxState extends State<SlideUpAlertBox> {
  PickedImage? pickedImage;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.4,
        maxChildSize: 0.8,
        builder: (_, controller) {
          return SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: ListView(
                controller: controller,
                padding: EdgeInsets.only(bottom: 40), // 👈 FIX BUTTON CUTTING
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Add Sales Person",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close, size: 20),
                        ),
                      )
                    ],
                  ),

                  SizedBox(height: height*.01),

                  _buildInput("Name",salesPersonName),
                  SizedBox(height: height*.01),

                  _buildInput("Phone Number",salesPersonNumber),
                  SizedBox(height: height*.01),

                  _buildInput("Email",salesPersonEmail),
                  SizedBox(height: height*.01),

                  _buildInput(
                    "Upload Profile",salesPersonProfile,
                    onTap: () async {
                      final img = await ImagePickerHelperForAddSalesPerson.pickImage();
                      if (img != null) {
                        setState(() {
                          pickedImage = img;
                        });
                      }
                    },
                    suffix: Icon(Icons.file_upload_outlined),
                  ),
                  SizedBox(height: height*.015),
                  pickedImage == null?
                  SizedBox(): Container(
                    height: height*.2,
                    // optional
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:  Image.memory(pickedImage!.bytes),
                  ),

                  SizedBox(height: height*.03),

                  // Add button
                  Consumer(
                    builder: (context, ref, child) {
                      return GestureDetector(
                        onTap: () async {
                          showHireConfirmation(context, 'Are you sure you want to Add this sales person?', () async {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => const Center(child: CircularProgressIndicator(color: ColorConstants.primaryColor,)),
                            );
                            String? profileUrl;
                            if (pickedImage != null) {
                              profileUrl = await ImagePickerHelper.uploadImageToFirebase(pickedImage!);
                            }
                            final SalesPersonModel salesPerson = SalesPersonModel(name: salesPersonName.text, phoneNumber: salesPersonNumber.text,
                                addedBy: widget.currentFirm?.reference?.id ??'', profile: profileUrl ??'', email: salesPersonEmail.text,
                                firmName: widget.currentFirm?.name??'', createdAt: DateTime.now(),
                                changedBy: widget.currentFirm?.reference?.id ??'', changedTime:  DateTime.now(), currentHandler: false);

                            ref.read(salesPersonControllerProvider.notifier).addSalesPerson(salesPerson: salesPerson, context: context)
                                .then((savedPerson) {
                              if (savedPerson == null) return;

                              final newMessage = ChatModel(
                                  type:'changeSalesPerson',
                                  chatterId: widget.currentFirm!.reference!.id,
                                  imageUrl:  widget.currentFirm?.logo??'',
                                  message:'the lead has been assigned to ${savedPerson.name}',
                                  time: DateTime.now(),
                                  dateLabel: DateTime.now(),
                                  amount: 0,
                                  description: '.',
                                  requiresAction: false,
                                  transactionStatus: ''
                              );
                              // 2️⃣ Copy existing chat list
                              final updatedChatList = List<ChatModel>.from(widget.service!.chat);
                              // 3️⃣ Add new message
                              updatedChatList.add(newMessage);
                              final updatedHandlers = List<SalesPersonModel>.from(widget.service!.leadHandler);
                              updatedHandlers.add(savedPerson);

                              final handler = widget.service?.copyWith(leadHandler: updatedHandlers,chat: updatedChatList);
                              ref.read(serviceLeadsControllerProvider.notifier)
                                  .updateServiceLeads(serviceLeadsModel: handler!, context: context);
                              salesPersonEmail.clear();
                              salesPersonNumber.clear();
                              salesPersonName.clear();
                              profileUrl =='';
                              Navigator.pop(context);
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },);

                          });
                        },
                        child: Container(
                          height: 55,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Add",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInput(String hint,TextEditingController controller,{VoidCallback? onTap,Widget? suffix}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Color(0xFFE5E9EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller:controller,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
              ),
            ),
          ),
          if (suffix != null) GestureDetector(onTap: onTap, child: suffix)
        ],
      ),
    );
  }
}
