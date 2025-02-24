import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:equatable/equatable.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject with EquatableMixin {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String subtitle;

  @HiveField(3)
  DateTime createdAtTime;

  @HiveField(4)
  DateTime createdAtDate;

  @HiveField(5)
  bool isCompleted;

  @HiveField(6)
  final String userId;

  @HiveField(7)
  Priority priority;

  Task({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.createdAtTime,
    required this.createdAtDate,
    required this.isCompleted,
    required this.userId,
    required this.priority,
  });

  factory Task.create({
    required String? title,
    required String? subtitle,
    DateTime? createdAtTime,
    DateTime? createdAtDate,
    required String userId,
    Priority? priority,
  }) =>
      Task(
        id: const Uuid().v1(),
        title: title ?? '',
        subtitle: subtitle ?? '',
        createdAtTime: createdAtTime ?? DateTime.now(),
        createdAtDate: createdAtDate ?? DateTime.now(),
        isCompleted: false,
        userId: userId,
        priority: priority ?? Priority.medium,
      );

  @override
  List<Object> get props => [id, title, subtitle, createdAtTime, createdAtDate, isCompleted, userId, priority];
}

@HiveType(typeId: 1)
enum Priority {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high,
}