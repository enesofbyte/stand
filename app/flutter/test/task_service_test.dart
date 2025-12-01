import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:stand/services/task_service.dart';

class FakeVault {
  final Directory dir;
  FakeVault(this.dir);
  Directory get vaultDir => dir;
}

void main() {
  test('TaskService create/list/toggle', () async {
    final tmp = await Directory.systemTemp.createTemp('stand_test');
    final svc = TaskService(tmp);
    await svc.init();

    final t = await svc.createTask(title: 'Test task', description: 'desc');
    expect(t.title, 'Test task');

    final list = await svc.listTasks();
    expect(list.length, 1);

    await svc.toggleComplete(t.id);
    final l2 = await svc.listTasks();
    expect(l2.first.status, 'done');

    await svc.deleteTask(t.id);
    final l3 = await svc.listTasks();
    expect(l3.length, 0);
  });
}
