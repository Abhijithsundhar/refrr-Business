import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';


class PickedImage {
  final Uint8List bytes;
  final String name;

  PickedImage({required this.bytes, required this.name});
}

class ImagePickerHelper {
  static Future<PickedImage?> pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // ✅ Compress image
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        pickedFile.path,
        minWidth: 800,
        minHeight: 800,
        quality: 70,
        format: CompressFormat.jpeg,
      );

      if (compressedBytes != null) {
        return PickedImage(
          bytes: Uint8List.fromList(compressedBytes), // ✅ return compressed
          name: pickedFile.name,
        );
      } else {
        print('Compression failed, falling back to original bytes');
        final originalBytes = await pickedFile.readAsBytes();
        return PickedImage(bytes: originalBytes, name: pickedFile.name);
      }
    }
    return null;
  }

  static Future<String?> uploadImageToFirebase(PickedImage image) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profiles/${DateTime.now().millisecondsSinceEpoch}_${image.name}');

      final uploadTask = await ref.putData(image.bytes);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  static Future<String?> uploadOfferImageToFirebase(PickedImage image) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('offer/${DateTime.now().millisecondsSinceEpoch}_${image.name}');

      final uploadTask = await ref.putData(image.bytes);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}

class ImagePickerHelperForAddSalesPerson {
  static Future<PickedImage?> pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // ✅ Compress image
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        pickedFile.path,
        minWidth: 300,     // lower resolution
        minHeight: 300,    // lower resolution
        quality: 40,       // very low quality
        format: CompressFormat.jpeg,
      );


      if (compressedBytes != null) {
        return PickedImage(
          bytes: Uint8List.fromList(compressedBytes), // ✅ return compressed
          name: pickedFile.name,
        );
      } else {
        print('Compression failed, falling back to original bytes');
        final originalBytes = await pickedFile.readAsBytes();
        return PickedImage(bytes: originalBytes, name: pickedFile.name);
      }
    }
    return null;
  }

  static Future<String?> uploadImageToFirebase(PickedImage image) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('sales-person-profiles/${DateTime.now().millisecondsSinceEpoch}_${image.name}');

      final uploadTask = await ref.putData(image.bytes);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}
