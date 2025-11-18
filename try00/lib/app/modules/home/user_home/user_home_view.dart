import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserHomeView extends StatelessWidget {
  const UserHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _fetchAffirmation(),
      builder: (context, snap) {
        final affirmation = snap.data ?? 'Keep going — you are doing great!';
        return Scaffold(
          appBar: AppBar(title: const Text('Home')),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.mood, size: 120, color: Colors.indigo),
                const SizedBox(height: 8),
                Text(affirmation, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: () => Get.toNamed('/daily_journal'), child: const Text('Daily Journal')),
                ElevatedButton(onPressed: () => Get.toNamed('/benchmark'), child: const Text('Benchmark')),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<String?> _fetchAffirmation() async {
    try {
      final r = await http.get(Uri.parse('https://www.affirmations.dev/'));
      if (r.statusCode == 200) {
        final json = jsonDecode(r.body) as Map<String, dynamic>;
        return json['affirmation'] as String?;
      }
    } catch (_) {}
    return null;
  }
}
