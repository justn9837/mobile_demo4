import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class LoginView extends StatelessWidget {
  final _email = TextEditingController();
  final _password = TextEditingController();

  LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final authC = Get.put(AuthController());
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.mood, size: 120, color: Colors.indigo),
            TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _password, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => authC.login(_email.text.trim(), _password.text.trim()),
              child: const Text('Login'),
            ),
            TextButton(onPressed: () => Get.toNamed('/register'), child: const Text('Register')),
          ],
        ),
      ),
    );
  }
}
