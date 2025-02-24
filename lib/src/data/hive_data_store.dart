import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';

class HiveDataStore {
  static const boxName = "tasksBox";
  late Box<Task> box;

  Future<void> initHive() async {
    if (!Hive.isBoxOpen(boxName)) {
      box = await Hive.openBox<Task>(boxName);
      print('Hive box opened: $boxName');
    } else {
      box = Hive.box<Task>(boxName);
      print('Hive box already open: $boxName');
    }
  }

  Future<void> addTask({required Task task}) async {
    print('Adding task to Hive: ID: ${task.id}, Title: ${task.title}, UserID: ${task.userId}');
    await box.put(task.id, task);
    final addedTask = box.get(task.id);
    print('Task added to Hive: ID: ${addedTask?.id}, Title: ${addedTask?.title}, UserID: ${addedTask?.userId}');
  }

  Future<Task?> getTask({required String id}) async {
    final task = box.get(id);
    print('Getting task from Hive: ID: $id, Found: ${task != null}');
    return task;
  }

  Future<void> updateTask({required Task task}) async {
    print('Before saving to Hive: ID: ${task.id}, Title: ${task.title}, Subtitle: ${task.subtitle}, Priority: ${task.priority}');
    await task.save();
    final savedTask = box.get(task.id);
    print('After saving to Hive: ID: ${savedTask?.id}, Title: ${savedTask?.title}, Subtitle: ${savedTask?.subtitle}, Priority: ${savedTask?.priority}');
  }

  Future<void> deleteTask({required Task task}) async {
    print('Deleting task from Hive: ID: ${task.id}');
    await task.delete();
    print('Task deleted, remaining tasks: ${box.values.length}');
  }

  Future<void> deleteAllTasks({required String userId}) async {
    final tasks = box.values.where((task) => task.userId == userId).toList();
    print('Deleting ${tasks.length} tasks for user: $userId');
    for (var task in tasks) {
      print('Deleting task: ${task.id}');
      await task.delete();
    }
    print('All tasks deleted from Hive, remaining: ${box.values.length}');
  }

  ValueListenable<Box<Task>> listenToTasks({required String userId}) {
    print('Setting up listener for tasks with userId: $userId');
    return box.listenable();
  }

  List<Task> getTasksForUser({required String userId}) {
    final tasks = box.values.where((task) => task.userId == userId).toList();
    print('Getting tasks for user: $userId, Found: ${tasks.length}');
    return tasks;
  }
}