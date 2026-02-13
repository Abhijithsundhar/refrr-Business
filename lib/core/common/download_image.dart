import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

Future<void> downloadImageToAppDir(String imageUrl) async {
  try {
    // Get app's document directory
    final dir = await getApplicationDocumentsDirectory();

    // Generate a unique file name
    final filePath = '${dir.path}/creative_${DateTime.now().millisecondsSinceEpoch}.jpg';

    // Download image using Dio
    final response = await Dio().get(
      imageUrl,
      options: Options(responseType: ResponseType.bytes),
    );

    // Save to file
    final file = File(filePath);
    await file.writeAsBytes(response.data);

    print('Image saved at: $filePath');
  } catch (e) {
    print('DOWNLOAD ERROR 👉 $e');
  }
}
