import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../cubit/task_cubit.dart';
import '../../../../cubit/task_state.dart';
import '../../../models/model/task_model.dart';
import '../widgets/task_card.dart';
import 'add_task_screen.dart';

class TaskListScreen extends StatelessWidget {
  final VoidCallback? onToggleTheme; // لو عايز تمرر toggle من main
  const TaskListScreen({super.key, this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MyTasks',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.wb_sunny_outlined, size: 26),
            onPressed: onToggleTheme, // يشتغل لو مررت دالة
          )
        ],
      ),
      body: BlocBuilder<TaskCubit, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TaskError) {
            return Center(child: Text(state.message));
          } else if (state is TaskSuccess) {
            final tasks = state.tasks;
            if (tasks.isEmpty) {
              return const Center(
                  child: Text(
                    'No tasks yet — add your first one',
                    style: TextStyle(fontSize: 16),
                  ));
            }

            final today = DateTime.now();
            final tomorrow = today.add(const Duration(days: 1));

            final todayList = tasks.where((t) => isSameDate(t.dueDate, today)).toList();
            final tomorrowList = tasks.where((t) => isSameDate(t.dueDate, tomorrow)).toList();
            final upcoming = tasks
                .where((t) =>
            !isSameDate(t.dueDate, today) && !isSameDate(t.dueDate, tomorrow))
                .toList();

            return RefreshIndicator(
              onRefresh: () => context.read<TaskCubit>().loadTasks(),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  if (todayList.isNotEmpty)
                    SectionWidget(title: 'Today', items: todayList),
                  if (tomorrowList.isNotEmpty)
                    SectionWidget(title: 'Tomorrow', items: tomorrowList),
                  if (upcoming.isNotEmpty)
                    SectionWidget(title: 'Upcoming', items: upcoming),
                ],
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const AddTaskScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }

  bool isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class SectionWidget extends StatelessWidget {
  final String title;
  final List<TaskModel> items;
  const SectionWidget({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...items.map((task) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: TaskCard(
            task: task,
            onToggle: () => context.read<TaskCubit>().toggleStatus(task),
            onDelete: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Delete task?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel')),
                  TextButton(
                      onPressed: () {
                        context.read<TaskCubit>().deleteTask(task.id!);
                        Navigator.pop(context);
                      },
                      child: const Text('Delete')),
                ],
              ),
            ),
            onEdit: () {
              // optional: implement edit flow (re-use AddTaskScreen with initial values)
            },
          ),
        )),
      ],
    );
  }
}
