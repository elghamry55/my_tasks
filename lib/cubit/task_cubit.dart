// task_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/models/data/db_helper.dart';
import '../features/models/model/task_model.dart';
import '../core/notification_helper.dart';
import 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  final DBHelper _db = DBHelper();
  TaskCubit() : super(TaskLoading());

  Future<void> loadTasks() async {
    try {
      emit(TaskLoading());
      final tasks = await _db.getAllTasks();
      emit(TaskSuccess(tasks));
    } catch (e) {
      emit(TaskError('Failed to load tasks'));
    }
  }

  Future<void> addTask(TaskModel task) async {
    try {
      await _db.insertTask(task);
      await NotificationHelper.scheduleNotificationForTask(task);
      await loadTasks();
    } catch (e) {
      emit(TaskError('Failed to add task'));
    }
  }

  Future<void> updateTask(TaskModel task) async {
    try {
      await _db.updateTask(task);
      await NotificationHelper.scheduleNotificationForTask(task);
      await loadTasks();
    } catch (e) {
      emit(TaskError('Failed to update task'));
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      await _db.deleteTask(id);
      await NotificationHelper.cancelNotification(id);
      await loadTasks();
    } catch (e) {
      emit(TaskError('Failed to delete task'));
    }
  }

  Future<void> toggleStatus(TaskModel task) async {
    try {
      task.status = task.status == 0 ? 1 : 0;
      await _db.updateTask(task);
      if (task.status == 1) {
        await NotificationHelper.cancelNotification(task.id!);
      } else {
        await NotificationHelper.scheduleNotificationForTask(task);
      }
      await loadTasks();
    } catch (e) {
      emit(TaskError('Failed to update status'));
    }
  }
}
