import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:refrr_admin/Core/common/image-picker.dart';
import 'package:refrr_admin/Core/common/snackbar.dart';

Future<String?> uploadImage({
  required XFile image,
  required BuildContext context,
}) async {
  try {
    // Read image bytes
    final bytes = await image.readAsBytes();

    // Compress image for faster upload
    final compressedBytes = await _compressImage(
      bytes: bytes,
      fileName: image.name,
    );

    final pickedImage = PickedImage(
      name: image.name,
      bytes: compressedBytes,
    );

    // Upload to Firebase with timeout
    final uploadedUrl = await ImagePickerHelper.uploadOfferImageToFirebase(
      pickedImage,
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw TimeoutException('Upload took too long');
      },
    );

    if (uploadedUrl == null || uploadedUrl.isEmpty) {
      if (context.mounted) {
        showCommonSnackbar(context, 'Image upload failed. Please try again.');
      }
      return null;
    }

    return uploadedUrl;
  } on TimeoutException {
    debugPrint('Image upload timeout');
    if (context.mounted) {
      showCommonSnackbar(context, 'Upload timeout. Please check your connection.');
    }
    return null;
  } catch (e) {
    debugPrint('Image upload error: $e');
    if (context.mounted) {
      showCommonSnackbar(context, 'Something went wrong while uploading image');
    }
    return null;
  }
}

/// Compress image to reduce file size and improve upload speed
Future<Uint8List> _compressImage({
  required Uint8List bytes,
  required String fileName,
  int quality = 85,
  int maxWidth = 1920,
  int maxHeight = 1920,
}) async {
  try {
    // Use flutter_image_compress package
    final compressedBytes = await FlutterImageCompress.compressWithList(
      bytes,
      minWidth: maxWidth,
      minHeight: maxHeight,
      quality: quality,
      format: _getCompressFormat(fileName),
    );

    debugPrint('Original size: ${bytes.length / 1024} KB');
    debugPrint('Compressed size: ${compressedBytes.length / 1024} KB');
    debugPrint('Reduction: ${((1 - compressedBytes.length / bytes.length) * 100).toStringAsFixed(1)}%');

    return Uint8List.fromList(compressedBytes);
  } catch (e) {
    debugPrint('Compression error: $e, using original image');
    return bytes;
  }
}

/// Get appropriate compression format based on file extension
CompressFormat _getCompressFormat(String fileName) {
  final extension = fileName.toLowerCase().split('.').last;
  switch (extension) {
    case 'png':
      return CompressFormat.png;
    case 'heic':
      return CompressFormat.heic;
    case 'webp':
      return CompressFormat.webp;
    default:
      return CompressFormat.jpeg;
  }
}
