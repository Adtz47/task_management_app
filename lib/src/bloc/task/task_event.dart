import 'package:equatable/equatable.dart';
import '../../models/task.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();
  @override
  List<Object> get props => [];
}

class LoadTasks extends TaskEvent {}

class AddTask extends TaskEvent {
  final String title;
  final String subtitle;
  final DateTime createdAtTime;
  final DateTime createdAtDate;
  final String userId;
  final Priority? priority; 

  const AddTask(this.title, this.subtitle, this.createdAtTime, this.createdAtDate, this.userId, {this.priority});
  @override
  List<Object> get props => [title, subtitle, createdAtTime, createdAtDate, userId, priority ?? Priority.medium];
}

class UpdateTask extends TaskEvent {
  final Task task;
  const UpdateTask(this.task);
  @override
  List<Object> get props => [task];
}

class ToggleTaskCompletion extends TaskEvent {
  final Task task;
  const ToggleTaskCompletion(this.task);
  @override
  List<Object> get props => [task];
}

class DeleteTask extends TaskEvent {
  final String taskId;
  const DeleteTask(this.taskId);
  @override
  List<Object> get props => [taskId];
}

class DeleteAllTasks extends TaskEvent {}