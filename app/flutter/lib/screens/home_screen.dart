import 'package:flutter/material.dart';
import 'vault_screen.dart';
import 'package:provider/provider.dart';
import 'tasks_screen.dart';
import 'habits_screen.dart';
import '../services/vault_service.dart';
import '../services/task_service.dart';
import '../services/habit_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stand — LifeOS')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Welcome to Stand (prototype)', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            const Text('Select your vault to proceed or create a new one.'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const VaultScreen()));
              },
              icon: const Icon(Icons.folder),
              label: const Text('Open Vault Explorer'),
            ),
            const SizedBox(height: 8),
            Row(children: [Expanded(child: ElevatedButton.icon(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TasksScreen())), icon: const Icon(Icons.checklist), label: const Text('Tasks'))), const SizedBox(width: 8), Expanded(child: ElevatedButton.icon(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HabitsScreen())), icon: const Icon(Icons.bolt), label: const Text('Habits')))]),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final vault = Provider.of<VaultService>(context, listen: false);
          final tasks = Provider.of<TaskService>(context, listen: false);
          final habits = Provider.of<HabitService>(context, listen: false);
          final choice = await showModalBottomSheet<String?>(context: context, builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [ListTile(title: const Text('Quick note'), leading: const Icon(Icons.note_add), onTap: () => Navigator.of(context).pop('note')), ListTile(title: const Text('Quick task'), leading: const Icon(Icons.check_box), onTap: () => Navigator.of(context).pop('task')), ListTile(title: const Text('Quick habit'), leading: const Icon(Icons.bolt), onTap: () => Navigator.of(context).pop('habit'))])));
          if (choice == 'note') {
            final name = 'capture-${DateTime.now().millisecondsSinceEpoch}.md';
            await vault.createPage(name, '# Quick capture\n\n');
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => VaultScreen()));
          } else if (choice == 'task') {
            final titleCtrl = TextEditingController();
            final ok = await showDialog<bool?>(context: context, builder: (_) => AlertDialog(title: const Text('Quick task'), content: TextField(controller: titleCtrl, decoration: const InputDecoration(hintText: 'Title')), actions: [TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')), ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Create'))]));
            if (ok == true && titleCtrl.text.trim().isNotEmpty) {
              await tasks.createTask(title: titleCtrl.text.trim());
            }
          } else if (choice == 'habit') {
            final nameCtrl = TextEditingController();
            final freqCtrl = TextEditingController();
            final ok = await showDialog<bool?>(context: context, builder: (_) => AlertDialog(title: const Text('Quick habit'), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: nameCtrl, decoration: const InputDecoration(hintText: 'Habit name')), TextField(controller: freqCtrl, decoration: const InputDecoration(hintText: 'Frequency (daily)'))]), actions: [TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')), ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Create'))]));
            if (ok == true && nameCtrl.text.trim().isNotEmpty) {
              await habits.createHabit(name: nameCtrl.text.trim(), frequency: freqCtrl.text.trim().isEmpty ? 'daily' : freqCtrl.text.trim());
            }
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
