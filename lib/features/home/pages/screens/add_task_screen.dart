
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../cubit/task_cubit.dart';
import '../../../models/model/task_model.dart';

class AddTaskScreen extends StatefulWidget {
  final TaskModel? task;

  const AddTaskScreen({
    super.key,
    this.task,
  });

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleCtl = TextEditingController();
  final _descCtl = TextEditingController();

  DateTime? _pickedDate;
  TimeOfDay? _pickedTime;

  bool _isSaving = false;

  bool get _isEditing => widget.task != null;

  Color get _primary => Theme.of(context).colorScheme.primary;

  String get _dueText {
    if (_pickedDate == null || _pickedTime == null) {
      return 'Select date and time';
    }

    final date = DateTime(
      _pickedDate!.year,
      _pickedDate!.month,
      _pickedDate!.day,
      _pickedTime!.hour,
      _pickedTime!.minute,
    );

    return DateFormat('EEE, dd MMM yyyy • hh:mm a').format(date);
  }

  @override
  void initState() {
    super.initState();

    final task = widget.task;

    if (task != null) {
      _titleCtl.text = task.title;
      _descCtl.text = task.description ?? '';

      _pickedDate = DateTime(
        task.dueDate.year,
        task.dueDate.month,
        task.dueDate.day,
      );

      _pickedTime = TimeOfDay.fromDateTime(task.dueDate);
    }
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();

    final initialDate = _pickedDate ?? now;

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: initialDate.isBefore(now)
          ? initialDate
          : DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: _primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: _pickedTime ?? TimeOfDay.now(),
    );

    if (time == null || !mounted) return;

    setState(() {
      _pickedDate = date;
      _pickedTime = time;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_pickedDate == null || _pickedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select date and time'),
        ),
      );
      return;
    }

    final dueDate = DateTime(
      _pickedDate!.year,
      _pickedDate!.month,
      _pickedDate!.day,
      _pickedTime!.hour,
      _pickedTime!.minute,
    );

    if (dueDate.isBefore(DateTime.now()) &&
        (widget.task == null ||
            dueDate != widget.task!.dueDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a future date and time'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final task = TaskModel(
      id: widget.task?.id,
      title: _titleCtl.text.trim(),
      description: _descCtl.text.trim(),
      dueDate: dueDate,
      status: widget.task?.status ?? 0,
    );

    final success = _isEditing
        ? await context.read<TaskCubit>().updateTask(task)
        : await context.read<TaskCubit>().addTask(task);

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (success) {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Task updated successfully'
                : 'Task added successfully',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _descCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Task' : 'Create Task',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [
                        colors.primary,
                        colors.primary.withOpacity(0.75),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.edit_note_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isEditing
                            ? 'Update your task'
                            : 'Plan your day',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _isEditing
                            ? 'Make changes and keep moving forward.'
                            : 'Add a new task and stay organized.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                const _FieldLabel(
                  title: 'Task title',
                  subtitle: 'What do you need to accomplish?',
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: _titleCtl,
                  textCapitalization: TextCapitalization.sentences,
                  maxLength: 80,
                  decoration: _inputDecoration(
                    context,
                    hint: 'Enter task title',
                    icon: Icons.task_alt_rounded,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Task title is required';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                const _FieldLabel(
                  title: 'Description',
                  subtitle: 'Add some details (optional)',
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: _descCtl,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 4,
                  maxLines: 5,
                  maxLength: 300,
                  decoration: _inputDecoration(
                    context,
                    hint: 'Write a short description...',
                    icon: Icons.notes_rounded,
                  ),
                ),

                const SizedBox(height: 18),

                const _FieldLabel(
                  title: 'Due date & time',
                  subtitle: 'When should this task be completed?',
                ),

                const SizedBox(height: 12),

                InkWell(
                  onTap: _pickDateTime,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: colors.outline.withOpacity(0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.calendar_month_rounded,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _pickedDate == null
                                    ? 'Choose deadline'
                                    : 'Selected deadline',
                                style: theme.textTheme.bodySmall,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                _dueText,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: colors.primary,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                      height: 23,
                      width: 23,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isEditing
                              ? Icons.check_rounded
                              : Icons.add_rounded,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _isEditing
                              ? 'Save Changes'
                              : 'Create Task',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
      BuildContext context, {
        required String hint,
        required IconData icon,
      }) {
    final colors = Theme.of(context).colorScheme;

    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: colors.primary),
      filled: true,
      fillColor: Theme.of(context).cardColor,
      counterText: '',
      contentPadding: const EdgeInsets.all(18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: colors.outline.withOpacity(0.2),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: colors.outline.withOpacity(0.2),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: colors.primary,
          width: 1.5,
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String title;
  final String subtitle;

  const _FieldLabel({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
