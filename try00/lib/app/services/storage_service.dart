import 'dart:io';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// StorageService: upload profile photo to Supabase storage and return public URL.
class StorageService extends GetxService {
  late final SupabaseClient _client;

  StorageService() {
    _client = Get.find<SupabaseService>().client;
  }

  /// Uploads [file] to 'foto_profil' bucket as 'avatars/{userId}.png' and returns public URL.
  Future<String?> uploadProfilePhoto(String userId, File file) async {
    final path = 'avatars/$userId.png';
    final bucket = 'foto_profil';
    try {
      await _client.storage.from(bucket).upload(path, file);
      final url = _client.storage.from(bucket).getPublicUrl(path);
      // getPublicUrl returns a String
      return url;
    } catch (e) {
      // log and return null on failure
      print('uploadProfilePhoto error: $e');
      return null;
    }
  }
}
