
import '../features/models/model/task_model.dart';

abstract class TaskState {}

class TaskLoading extends TaskState {}

class TaskSuccess extends TaskState {
  final List<TaskModel> tasks;

  TaskSuccess(this.tasks);
}

class TaskError extends TaskState {
  final String message;

  TaskError(this.message);
}
