import 'dart:convert';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'dart:io' show Directory;

class Task {
  String id;
  String title;
  String? description;
  String status; // todo, in-progress, done
  DateTime? dueDate;
  String? repeatRule;
  int createdAt;
  int updatedAt;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.status = 'todo',
    this.dueDate,
    this.repeatRule,
    int? createdAt,
    int? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch,
        updatedAt = updatedAt ?? DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'status': status,
        'dueDate': dueDate?.toIso8601String(),
        'repeatRule': repeatRule,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  static Task fromJson(Map<String, dynamic> j) => Task(
        id: j['id'],
        title: j['title'],
        description: j['description'],
        status: j['status'] ?? 'todo',
        dueDate: j['dueDate'] == null ? null : DateTime.parse(j['dueDate']),
        repeatRule: j['repeatRule'],
        createdAt: j['createdAt'],
        updatedAt: j['updatedAt'],
      );
}

class TaskService {
  final Directory vaultDir;
  final _uuid = const Uuid();
  late File _file;
  List<Task> _cache = [];

  TaskService(Directory vaultDirectory) : vaultDir = vaultDirectory {
    _file = File('${vaultDir.path}/_tasks.json');
  }

  Future<void> init() async {
    if (!(await _file.exists())) {
      await _file.writeAsString(jsonEncode([]));
    }
    await _load();
  }

  Future<void> _load() async {
    final str = await _file.readAsString();
    final arr = jsonDecode(str) as List<dynamic>;
    _cache = arr.map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Task>> listTasks() async {
    return _cache;
  }

  Future<Task> createTask({required String title, String? description, DateTime? due}) async {
    final t = Task(id: _uuid.v4(), title: title, description: description, dueDate: due);
    _cache.add(t);
    await _persist();
    return t;
  }

  Future<void> updateTask(Task task) async {
    final idx = _cache.indexWhere((t) => t.id == task.id);
    if (idx >= 0) {
      task.updatedAt = DateTime.now().millisecondsSinceEpoch;
      _cache[idx] = task;
      await _persist();
    }
  }

  Future<void> toggleComplete(String id) async {
    final idx = _cache.indexWhere((t) => t.id == id);
    if (idx >= 0) {
      final t = _cache[idx];
      t.status = (t.status == 'done') ? 'todo' : 'done';
      t.updatedAt = DateTime.now().millisecondsSinceEpoch;
      await _persist();
    }
  }

  Future<void> deleteTask(String id) async {
    _cache.removeWhere((t) => t.id == id);
    await _persist();
  }

  Future<void> _persist() async {
    final str = jsonEncode(_cache.map((t) => t.toJson()).toList());
    await _file.writeAsString(str);
  }
}
