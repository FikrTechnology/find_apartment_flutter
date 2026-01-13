import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

class ImagePickerUtil {
  static final Logger _logger = Logger();
  static final ImagePicker _picker = ImagePicker();

  static Future<(File, String)?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        _logger.i('Image picked from gallery: ${pickedFile.name}');
        return (imageFile, pickedFile.name);
      }
      return null;
    } catch (e) {
      _logger.e('Error picking image from gallery: $e');
      rethrow;
    }
  }

  static Future<(File, String)?> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        _logger.i('Image captured from camera: ${pickedFile.name}');
        return (imageFile, pickedFile.name);
      }
      return null;
    } catch (e) {
      _logger.e('Error capturing image from camera: $e');
      rethrow;
    }
  }

  static Future<String> convertImageToBase64(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);
      _logger.i('Image converted to Base64: ${imageFile.path}');
      return base64String;
    } catch (e) {
      _logger.e('Error converting image to Base64: $e');
      rethrow;
    }
  }

  static String getFileName(File imageFile) {
    return imageFile.path.split('/').last;
  }
}
