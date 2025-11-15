import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/dateformat.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';
import 'package:refrr_admin/Core/constants/homepage-functions.dart';
import 'package:refrr_admin/Feature/Funnel/Controller/serviceLead-controllor.dart';
import 'package:refrr_admin/Feature/Login/Screens/home.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:refrr_admin/models/serviceLeadModel.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PipeLineInnerPage extends ConsumerStatefulWidget  {
  final ServiceLeadModel service;
  final LeadsModel? currentFirm;
  const PipeLineInnerPage( {super.key, required this.service,this.currentFirm,});

  @override
  ConsumerState<PipeLineInnerPage> createState() => _PipeLineInnerPageState();
}

class _PipeLineInnerPageState extends ConsumerState<PipeLineInnerPage> {
  Future<void> _creditMoney(ServiceLeadModel lead) async {
    final TextEditingController amountController = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text("Add Money"),
          content: TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "Enter amount",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext, rootNavigator: true).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = amountController.text.trim();
                if (amount.isEmpty) return;

                // Show loader
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(child: CircularProgressIndicator()),
                );

                try {
                  final newCreditEntry = {
                    "amount": int.parse(amount),
                    "date": Timestamp.now(),
                    'added': lead.marketerName ?? ''
                  };

                  final updatedCreditAmount = [...lead.creditedAmount, newCreditEntry];

                  final updatedLead = lead.copyWith(creditedAmount: updatedCreditAmount);

                  await ref.read(serviceLeadsControllerProvider.notifier)
                      .updateServiceLeads(
                    context: context,
                    serviceLeadsModel: updatedLead,
                  );

                  // ✅ Close loader
                  Navigator.of(context, rootNavigator: true).pop();

// ✅ Close dialog
                  Navigator.of(dialogContext, rootNavigator: true).pop();

// 🛑 DO NOT PUSH HERE DIRECTLY
// ✅ Push after frame to avoid navigator lock
                  Future.microtask(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HomeScreen(lead: widget.currentFirm,index:0),
                      ),
                    );
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Amount added successfully",style: TextStyle(color: Colors.black),),
                      backgroundColor: Colors.white,
                    ),
                  );
                } catch (e) {
                  Navigator.of(context, rootNavigator: true).pop(); // close loader

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Failed: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateStatus(ServiceLeadModel lead) async {
    if (!mounted) return;
    final String? status = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title & Close
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Lead status',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(width: width * .04),
                  InkWell(
                    onTap: () async {
                      Navigator.of(bottomSheetContext).pop();
                      await _creditMoney(lead);
                    },
                    child: Center(
                      child: Text(
                        ' + Add money',
                        style: GoogleFonts.roboto(
                          color: Colors.blue,
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.blue,
                          decorationThickness: 1,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (Navigator.of(bottomSheetContext).canPop()) {
                        Navigator.of(bottomSheetContext).pop();
                      }
                    },
                    child: const Icon(Icons.close, size: 24),
                  ),
                ],
              ),
              SizedBox(height: height * .05),

              // Status chips
              Center(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: statusOptions.map((s) {
                    return GestureDetector(
                      onTap: () {
                        if (Navigator.of(bottomSheetContext).canPop()) {
                          Navigator.of(bottomSheetContext).pop(s);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 18),
                        decoration: BoxDecoration(
                          color: chipBackground(s),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: chipAccent(s).withOpacity(0.25),
                          ),
                        ),
                        child: Text(
                          s,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF5E5E5E),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );

    if (!mounted) return;
    if (status == null) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final newHistoryEntry = {
        "status": status,
        "date": Timestamp.now(),
        'added' :lead.marketerName ??''
      };

      final updatedHistory = [...lead.statusHistory, newHistoryEntry];

      final updatedLead = lead.copyWith(
        statusHistory: updatedHistory,
      );

      await ref
          .read(serviceLeadsControllerProvider.notifier)
          .updateServiceLeads(
        context: context,
        serviceLeadsModel: updatedLead,
      );

      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to $status'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      print('Error updating status: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFFF5FAFF),
        elevation: 0,
        leading: IconButton(
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {Navigator.pop(context);},
        ),
        title:  Text('Lead Track',
          style: GoogleFonts.roboto(
            color: Colors.black,
            fontSize: width*.05,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Color(0xFFF5FAFF),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Company Header
                  Container(
                    padding:  EdgeInsets.only(left: width*.05),
                    child: Row(
                      children: [
                        Container(
                          width: width*.25,
                          height: height*.1,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Image.asset('assets/image.png',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.service.serviceName,
                              // 'Website Development',
                              style: GoogleFonts.roboto(
                                color: Color(0xFF545454),
                                fontSize: width*.045,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text( DateFormat('dd/MM/yyyy').format(widget.service.createTime),

                              style: GoogleFonts.roboto(
                                color: Color(0xFF545454),
                                fontSize: width*.035,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Website Development Card
                  Padding(
                    padding:  EdgeInsets.only(left: width*.09,top: height*.001),
                    child:
                        Row(
                          children: [
                            Column(children: [
                              Text(
                                widget.service.marketerName,
                                style: GoogleFonts.roboto(
                                  fontSize: width*.045,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF2A2A2A)
                                  ,
                                ),
                              ),
                              Text(
                                  widget.service.location,
                                  style: GoogleFonts.roboto(
                                    fontSize: width*.03,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF545454)
                                    ,
                                  )),
                              SizedBox(height: height*.02,)
                            ],),

                            Padding(
                              padding:  EdgeInsets.only(left: width*.41),
                              child: GestureDetector(
                                onTap: (){
                                  _creditMoney(widget.service);
                                },
                                child: Container(
                                  width: width*.3,
                                  height: height*.05,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Center(
                                    child:  Text(
                                      'Add money',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Prospect Details Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Prospect Details',
                    style: GoogleFonts.roboto(
                      fontSize: width*.052,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child:  Text(
                      'View profile',
                      style: GoogleFonts.roboto(
                        fontSize: width*.032,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0067B0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: height*.01),

            // Details List
            _buildDetailRow('Name', widget.service.leadName),
            _buildDetailRow('Location', widget.service.location),
            _buildDetailRow('Phone No', widget.service.leadContact != 0 ? '+91 ${widget.service.leadContact}' : 'Not provided',),
            _buildDetailRow('Email ID', widget.service.leadEmail.isNotEmpty ? widget.service.leadEmail : 'Not provided',),

            const SizedBox(height: 24),

            // Lead Story Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Lead Story',
                    style: GoogleFonts.roboto(
                      fontSize: width*.052,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => updateStatus(widget.service),
                    child: Container(
                      width: width*.3,
                      height: height*.05,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child:  Text(
                          'Update',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: height*.04),

            // Lead Story Timeline
    //     Color(0xFFE8FFF3)),
    // _buildTimelineItem('23-07-2025', 'Invoice raised', 'Kavya', Color(0x12D87912)),
    // _buildTimelineItem('24-06-2025', 'Proposal sent', 'Abhijith', Color(0x12D87912)),
    // _buildTimelineItem('18-05-2025', 'Contacted', 'Vishnu', Color(0x12D87912)),
    // _buildTimelineItem('30-04-2025', 'New lead', 'Arjun', Color(0xFFF2FFF9),

            Column(
              children: List.generate(widget.service.statusHistory.length, (index) {
                final item = widget.service.statusHistory[index];
                bool isLast = index == widget.service.statusHistory.length - 1;

                // ✅ First & Last -> Color A | Middle -> Color B
                Color bgColor;
                if (index == 0 || index == widget.service.statusHistory.length - 1) {
                  bgColor = Color(0xFFE8FFF3); // First & Last item color
                } else {
                  bgColor = Color(0x12D87912); // Middle items color
                }

                return _buildTimelineItem(
                  formatDate(item['date']),
                  item['status'] ?? '',
                  item['added'] ?? '',
                  bgColor,        // ✅ apply bgColor here
                  isLast: isLast,
                );
              }),
            ),

            const SizedBox(height: 24),

            /// Lead Handler Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Lead Manager',
                style: GoogleFonts.roboto(
                  fontSize: width*.052,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// Lead Handler Person
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 29,
                        backgroundColor: Color(0xFFC1C1C1),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.grey.shade300,
                          child: Image.asset('assets/image 115.png'),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text('Kavya P J', style: GoogleFonts.roboto(
                        fontSize: width*.038,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      ),
                    ],
                  ),
                  SizedBox(width: width*.02,),
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 29,
                         backgroundColor: Color(0xFFC1C1C1),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.grey.shade300,
                          child:Icon(Icons.add,color: Color(0xFFC1C1C1),),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text('Kavya P J', style: GoogleFonts.roboto(
                        fontSize: width*.038,
                        fontWeight: FontWeight.w500,
                        color: Colors.transparent,
                      ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style:  GoogleFonts.roboto(
                fontSize: width*.036,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          Text(':',
            style: GoogleFonts.roboto(
              fontSize: width*.04,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.roboto(
                fontSize: width*.038,
                fontWeight: FontWeight.w400,
                color: Color(0xFF2E2E2E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String date, String status, String handler,Color bgColor, {bool isLast = false,}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            height: height*.065,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: bgColor,
              // borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(date,
                  style: GoogleFonts.roboto(
                    fontSize: width*.036,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF757D83),
                  ),
                ),
                Text(
                  status,
                  style: GoogleFonts.roboto(
                    fontSize: width*.036,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF757D83),
                  ),
                ),
                Text(handler,
                  style: GoogleFonts.roboto(
                    fontSize: width*.036,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF757D83),
                  ),
                ),
              ],
            ),
          ),
          if (!isLast)
            Divider(
              color: Colors.grey.shade300,
              thickness: 1,
              height: 1,
            ),
        ],
      ),
    );
  }
}
