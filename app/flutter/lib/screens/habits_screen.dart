import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/habit_service.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  late HabitService _habits;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _habits = Provider.of<HabitService>(context);
  }

  Future<void> _createSample() async {
    await _habits.createHabit(name: 'Daily journaling', frequency: 'daily');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Habits')),
      body: FutureBuilder<List<Habit>>(
        future: _habits.listHabits(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final list = snapshot.data!;
          if (list.isEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Text('No habits yet'), ElevatedButton(onPressed: _createSample, child: const Text('Create sample habit'))]));
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              final h = list[i];
              return ListTile(
                title: Text(h.name),
                subtitle: Text('${h.frequency} · ${h.logs.length} logs'),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () async { await _habits.logHabit(h.id); setState(() {}); }), IconButton(icon: const Icon(Icons.delete), onPressed: () async { await _habits.deleteHabit(h.id); setState(() {}); })]),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final nameController = TextEditingController();
          final freqController = TextEditingController();
          final result = await showDialog<bool?>(context: context, builder: (_) => AlertDialog(title: const Text('New habit'), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: nameController, decoration: const InputDecoration(hintText: 'Name')), TextField(controller: freqController, decoration: const InputDecoration(hintText: 'Frequency (daily/weekly)'))]), actions: [TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')), ElevatedButton(onPressed: () async { if (nameController.text.trim().isNotEmpty) { await _habits.createHabit(name: nameController.text.trim(), frequency: freqController.text.trim().isEmpty ? 'daily' : freqController.text.trim()); Navigator.of(context).pop(true); } }, child: const Text('Create'))]));
          if (result == true) setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
