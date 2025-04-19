import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class FirebaseUploadService {
  static Future<String> uploadFile(File file, String folder) async {
    try {
      // Validate file existence
      if (!file.existsSync()) {
        throw Exception("Selected file does not exist.");
      }

      final fileName = '${const Uuid().v4()}_${file.path.split('/').last}';
      final ref = FirebaseStorage.instance.ref('$folder/$fileName');

      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      print("✅ File uploaded to: $downloadUrl");
      return downloadUrl;
    } on FirebaseException catch (e) {
      print("❌ FirebaseException: ${e.code} - ${e.message}");
      rethrow;
    } catch (e, stack) {
      print("❌ General upload error: $e");
      print(stack);
      rethrow;
    }
  }
}

Future<String> convertFileToBase64(File file) async {
  final bytes = await file.readAsBytes();
  return base64Encode(bytes);
}
