import 'dart:convert';
import 'dart:io' show Directory;
import 'package:uuid/uuid.dart';
import 'vault_service.dart';

class Habit {
  String id;
  String name;
  String frequency; // e.g., 'daily', 'weekly'
  int startDate;
  List<int> logs; // timestamps
  int createdAt;

  Habit({required this.id, required this.name, required this.frequency, int? startDate, List<int>? logs, int? createdAt})
      : startDate = startDate ?? DateTime.now().millisecondsSinceEpoch,
        logs = logs ?? [],
        createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'frequency': frequency,
        'startDate': startDate,
        'logs': logs,
        'createdAt': createdAt,
      };

  static Habit fromJson(Map<String, dynamic> j) => Habit(
        id: j['id'],
        name: j['name'],
        frequency: j['frequency'],
        startDate: j['startDate'],
        logs: List<int>.from(j['logs'] ?? []),
        createdAt: j['createdAt'],
      );
}

class HabitService {
  final Directory vaultDir;
  final _uuid = const Uuid();
  late File _file;
  List<Habit> _cache = [];

  HabitService(Directory vaultDirectory) : vaultDir = vaultDirectory {
    _file = File('${vaultDir.path}/_habits.json');
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
    _cache = arr.map((e) => Habit.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Habit>> listHabits() async {
    return _cache;
  }

  Future<Habit> createHabit({required String name, required String frequency}) async {
    final h = Habit(id: _uuid.v4(), name: name, frequency: frequency);
    _cache.add(h);
    await _persist();
    return h;
  }

  Future<void> logHabit(String id) async {
    final idx = _cache.indexWhere((h) => h.id == id);
    if (idx >= 0) {
      _cache[idx].logs.add(DateTime.now().millisecondsSinceEpoch);
      await _persist();
    }
  }

  Future<void> deleteHabit(String id) async {
    _cache.removeWhere((h) => h.id == id);
    await _persist();
  }

  Future<void> _persist() async {
    final str = jsonEncode(_cache.map((h) => h.toJson()).toList());
    await _file.writeAsString(str);
  }
}
