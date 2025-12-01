import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/vault_service.dart';
import 'services/index_service.dart';
import 'services/ai_service.dart';
import 'services/task_service.dart';
import 'services/habit_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final vaultService = VaultService();
  await vaultService.init();

  final indexService = IndexService();
  await indexService.init(vaultService.vaultDir);
  await indexService.indexAll();

  final aiService = AIService();

  final taskService = TaskService(vaultService.vaultDir);
  await taskService.init();
  final habitService = HabitService(vaultService.vaultDir);
  await habitService.init();

  runApp(MultiProvider(
    providers: [
      Provider<VaultService>.value(value: vaultService),
      Provider<IndexService>.value(value: indexService),
      Provider<AIService>.value(value: aiService),
      Provider<TaskService>.value(value: taskService),
      Provider<HabitService>.value(value: habitService),
    ],
    child: const StandApp(),
  ));
}

class StandApp extends StatelessWidget {
  const StandApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stand — LifeOS Prototype',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}
