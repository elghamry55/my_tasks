
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

  Future<bool> addTask(TaskModel task) async {
    try {
      final id = await _db.insertTask(task);

      final savedTask = TaskModel(
        id: id,
        title: task.title,
        description: task.description,
        dueDate: task.dueDate,
        status: task.status,
      );

      await NotificationHelper.scheduleNotificationForTask(
        savedTask,
      );

      await loadTasks();

      return state is TaskSuccess;
    } catch (e) {
      emit(TaskError('Failed to add task'));
      return false;
    }
  }

  Future<bool> updateTask(TaskModel task) async {
    try {
      if (task.id == null) return false;

      await _db.updateTask(task);

      await NotificationHelper.cancelNotification(task.id!);

      if (task.status == 0) {
        await NotificationHelper.scheduleNotificationForTask(task);
      }

      await loadTasks();

      return state is TaskSuccess;
    } catch (e) {
      emit(TaskError('Failed to update task'));
      return false;
    }
  }

  Future<bool> deleteTask(int id) async {
    try {
      await _db.deleteTask(id);

      await NotificationHelper.cancelNotification(id);

      await loadTasks();

      return state is TaskSuccess;
    } catch (e) {
      emit(TaskError('Failed to delete task'));
      return false;
    }
  }

  Future<bool> toggleStatus(TaskModel task) async {
    try {
      if (task.id == null) return false;

      final updatedTask = TaskModel(
        id: task.id,
        title: task.title,
        description: task.description,
        dueDate: task.dueDate,
        status: task.status == 0 ? 1 : 0,
      );

      await _db.updateTask(updatedTask);

      await NotificationHelper.cancelNotification(task.id!);

      if (updatedTask.status == 0) {
        await NotificationHelper.scheduleNotificationForTask(
          updatedTask,
        );
      }

      await loadTasks();

      return state is TaskSuccess;
    } catch (e) {
      emit(TaskError('Failed to update status'));
      return false;
    }
  }
}
