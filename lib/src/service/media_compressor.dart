import 'dart:convert';
import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:video_compress/video_compress.dart';

class MediaCompressor {
  /// Compress and convert image to base64
  static Future<String> compressImageToBase64(File file) async {
    try {
      final originalBytes = await file.readAsBytes();
      final image = img.decodeImage(originalBytes);
      if (image == null) throw Exception("Invalid image");

      final resized = img.copyResize(image, width: 600); // Resize for smaller dimension
      final compressedBytes = img.encodeJpg(resized, quality: 60); // Lower quality for size

      print("✅ Image compressed. Size: ${compressedBytes.lengthInBytes / 1024} KB");
      return base64Encode(compressedBytes);
    } catch (e) {
      print("❌ Image compression failed: $e");
      rethrow;
    }
  }

  /// Compress and convert video to base64
  static Future<String> compressVideoToBase64(File file) async {
    try {
      final info = await VideoCompress.compressVideo(
        file.path,
        quality: VideoQuality.LowQuality,
        deleteOrigin: false,
      );

      if (info == null || info.file == null) throw Exception("Video compression failed");

      final compressedBytes = await info.file!.readAsBytes();

      print("✅ Video compressed. Size: ${compressedBytes.length / 1024} KB");
      return base64Encode(compressedBytes);
    } catch (e) {
      print("❌ Video compression failed: $e");
      rethrow;
    }
  }

  /// Optional: clean temp cache
  static Future<void> dispose() async {
    await VideoCompress.deleteAllCache();
  }
}
