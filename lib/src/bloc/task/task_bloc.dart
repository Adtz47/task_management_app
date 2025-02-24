import 'package:flutter_bloc/flutter_bloc.dart';
import 'task_event.dart';
import 'task_state.dart';
import '../../data/hive_data_store.dart';
import '../../models/task.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final HiveDataStore _hiveDataStore;
  final String userId;

  TaskBloc(this._hiveDataStore, this.userId) : super(TaskInitial()) {
    print('TaskBloc initialized with userId: $userId');
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<ToggleTaskCompletion>(_onToggleTaskCompletion);
    on<DeleteTask>(_onDeleteTask);
    on<DeleteAllTasks>(_onDeleteAllTasks);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    print('Loading tasks for user: $userId');
    emit(TaskLoading());
    try {
      final tasks = List<Task>.from(_hiveDataStore.getTasksForUser(userId: userId));
      print('Fetched ${tasks.length} tasks from Hive');
      tasks.sort((a, b) {
        final priorityComparison = b.priority.index.compareTo(a.priority.index);
        if (priorityComparison != 0) return priorityComparison;
        return a.createdAtDate.compareTo(b.createdAtDate);
      });
      print('Tasks loaded: ${tasks.length}, Tasks: ${tasks.map((t) => "${t.id}: ${t.title} (Priority: ${t.priority})").toList()}');
      emit(TaskLoaded(tasks));
      _hiveDataStore.listenToTasks(userId: userId).addListener(() {
        final updatedTasks = List<Task>.from(_hiveDataStore.getTasksForUser(userId: userId));
        print('Listener triggered, fetched ${updatedTasks.length} tasks');
        updatedTasks.sort((a, b) {
          final priorityComparison = b.priority.index.compareTo(a.priority.index);
          if (priorityComparison != 0) return priorityComparison;
          return a.createdAtDate.compareTo(b.createdAtDate);
        });
        add(LoadTasks());
      });
    } catch (e) {
      print('Error loading tasks: $e');
      emit(TaskError('Failed to load tasks: $e'));
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    print('Handling AddTask: Title: ${event.title}, Subtitle: ${event.subtitle}, Priority: ${event.priority}, UserID: ${event.userId}');
    try {
      final task = Task.create(
        title: event.title,
        subtitle: event.subtitle,
        createdAtTime: event.createdAtTime,
        createdAtDate: event.createdAtDate,
        userId: event.userId,
        priority: event.priority,
      );
      print('Task created: ID: ${task.id}, Title: ${task.title}, UserID: ${task.userId}');
      await _hiveDataStore.addTask(task: task);
      print('Task added to Hive: ${task.id}');
      add(LoadTasks());
    } catch (e) {
      print('Error adding task: $e');
      emit(TaskError('Failed to add task: $e'));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    print('Handling UpdateTask: ID: ${event.task.id}, Title: ${event.task.title}, Subtitle: ${event.task.subtitle}, Priority: ${event.task.priority}');
    try {
      await _hiveDataStore.updateTask(task: event.task);
      print('Task updated in Hive: ID: ${event.task.id}, Title: ${event.task.title}, Subtitle: ${event.task.subtitle}, Priority: ${event.task.priority}');
      add(LoadTasks());
    } catch (e) {
      print('Error updating task: $e');
      emit(TaskError('Failed to update task: $e'));
    }
  }

  Future<void> _onToggleTaskCompletion(ToggleTaskCompletion event, Emitter<TaskState> emit) async {
    print('Toggling completion for task: ${event.task.id}');
    try {
      event.task.isCompleted = !event.task.isCompleted;
      await _hiveDataStore.updateTask(task: event.task);
      add(LoadTasks());
    } catch (e) {
      print('Error toggling task completion: $e');
      emit(TaskError('Failed to toggle task completion: $e'));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    print('Handling DeleteTask for task: ${event.taskId}');
    try {
      final task = await _hiveDataStore.getTask(id: event.taskId);
      if (task != null) {
        await _hiveDataStore.deleteTask(task: task);
        print('Task deleted from Hive: ${event.taskId}');
        add(LoadTasks());
      } else {
        print('Task not found: ${event.taskId}');
      }
    } catch (e) {
      print('Error deleting task: $e');
      emit(TaskError('Failed to delete task: $e'));
    }
  }

  Future<void> _onDeleteAllTasks(DeleteAllTasks event, Emitter<TaskState> emit) async {
    print('Handling DeleteAllTasks');
    try {
      await _hiveDataStore.deleteAllTasks(userId: userId);
      print('All tasks deleted for user: $userId');
      add(LoadTasks());
    } catch (e) {
      print('Error deleting all tasks: $e');
      emit(TaskError('Failed to delete all tasks: $e'));
    }
  }
}