import 'package:flutter/material.dart';
import 'package:taskchampion_client_example/config/app_config.dart';
import 'package:taskchampion_client_rust/taskchampion_client_rust.dart';
import 'package:provider/provider.dart';

/// Task form screen for creating/editing tasks
class TaskFormScreen extends StatefulWidget {
  final Task? task;

  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _projectController;
  late TextEditingController _tagsController;
  TaskPriority _priority = TaskPriority.none;
  DateTime? _dueDate;

  bool get isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.task?.description ?? '',
    );
    _projectController = TextEditingController(
      text: widget.task?.project ?? '',
    );
    _tagsController = TextEditingController(
      text: widget.task?.tagsAsString ?? '',
    );
    _priority = widget.task?.priority ?? TaskPriority.none;
    _dueDate = widget.task?.due;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _projectController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'New Task'),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _save)],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description *',
                hintText: 'What needs to be done?',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Description is required';
                }
                return null;
              },
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Priority selection
            DropdownButtonFormField<TaskPriority>(
              initialValue: _priority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: TaskPriority.none, child: Text('None')),
                DropdownMenuItem(value: TaskPriority.low, child: Text('Low')),
                DropdownMenuItem(
                  value: TaskPriority.medium,
                  child: Text('Medium'),
                ),
                DropdownMenuItem(value: TaskPriority.high, child: Text('High')),
              ],
              onChanged: (value) => setState(() => _priority = value!),
            ),
            const SizedBox(height: 16),

            // Project field
            TextFormField(
              controller: _projectController,
              decoration: const InputDecoration(
                labelText: 'Project',
                hintText: 'e.g., Work, Personal',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Tags field
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags',
                hintText: 'Separate tags with spaces',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Due date picker
            ListTile(
              title: const Text('Due Date'),
              subtitle: Text(
                _dueDate != null
                    ? '📅 ${_dueDate!.month}/${_dueDate!.day}/${_dueDate!.year}'
                    : 'Not set',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDueDate,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (date != null && mounted) {
      setState(() => _dueDate = date);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final config = context.read<AppConfig>();
    final client = config.client;

    if (client == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Client not initialized')));
      return;
    }

    try {
      Task task;

      if (isEditing) {
        task = await client.updateTask(
          uuid: widget.task!.uuid,
          description: _descriptionController.text,
          priority: _priority,
          project: _projectController.text.isEmpty
              ? null
              : _projectController.text,
          tags: _tagsController.text
              .split(' ')
              .where((t) => t.isNotEmpty)
              .toList(),
          due: _dueDate,
        );
      } else {
        task = await client.createTask(
          description: _descriptionController.text,
          priority: _priority,
          project: _projectController.text.isEmpty
              ? null
              : _projectController.text,
          tags: _tagsController.text
              .split(' ')
              .where((t) => t.isNotEmpty)
              .toList(),
          due: _dueDate,
        );
      }

      if (mounted) {
        Navigator.pop(context, task);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
