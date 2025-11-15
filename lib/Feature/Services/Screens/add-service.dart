import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';
import 'package:refrr_admin/Feature/Login/Controller/lead-controllor.dart';
import 'package:refrr_admin/models/firm-model.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:refrr_admin/models/services-model.dart';

class AddNewServicePage extends ConsumerStatefulWidget {
  final LeadsModel? currentFirm;
  const AddNewServicePage({ super.key, this.currentFirm,});

  @override
  ConsumerState<AddNewServicePage> createState() => _AddNewServicePageState();
}

class _AddNewServicePageState extends ConsumerState<AddNewServicePage> {
  final _serviceNameCtrl = TextEditingController();
  final _minPriceCtrl = TextEditingController();
  final _maxPriceCtrl = TextEditingController();
  final _commissionCtrl = TextEditingController();

  final _picker = ImagePicker();
  XFile? _image;

  final List<String> statusOptions = const [
    'New Lead',
    'Contacted',
    'Interested',
    'Follow-Up-Needed',
    'Proposal Sent',
    'Negotiation',
    'Converted',
    'Invoice Raised',
    'Work in Progress',
    'Completed',
    'Not Qualified',
    'Lost',
  ];
  String? _selectedCommissionFor = 'Converted';

  static const double kFieldHeight = 44;
  bool _saving = false;

  @override
  void dispose() {
    _serviceNameCtrl.dispose();
    _minPriceCtrl.dispose();
    _maxPriceCtrl.dispose();
    _commissionCtrl.dispose();
    super.dispose();
  }
  Future<void> _pickImage() async {
    final res = await showModalBottomSheet<XFile?>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Gallery'),
                onTap: () async {
                  final x = await _picker.pickImage(source: ImageSource.gallery);
                  if (!mounted) return;
                  Navigator.pop(context, x);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Camera'),
                onTap: () async {
                  final x = await _picker.pickImage(source: ImageSource.camera);
                  if (!mounted) return;
                  Navigator.pop(context, x);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (res != null) {
      setState(() => _image = res);
    }
  }

  Future<void> _onAdd() async {
    if (_serviceNameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter service name')),
      );
      return;
    }

    if (widget.currentFirm == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No firm data available')),
      );
      return;
    }
    print('00000000000000000');
    print(widget.currentFirm);
    print(_serviceNameCtrl);
    print('00000000000000000');
    setState(() => _saving = true);

    try {
      final currentFirm = widget.currentFirm!;
      String imageUrl = '';
      if (_image != null) {
        // 🔹 Replace this with your actual upload logic (Firebase Storage)
        imageUrl = _image!.path;
      }

      final newService = ServiceModel(
        image: imageUrl,
        name: _serviceNameCtrl.text.trim(),
        startingPrice: int.tryParse(_minPriceCtrl.text.trim()) ?? 0,
        endingPrice: int.tryParse(_maxPriceCtrl.text.trim()) ?? 0,
        commission: int.tryParse(_commissionCtrl.text.trim()) ?? 0,
        commissionFor: _selectedCommissionFor ?? 'Converted',
        leadsGiven: 0,
        createTime: DateTime.now(),
        delete: false,
      );
      print('11111111111111');
      print(newService);
      print(imageUrl);
      print('1111111');

      // 🔹 Get current services or create a new empty list
      final List<ServiceModel> currentServices =
      List<ServiceModel>.from(currentFirm.services);

      // 🔹 Add new service
      currentServices.add(newService);

      // 🔹 Copy the firm with the updated service list
      final updatedFirm = currentFirm.copyWith(services: currentServices);

      // 🔹 Update in Firestore via controller
      await ref
          .read(leadControllerProvider.notifier)
          .updateLead(leadModel: updatedFirm, context: context);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Service added successfully'),
          backgroundColor: Colors.green,
        ),
      );

      if (Navigator.canPop(context)) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add service: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  InputDecoration _decor({
    String? hint,
    Widget? suffix,
    Widget? suffixIcon,
    double vPad = 8,
    double hPad = 12,
  }) {
    return InputDecoration(
      isDense: true,
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF3F3F3),
      contentPadding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      suffix: suffix,
      suffixIcon: suffixIcon,
      suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: height * .01, left: width * .017),
      child: Text(
        text,
        style: GoogleFonts.roboto(
          fontSize: width * .03,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF575757),
        ),
      ),
    );
  }

  Widget _amountField(TextEditingController ctrl, {String? hint}) {
    return SizedBox(
      height: kFieldHeight,
      child: TextField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(fontSize: 14),
        decoration: _decor(
          hint: hint ?? '',
          vPad: 8,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: false,
      ),
      // Removed bottomNavigationBar; button is now in the scrollable content
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(right: width * .05, left: width * .05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Heading
              Padding(
                padding: EdgeInsets.only(left: width * .017),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add new service',
                      style: GoogleFonts.roboto(
                        fontSize: width * .04,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: mq.size.height * .02),
              _label('Service Name'),
              SizedBox(
                height: kFieldHeight,
                child: TextField(
                  controller: _serviceNameCtrl,
                  style: const TextStyle(fontSize: 14),
                  decoration: _decor(hint: '', vPad: 8),
                ),
              ),
              SizedBox(height: mq.size.height * .02),
              _label('Add Image'),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 170,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F3F3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: _image == null
                      ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 44,
                          color: Colors.black54,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap to add image',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(_image!.path),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
              ),
              SizedBox(height: mq.size.height * .02),
              _label('Range (AED)'),
              Row(
                children: [
                  Expanded(child: _amountField(_minPriceCtrl, hint: '')),
                  SizedBox(width: width * .02),
                  const Text('to', style: TextStyle(color: Colors.black54)),
                  SizedBox(width: width * .02),
                  Expanded(child: _amountField(_maxPriceCtrl, hint: '')),
                ],
              ),
              SizedBox(height: mq.size.height * .02),
              _label('Commission for'),
              SizedBox(
                height: kFieldHeight,
                child: DropdownButtonFormField<String>(
                  value: _selectedCommissionFor,
                  items: statusOptions
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCommissionFor = v),
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                  iconSize: 20,
                  decoration: _decor(hint: 'Select status', vPad: 8),
                ),
              ),
              SizedBox(height: mq.size.height * .02),

              _label('Commission'),
              SizedBox(
                height: kFieldHeight,
                child: TextField(
                  controller: _commissionCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 14),
                  decoration: _decor(
                    hint: '',
                    vPad: 8,
                    suffix: const Text(
                      '%',
                      style: TextStyle(
                        color: Color(0xFF1DB954),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: height * .04),
              // Moved button here so it sits below the commission fields and scrolls with the page
              SafeArea(
                top: false,
                minimum: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: height*.06,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _saving ? null : _onAdd,
                    child: _saving
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                        : const Text(
                      'Add',
                      style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}