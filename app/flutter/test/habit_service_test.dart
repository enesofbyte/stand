import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:stand/services/habit_service.dart';

void main() {
  test('HabitService create/log/delete', () async {
    final tmp = await Directory.systemTemp.createTemp('stand_habit_test');
    final svc = HabitService(tmp);
    await svc.init();

    final h = await svc.createHabit(name: 'Test Habit', frequency: 'daily');
    expect(h.name, 'Test Habit');

    await svc.logHabit(h.id);
    final list = await svc.listHabits();
    expect(list.first.logs.isNotEmpty, true);

    await svc.deleteHabit(h.id);
    final list2 = await svc.listHabits();
    expect(list2.length, 0);
  });
}
