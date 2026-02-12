import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';

Future<void> shareImageFromUrl(String imageUrl) async {
  try {
    final response = await http.get(Uri.parse(imageUrl));

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/creative.jpg');

    await file.writeAsBytes(response.bodyBytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Check out this creative',
    );
  } catch (e) {
    debugPrint('Share error: $e');
  }
}
