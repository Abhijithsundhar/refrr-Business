import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/alertBox.dart';
import 'package:refrr_admin/Core/common/custom-appBar.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';
import 'package:refrr_admin/Core/common/snackbar.dart';
import 'package:refrr_admin/Core/constants/color-constnats.dart';
import 'package:refrr_admin/Core/theme/pallet.dart';
import 'package:refrr_admin/Feature/pipeline/Controller/serviceLead-controllor.dart';
import 'package:refrr_admin/Feature/website/controller/firm-controller.dart';
import 'package:refrr_admin/Feature/website/screens/firm-person/addFirm.dart';
import 'package:refrr_admin/models/affiliate-model.dart';
import 'package:refrr_admin/models/firm-model.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:refrr_admin/models/product-model.dart';
import 'package:refrr_admin/models/serviceLeadModel.dart';
import 'package:refrr_admin/models/services-model.dart';

class SelectFirm extends ConsumerStatefulWidget {
  final LeadsModel? lead;
  final AffiliateModel? affiliate;
  final ServiceModel? service;
  final ProductModel? product;

  const SelectFirm({
    super.key,
    required this.lead,
    this.affiliate,
    this.service,
    this.product,
  });

  @override
  ConsumerState<SelectFirm> createState() => _SelectFirmState();
}

