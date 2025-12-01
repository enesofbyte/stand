import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/task_service.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  late TaskService _tasks;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tasks = Provider.of<TaskService>(context);
  }

  Future<void> _createSample() async {
    await _tasks.createTask(title: 'Call client', description: 'Follow up re: contract');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: FutureBuilder<List<Task>>(
        future: _tasks.listTasks(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final list = snapshot.data!;
          if (list.isEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Text('No tasks yet'), ElevatedButton(onPressed: _createSample, child: const Text('Create sample task'))]));
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              final t = list[i];
              return ListTile(
                title: Text(t.title, style: TextStyle(decoration: t.status == 'done' ? TextDecoration.lineThrough : null)),
                subtitle: t.description == null ? null : Text(t.description!),
                trailing: IconButton(
                  icon: Icon(t.status == 'done' ? Icons.check_box : Icons.check_box_outline_blank),
                  onPressed: () async {
                    await _tasks.toggleComplete(t.id);
                    setState(() {});
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final titleController = TextEditingController();
          final descController = TextEditingController();
          final result = await showDialog<bool?>(context: context, builder: (_) => AlertDialog(title: const Text('New task'), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: titleController, decoration: const InputDecoration(hintText: 'Title')), TextField(controller: descController, decoration: const InputDecoration(hintText: 'Description'))]), actions: [TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')), ElevatedButton(onPressed: () async { if (titleController.text.trim().isNotEmpty) { await _tasks.createTask(title: titleController.text.trim(), description: descController.text.trim()); Navigator.of(context).pop(true); } }, child: const Text('Create'))]));
          if (result == true) setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
