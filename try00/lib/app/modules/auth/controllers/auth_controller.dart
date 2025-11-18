import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/providers/auth_service.dart';
import '../../../data/models/user_model.dart';

class AuthController extends GetxController {
  final _auth = AuthService();
  final currentUser = Rxn<UserModel>();

  Future<void> login(String email, String password) async {
    // allow username or email login: if contains @ treat as email
    UserModel? user;
    if (email.contains('@')) {
      user = await _auth.loginWithEmail(email, password);
    } else {
      user = await _auth.loginWithUsername(email, password);
    }
    currentUser.value = user;
    if (user != null) {
      // save last username/email
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastUsername', email);

      if (user.role == 'psychologist') {
        Get.offAllNamed('/dosen_home');
      } else {
        Get.offAllNamed('/user_home');
      }
    }
  }

  Future<void> register(String email, String password, String username, {String role = 'user'}) async {
    final user = await _auth.registerProfile(email: email, password: password, username: username, role: role);
    currentUser.value = user;
    if (user != null) {
      if (user.role == 'psychologist') {
        Get.offAllNamed('/dosen_home');
      } else {
        Get.offAllNamed('/user_home');
      }
    }
  }

  Future<void> logout() async {
    await _auth.logout();
    currentUser.value = null;
    Get.offAllNamed('/login');
  }
}
