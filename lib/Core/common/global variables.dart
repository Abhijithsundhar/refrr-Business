

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:refrr_admin/models/admin-model.dart';

///screen size
double width = 0;
double height = 0;

final adminProvider = StateProvider<AdminModel?>((ref) {
  return null;
});

late List<Map<String, dynamic>> contactPersons;

File? pickedImage; // Import dart:io if not already
List<Map<String, dynamic>> pdfs = [];