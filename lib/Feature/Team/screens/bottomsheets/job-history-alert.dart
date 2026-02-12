 import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/custom-text-field.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';
import 'package:refrr_admin/Core/common/snackbar.dart';
import 'package:refrr_admin/models/job-history-model.dart';
 void showAddJobHistoryDialog(
     BuildContext context, {
       required Function(JobHistory) onAdd,
     }) {
   final roleController = TextEditingController();
   final expController = TextEditingController();
   final industryController = TextEditingController();

   showDialog(
     context: context,
     builder: (_) {
       return Center(
         child: Material(
           color: Colors.transparent,
           child: Container(
             width: width * 0.9,
             padding: EdgeInsets.all(width * 0.05),
             decoration: BoxDecoration(
               color: Colors.white,
               borderRadius: BorderRadius.circular(width * 0.05),
             ),
             child: Column(
               mainAxisSize: MainAxisSize.min,
               children: [
                 Text("Add Job History",
                     style: GoogleFonts.dmSans(
                         fontSize: width * 0.05,
                         fontWeight: FontWeight.bold)),

                 SizedBox(height: width * 0.04),

                 inputField("Role", roleController,TextInputType.text,SizedBox()),
                 SizedBox(height: width * 0.03),
                 inputField("Years of Experience", expController,TextInputType.number,SizedBox()),
                 SizedBox(height: width * 0.03),
                 inputField("Industry", industryController,TextInputType.text,SizedBox()),

                 SizedBox(height: width * 0.05),

                 SizedBox(
                   width: double.infinity,
                   height: width * 0.13,
                   child: ElevatedButton(
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.black,
                     ),
                     onPressed: () {
                       if (roleController.text.isEmpty ||
                           expController.text.isEmpty ||
                           industryController.text.isEmpty) {
                         showCommonSnackbar(context, "Fill all fields");
                         return;
                       }

                       onAdd(
                         JobHistory(
                           role: roleController.text,
                           experience: expController.text,
                           industry: industryController.text,
                         ),
                       );

                       Navigator.pop(context);
                     },
                     child: Text("Add",
                         style: GoogleFonts.dmSans(
                             color: Colors.white,
                             fontSize: width * 0.04)),
                   ),
                 ),
               ],
             ),
           ),
         ),
       );
     },
   );
 }
