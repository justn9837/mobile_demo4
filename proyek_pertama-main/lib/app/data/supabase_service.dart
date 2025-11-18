import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase/supabase.dart';

/// SupabaseService using the pure Dart `supabase` client (no native plugins).
class SupabaseService {
  static SupabaseClient? _client;

  static bool get enabled => _client != null;

  static Future<void> init() async {
    final url = dotenv.env['SUPABASE_URL'];
    final anon = dotenv.env['SUPABASE_ANON_KEY'];
    if (url == null || anon == null || url.isEmpty || anon.isEmpty) {
      _client = null;
      return;
    }
    _client = SupabaseClient(url, anon);
  }

  static SupabaseClient get client {
    if (_client == null) throw StateError('SupabaseService not initialized');
    return _client!;
  }

  static Future<AuthResponse> signUp(String email, String password) async {
    return await client.auth.signUp(email: email, password: password);
  }

  static Future<AuthResponse> signIn(String email, String password) async {
    return await client.auth.signInWithPassword(email: email, password: password);
  }

  static Future<Map<String, dynamic>?> getProfileByUsername(String username) async {
    try {
      final res = await client.from('profiles').select().eq('username', username).maybeSingle();
      if (res == null) return null;
      return Map<String, dynamic>.from(res as Map);
    } catch (_) {
      return null;
    }
  }

  static Future<bool> insertProfile(Map<String, dynamic> profile) async {
    try {
      await client.from('profiles').insert(profile).execute();
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> uploadAvatar(String userId, String filename, Uint8List bytes) async {
    try {
      await client.storage.from('foto_profil').uploadBinary('$userId/$filename', bytes);
      return true;
    } catch (e) {
      debugPrint('uploadAvatar error: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchEntries(String username) async {
    try {
      final res = await client.from('entries').select().eq('username', username).order('timestamp', ascending: true).execute();
      final data = (res as dynamic).data as List?;
      if (data == null) return [];
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<bool> insertEntry(Map<String, dynamic> entry) async {
    try {
      await client.from('entries').insert(entry).execute();
      return true;
    } catch (_) {
      return false;
    }
  }
}
