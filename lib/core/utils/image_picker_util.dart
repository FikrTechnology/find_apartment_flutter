import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
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

      if (pickedFile == null) {
        _logger.i('No image selected from gallery');
        return null;
      }

      _logger.i('Image picked from gallery: ${pickedFile.name}');
      
      // Validate path is accessible
      final imagePath = pickedFile.path;
      if (imagePath.isEmpty) {
        _logger.e('Empty image path returned from gallery');
        return null;
      }

      final imageFile = File(imagePath);
      
      // Don't check exists here - can cause issues on iOS
      // Just return the file object
      return (imageFile, pickedFile.name);
    } on PlatformException catch (e) {
      _logger.e('Platform exception picking image: ${e.message}, Code: ${e.code}');
      return null;
    } catch (e, st) {
      _logger.e('Error picking image from gallery: $e');
      _logger.e('Stacktrace: $st');
      return null;
    }
  }

  static Future<(File, String)?> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        _logger.i('No image captured from camera');
        return null;
      }

      _logger.i('Image captured from camera: ${pickedFile.name}');
      
      // Validate path is accessible
      final imagePath = pickedFile.path;
      if (imagePath.isEmpty) {
        _logger.e('Empty image path returned from camera');
        return null;
      }

      final imageFile = File(imagePath);
      
      // Don't check exists here - can cause issues on iOS
      // Just return the file object
      return (imageFile, pickedFile.name);
    } on PlatformException catch (e) {
      _logger.e('Platform exception capturing image: ${e.message}, Code: ${e.code}');
      return null;
    } catch (e, st) {
      _logger.e('Error capturing image from camera: $e');
      _logger.e('Stacktrace: $st');
      return null;
    }
  }

  static Future<String?> convertImageToBase64(File imageFile) async {
    try {
      _logger.i('Starting Base64 conversion: ${imageFile.path}');
      
      // Try to read bytes - this is the actual operation that matters
      List<int> imageBytes;
      try {
        imageBytes = await imageFile.readAsBytes();
        _logger.i('Successfully read ${imageBytes.length} bytes from image');
      } catch (e) {
        _logger.e('Failed to read image bytes: $e');
        // Try alternative: read from path string
        try {
          imageBytes = File(imageFile.path).readAsBytesSync();
          _logger.i('Read bytes using sync method: ${imageBytes.length} bytes');
        } catch (e2) {
          _logger.e('Sync read also failed: $e2');
          return null;
        }
      }

      // Validate bytes is not empty
      if (imageBytes.isEmpty) {
        _logger.e('Image file is empty');
        return null;
      }

      _logger.i('Image size: ${(imageBytes.length / 1024 / 1024).toStringAsFixed(2)} MB');

      // Encode to base64
      String base64String;
      try {
        base64String = base64Encode(imageBytes);
        _logger.i('Base64 encoding successful. Length: ${base64String.length}');
      } catch (e) {
        _logger.e('Failed to encode to base64: $e');
        return null;
      }

      // Validate base64 string
      if (base64String.isEmpty) {
        _logger.e('Base64 string is empty after encoding');
        return null;
      }

      _logger.i('Image successfully converted to Base64');
      return base64String;
    } catch (e, st) {
      _logger.e('Unexpected error converting image to Base64: $e');
      _logger.e('Stacktrace: $st');
      return null;
    }
  }

  static String getFileName(File imageFile) {
    return imageFile.path.split('/').last;
  }
}
