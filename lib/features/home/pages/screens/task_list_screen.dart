
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../cubit/task_cubit.dart';
import '../../../../cubit/task_state.dart';
import '../../../models/model/task_model.dart';
import '../widgets/task_card.dart';
import 'add_task_screen.dart';

class TaskListScreen extends StatelessWidget {
  final VoidCallback? onToggleTheme;

  const TaskListScreen({
    super.key,
    this.onToggleTheme,
  });

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  bool _isBeforeDate(DateTime a, DateTime b) {
    return DateTime(a.year, a.month, a.day)
        .isBefore(DateTime(b.year, b.month, b.day));
  }

  void _openAddTask(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddTaskScreen(),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context,
      TaskModel task,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          icon: const Icon(
            Icons.delete_outline_rounded,
            color: Colors.red,
            size: 35,
          ),
          title: const Text('Delete Task?'),
          content: Text(
            'Are you sure you want to delete "${task.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted && task.id != null) {
      await context.read<TaskCubit>().deleteTask(task.id!);
    }
  }

  void _openEditTask(BuildContext context, TaskModel task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTaskScreen(task: task),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MyTasks',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            onPressed: onToggleTheme,
            tooltip: 'Toggle theme',
            icon: Icon(
              theme.brightness == Brightness.dark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: BlocBuilder<TaskCubit, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is TaskError) {
            return _ErrorView(
              message: state.message,
              onRetry: () => context.read<TaskCubit>().loadTasks(),
            );
          }

          if (state is! TaskSuccess) {
            return const SizedBox.shrink();
          }

          final tasks = state.tasks;
          final now = DateTime.now();
          final tomorrow = now.add(const Duration(days: 1));

          final completed = tasks.where((t) => t.status == 1).length;
          final pending = tasks.length - completed;

          final overdueList = tasks.where((task) {
            return task.status == 0 &&
                task.dueDate.isBefore(now);
          }).toList();

          final todayList = tasks.where((task) {
            return task.status == 0 &&
                _isSameDate(task.dueDate, now) &&
                !task.dueDate.isBefore(now);
          }).toList();

          final tomorrowList = tasks.where((task) {
            return task.status == 0 &&
                _isSameDate(task.dueDate, tomorrow);
          }).toList();

          final upcoming = tasks.where((task) {
            return task.status == 0 &&
                !_isBeforeDate(task.dueDate, now) &&
                !_isSameDate(task.dueDate, now) &&
                !_isSameDate(task.dueDate, tomorrow);
          }).toList();

          final completedList = tasks.where((t) => t.status == 1).toList();

          return RefreshIndicator(
            onRefresh: () => context.read<TaskCubit>().loadTasks(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
              children: [
                _WelcomeHeader(
                  taskCount: pending,
                ),

                const SizedBox(height: 22),

                _StatisticsCard(
                  total: tasks.length,
                  completed: completed,
                  pending: pending,
                ),

                const SizedBox(height: 28),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your Tasks',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${tasks.length} total',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                if (tasks.isEmpty)
                  _EmptyState(
                    onAdd: () => _openAddTask(context),
                  )
                else ...[
                  if (overdueList.isNotEmpty)
                    SectionWidget(
                      title: 'Overdue',
                      icon: Icons.warning_amber_rounded,
                      items: overdueList,
                      onEdit: (task) => _openEditTask(context, task),
                      onDelete: (task) => _confirmDelete(context, task),
                    ),

                  if (todayList.isNotEmpty)
                    SectionWidget(
                      title: 'Today',
                      icon: Icons.today_rounded,
                      items: todayList,
                      onEdit: (task) => _openEditTask(context, task),
                      onDelete: (task) => _confirmDelete(context, task),
                    ),

                  if (tomorrowList.isNotEmpty)
                    SectionWidget(
                      title: 'Tomorrow',
                      icon: Icons.event_rounded,
                      items: tomorrowList,
                      onEdit: (task) => _openEditTask(context, task),
                      onDelete: (task) => _confirmDelete(context, task),
                    ),

                  if (upcoming.isNotEmpty)
                    SectionWidget(
                      title: 'Upcoming',
                      icon: Icons.upcoming_rounded,
                      items: upcoming,
                      onEdit: (task) => _openEditTask(context, task),
                      onDelete: (task) => _confirmDelete(context, task),
                    ),

                  if (completedList.isNotEmpty)
                    SectionWidget(
                      title: 'Completed',
                      icon: Icons.check_circle_outline_rounded,
                      items: completedList,
                      onEdit: (task) => _openEditTask(context, task),
                      onDelete: (task) => _confirmDelete(context, task),
                    ),
                ],
              ],
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddTask(context),
        elevation: 3,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Task',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class SectionWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<TaskModel> items;
  final Function(TaskModel) onEdit;
  final Function(TaskModel) onDelete;

  const SectionWidget({
    super.key,
    required this.title,
    required this.items,
    required this.onEdit,
    required this.onDelete,
    this.icon = Icons.circle_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 19,
                color: colors.primary,
              ),
              const SizedBox(width: 9),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 9),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${items.length}',
                  style: TextStyle(
                    color: colors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ...items.map(
                (task) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TaskCard(
                task: task,
                onToggle: () {
                  context.read<TaskCubit>().toggleStatus(task);
                },
                onEdit: () => onEdit(task),
                onDelete: () => onDelete(task),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  final int taskCount;

  const _WelcomeHeader({
    required this.taskCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final date = DateTime.now();

    const months = [
      'January', 'February', 'March', 'April',
      'May', 'June', 'July', 'August',
      'September', 'October', 'November', 'December',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello there 👋',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${months[date.month - 1]} ${date.day}, ${date.year}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          taskCount == 0
              ? 'You are all caught up. Enjoy your day!'
              : 'You have $taskCount tasks waiting for you.',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _StatisticsCard extends StatelessWidget {
  final int total;
  final int completed;
  final int pending;

  const _StatisticsCard({
    required this.total,
    required this.completed,
    required this.pending,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final progress = total == 0 ? 0.0 : completed / total;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary,
            colors.primary.withOpacity(0.78),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withOpacity(0.2),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Task Overview',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
              const Icon(
                Icons.insights_rounded,
                color: Colors.white,
                size: 25,
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              _StatItem(
                value: total,
                label: 'Total',
              ),
              _StatItem(
                value: pending,
                label: 'Pending',
              ),
              _StatItem(
                value: completed,
                label: 'Completed',
              ),
            ],
          ),

          const SizedBox(height: 22),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Completion progress',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final int value;
  final String label;

  const _StatItem({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$value',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 25,
        vertical: 40,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colors.outline.withOpacity(0.15),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.checklist_rounded,
              size: 48,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No tasks yet!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start organizing your day by creating your first task.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.onSurface.withOpacity(0.6),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create First Task'),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 55,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
