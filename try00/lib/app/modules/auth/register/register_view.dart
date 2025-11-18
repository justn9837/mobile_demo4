import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class RegisterView extends StatelessWidget {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _username = TextEditingController();

  RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final authC = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.mood, size: 120, color: Colors.indigo),
            TextField(controller: _username, decoration: const InputDecoration(labelText: 'Username')),
            TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _password, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => authC.register(_email.text.trim(), _password.text.trim(), _username.text.trim()),
              child: const Text('Register'),
            ),
            TextButton(onPressed: () => Get.back(), child: const Text('Back')),
          ],
        ),
      ),
    );
  }
}
