import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'daily_journal_controller.dart';

class DailyJournalView extends StatelessWidget {
  DailyJournalView({super.key});

  final controller = Get.put(DailyJournalController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Journal')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(controller: controller.noteController, decoration: const InputDecoration(labelText: 'Note')),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: ElevatedButton(onPressed: () => controller.addEntry('happy', 1), child: const Text('Add Happy'))),
                const SizedBox(width: 8),
                Expanded(child: ElevatedButton(onPressed: () => controller.addEntry('sad', 8), child: const Text('Add Stress'))),
              ],
            ),
            const SizedBox(height: 12),
            Obx(() {
              return Expanded(
                child: ListView.builder(
                  itemCount: controller.entries.length,
                  itemBuilder: (context, i) {
                    final e = controller.entries[i];
                    return ListTile(
                      title: Text('${e.mood} - ${e.stressLevel}'),
                      subtitle: Text(e.note ?? ''),
                      trailing: e.pending ? const Text('PENDING') : const Text('SYNCED'),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
