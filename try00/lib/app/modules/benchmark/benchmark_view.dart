import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';

class BenchmarkView extends StatefulWidget {
  const BenchmarkView({super.key});

  @override
  State<BenchmarkView> createState() => _BenchmarkViewState();
}

class _BenchmarkViewState extends State<BenchmarkView> {
  Map<String, int> results = {};

  Future<void> runBenchmarks() async {
    final sw = DateTime.now();
    // shared_preferences set/get
    final start1 = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bench_test', 'x');
    prefs.getString('bench_test');
    final ms1 = DateTime.now().difference(start1).inMilliseconds;

    // hive write/read
    final start2 = DateTime.now();
    final box = await Hive.openBox('bench');
    await box.put('k', 'v');
    await box.get('k');
    final ms2 = DateTime.now().difference(start2).inMilliseconds;

    // simple http select (affirmation API) as DB test substitute
    final start3 = DateTime.now();
    final r = await http.get(Uri.parse('https://www.affirmations.dev/'));
    final ms3 = DateTime.now().difference(start3).inMilliseconds;

    setState(() {
      results = {
        'shared_prefs_ms': ms1,
        'hive_ms': ms2,
        'http_ms': ms3,
      };
    });

    await box.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Benchmark')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            ElevatedButton(onPressed: runBenchmarks, child: const Text('Run Benchmarks')),
            const SizedBox(height: 12),
            if (results.isNotEmpty)
              ...results.entries.map((e) => ListTile(title: Text(e.key), trailing: Text('${e.value} ms'))),
          ],
        ),
      ),
    );
  }
}