class _SelectFirmState extends ConsumerState<SelectFirm> {
  bool isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final leadId = widget.lead?.reference?.id;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'Select Firm'),
      body: Stack(
        children: [
          // Main Content
          Column(
            children: [
              // ✅ Fixed height for list
              Expanded(
                child: _buildFirmsList(leadId),
              ),
              // ✅ Space for button
              SizedBox(height: 80),
            ],
          ),

          // ✅ Bottom Button
          Positioned(
            bottom: 20,
            right: 20,
            child: _buildAddButton(context),
          ),

          // ✅ Loading Overlay
          if (isSubmitting)
            Container(
              color: Colors.black54,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Submitting lead...',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ✅ Build Firms List
  Widget _buildFirmsList(String? leadId) {
    // ✅ Check if leadId is null
    if (leadId == null || leadId.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text(
              'Lead information is missing',
              style: GoogleFonts.dmSans(
                fontSize: width * 0.04,
                color: Colors.red,
              ),
            ),
          ],
        ),
      );
    }

    final firmsAsync = ref.watch(firmsStreamProvider(leadId));

    return firmsAsync.when(
      data: (firms) {
        if (firms.isEmpty) {
          return _buildEmptyState();
        }
        return _buildFirmsListView(firms);
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (e, stack) => _buildErrorState(e.toString()),
    );
  }

  // ✅ Build Firms ListView
  Widget _buildFirmsListView(List<AddFirmModel> firms) {
    return ListView.builder(
      padding: EdgeInsets.all(15),
      itemCount: firms.length,
      itemBuilder: (context, index) {
        final firm = firms[index];
        return GestureDetector(
          onTap: isSubmitting ? null : () => _onFirmTap(firm),
          child: _buildFirmCard(firm, index),
        );
      },
    );
  }

  // ✅ Handle Firm Tap
  void _onFirmTap(AddFirmModel firm) {
    if (!_validateData()) {
      return;
    }

    showCommonAlertBox(context,
      'Please confirm and push the lead to ${widget.lead?.name ??''}?', () => _submitServiceLead(firm),
      'Confirm',
    );
  }

  // ✅ Validate all required data
  bool _validateData() {
    if (widget.lead == null) {
      showCommonSnackbar(context, 'Lead information is missing');
      return false;
    }

    if (widget.lead?.reference?.id == null || widget.lead!.reference!.id.isEmpty) {
      showCommonSnackbar(context, 'Lead reference is missing');
      return false;
    }

    // ✅ Check if either service OR product is provided
    if (widget.service == null && widget.product == null) {
      showCommonSnackbar(context, 'Service or Product information is missing');
      return false;
    }

    return true;
  }

  // ✅ Submit service lead (separated for better error handling)
// ✅ Submit service lead (works for both product and service)
  Future<void> _submitServiceLead(AddFirmModel firm) async {
    if (isSubmitting) return;

    setState(() {
      isSubmitting = true;
    });

    try {
      print('🚀 Starting lead submission...');

      // ✅ Safely get values with null checks
      final leadRefId = widget.lead!.reference!.id;

      // ✅ Determine lead type and get appropriate details
      final bool isProductLead = widget.product != null;

      final String leadTypeName = isProductLead
          ? (widget.product?.name ?? '')
          : (widget.service?.name ?? '');
      final String category = isProductLead
          ? (widget.product?.name ?? '')
          : (widget.service?.name ?? '');

      // ✅ Create ServiceLeadModel with dynamic data
      final serviceLeadModel = ServiceLeadModel(
        marketerId: leadRefId,
        marketerName: widget.lead?.name ?? '',
        marketerLocation: widget.lead?.zone ?? '',

        serviceName: leadTypeName,
        createTime: DateTime.now(),

        leadScore: 0,
        leadName: widget.lead?.name ?? '',
        leadLogo: widget.lead?.logo ?? '',
        leadEmail: widget.lead!.mail??'',
        leadContact: int.parse(widget.lead!.contactNo) ,
        location: widget.lead?.zone??'',

        type: firm.type,
        leadFor: leadRefId,
        firmName: firm.name,
        firmId: firm.reference?.id??'',
        firmLocation: firm.location,
        leadType: 'Cool',
        statusHistory: [
          {
            'date': DateTime.now(),
            'status': 'New Lead',
            'added': widget.lead?.name ?? '',
          },
        ],
        creditedAmount: [],
        leadHandler: [],
        chat: [],
        delete: false,
        hide: false,
        category: ''
      );


      // ✅ Add service lead
      await ref.read(serviceLeadsControllerProvider.notifier).addServiceLeads(
        serviceLeadsModel: serviceLeadModel, context: context,);

      print('✅lead added successfully');

      // ✅ Wait a bit for Firestore to process
      await Future.delayed(Duration(milliseconds: 500));

      // ✅ Navigate back on success
      if (mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pop(true);
        showCommonSnackbar(context, 'lead submitted successfully');
      }
    } catch (e, stackTrace) {
      print('❌ Error submitting lead: $e');
      print('Stack trace: $stackTrace');

      if (mounted) {
        showCommonSnackbar(context, 'Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }
  // ✅ Build Empty State
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business_outlined,
            size: 64,
            color: Pallet.greyColor,
          ),
          SizedBox(height: 16),
          Text(
            'No firms/person listed',
            style: GoogleFonts.dmSans(
              fontSize: width * 0.04,
              color: Pallet.greyColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap "Add New" to create one',
            style: GoogleFonts.dmSans(
              fontSize: width * 0.035,
              color: Pallet.greyColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Build Error State
  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          SizedBox(height: 16),
          Text(
            'Error loading firms',
            style: GoogleFonts.dmSans(
              fontSize: width * 0.04,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              style: GoogleFonts.dmSans(
                fontSize: width * 0.03,
                color: Pallet.greyColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Build Firm Card
  Widget _buildFirmCard(AddFirmModel firm, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Pallet.greyColor.withOpacity(.2), width: 1),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        firm.name.toUpperCase(),
                        style: GoogleFonts.roboto(
                          fontSize: width * .04,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8),
                    // ✅ Show type badge
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: firm.type == 'firm'
                            ? ColorConstants.primaryColor.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        firm.type == 'firm' ? 'FIRM' : 'PERSON',
                        style: GoogleFonts.dmSans(
                          fontSize: width * 0.025,
                          fontWeight: FontWeight.w600,
                          color: firm.type == 'firm'
                              ? ColorConstants.primaryColor
                              : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                if (firm.location.isNotEmpty)
                  Text(
                    firm.location,
                    style: GoogleFonts.roboto(
                      fontSize: width * .03,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[700],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                if (firm.industryType.isNotEmpty) ...[
                  SizedBox(height: 2),
                  Text(
                    firm.industryType,
                    style: GoogleFonts.roboto(
                      fontSize: width * .028,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Build Add Button Widget
  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: isSubmitting
          ? null
          : () async {
        // ✅ Validate before navigation
        if (widget.lead == null) {
          showCommonSnackbar(context, 'Lead information is missing');
          return;
        }

        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddFirmScreen(
              leads: widget.lead,
              affiliate: widget.affiliate,
            ),
          ),
        );

        // ✅ Refresh list if firm was added
        if (result == true && mounted) {
          ref.invalidate(firmsStreamProvider(widget.lead!.reference!.id));
        }
      },
      child: Container(
        height: height * .055,
        width: width * .27,
        decoration: BoxDecoration(
          color: isSubmitting
              ? ColorConstants.primaryColor.withOpacity(0.5)
              : ColorConstants.primaryColor,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 4),
            Text(
              'Add New',
              style: GoogleFonts.dmSans(
                fontSize: width * 0.035,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}