import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../../services/supabase_service.dart';

/// AuthService: handles register/login/logout and profile creation in Supabase.
class AuthService extends GetxService {
  late final SupabaseClient _client;

  AuthService() {
    _client = Get.find<SupabaseService>().client;
  }

  Future<UserModel?> loginWithEmail(String email, String password) async {
    final res = await _client.auth.signInWithPassword(email: email, password: password);
    final user = res.user;
    if (user == null) return null;
    final profile = await _client.from('profiles').select().eq('user_id', user.id).maybeSingle();
    if (profile != null) {
      return UserModel(
        id: profile['id'] as String?,
        username: profile['username'] as String?,
        name: profile['name'] as String?,
        email: profile['email'] as String?,
        avatar: profile['avatar'] as String?,
        role: profile['role'] as String? ?? 'user',
      );
    }
    return UserModel(id: user.id, email: user.email);
  }

  /// Login using username instead of email. Looks up profile to get email.
  Future<UserModel?> loginWithUsername(String username, String password) async {
    final profile = await _client.from('profiles').select().eq('username', username).maybeSingle();
    if (profile == null) return null;
    final email = profile['email'] as String?;
    if (email == null) return null;
    return await loginWithEmail(email, password);
  }

  Future<UserModel?> registerProfile({
    required String email,
    required String password,
    required String username,
    String? name,
    String role = 'user',
  }) async {
    final res = await _client.auth.signUp(email: email, password: password);
    final user = res.user;
    if (user == null) return null;

    final insert = await _client.from('profiles').insert({
      'user_id': user.id,
      'username': username,
      'name': name ?? username,
      'email': email,
      'role': role,
    }).select().maybeSingle();

    return UserModel(
      id: insert['id'] as String?,
      username: insert['username'] as String?,
      name: insert['name'] as String?,
      email: insert['email'] as String?,
      role: insert['role'] as String? ?? 'user',
    );
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }
}
