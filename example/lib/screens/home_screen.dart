import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskchampion_client_example/config/app_config.dart';
import 'package:taskchampion_client_rust/taskchampion_client_rust.dart';
import 'package:intl/intl.dart';
import 'task_form_screen.dart';

/// Home screen displaying task list
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TaskStatus? _filterStatus;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Initialize app config on home screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final config = context.read<AppConfig>();
      if (!config.isInitialized) {
        config.initialize();
      }
    });
  }

  /// Build filter based on search query and status filter
  TaskFilter _buildFilter() {
    final filters = <FilterExpression>[];

    // Add status filter if selected
    if (_filterStatus != null) {
      filters.add(EqualsFilter(
        property: const StringPropertyRef('status'),
        value: _filterStatus!.name,
      ));
    }

    // Add search filter if query is not empty
    if (_searchQuery.isNotEmpty) {
      filters.add(ContainsFilter(
        property: const StringPropertyRef('description'),
        value: _searchQuery,
        caseSensitive: false,
      ));
    }

    // Return combined filter
    if (filters.isEmpty) {
      return TaskFilter.matchAll;
    } else if (filters.length == 1) {
      return TaskFilter(filters.first);
    } else {
      return TaskFilter(AndFilterGroup(filters));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskChampion Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          Consumer<AppConfig>(
            builder: (context, config, child) {
              return IconButton(
                icon: config.isSyncing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync),
                onPressed: config.isSyncing ? null : () => config.sync(),
                tooltip: 'Sync',
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _filterStatus == null,
                  onSelected: (selected) =>
                      setState(() => _filterStatus = null),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Pending'),
                  selected: _filterStatus == TaskStatus.pending,
                  onSelected: (selected) => setState(
                    () => _filterStatus = selected ? TaskStatus.pending : null,
                  ),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Completed'),
                  selected: _filterStatus == TaskStatus.completed,
                  onSelected: (selected) => setState(
                    () =>
                        _filterStatus = selected ? TaskStatus.completed : null,
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // Task list
          Expanded(
            child: Consumer<AppConfig>(
              builder: (context, config, child) {
                if (config.client == null) {
                  return const Center(child: Text('Initializing...'));
                }

                // Use filter-based search
                final filter = _buildFilter();

                return FutureBuilder<List<Task>>(
                  future: config.client!.filterTasks(filter),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final tasks = snapshot.data ?? [];

                    if (tasks.isEmpty) {
                      final hasQuery = _searchQuery.isNotEmpty || _filterStatus != null;
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              hasQuery ? Icons.search_off : Icons.task_alt,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              hasQuery
                                  ? 'No tasks match your search'
                                  : 'No tasks found',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            if (hasQuery)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _searchQuery = '';
                                    _filterStatus = null;
                                  });
                                },
                                child: const Text('Clear filters'),
                              ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return TaskListTile(
                          task: task,
                          onTap: () => _editTask(task),
                          onToggle: () => _toggleTask(task),
                          onDelete: () => _deleteTask(task),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createTask(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _createTask() async {
    final result = await Navigator.push<Task>(
      context,
      MaterialPageRoute(builder: (context) => const TaskFormScreen()),
    );

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task created: ${result.description}')),
      );
    }
  }

  void _editTask(Task task) async {
    final result = await Navigator.push<Task>(
      context,
      MaterialPageRoute(builder: (context) => TaskFormScreen(task: task)),
    );

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task updated: ${result.description}')),
      );
    }
  }

  void _toggleTask(Task task) async {
    final config = context.read<AppConfig>();
    final newStatus = task.status == TaskStatus.pending
        ? TaskStatus.completed
        : TaskStatus.pending;

    await config.client?.updateTask(uuid: task.uuid, status: newStatus);

    if (mounted) {
      setState(() {});
    }
  }

  void _deleteTask(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Delete "${task.description}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<AppConfig>().client?.deleteTask(task.uuid);
      setState(() {});
    }
  }
}

/// Task list tile widget
class TaskListTile extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TaskListTile({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = task.status == TaskStatus.completed;

    return Dismissible(
      key: Key(task.uuid),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: ListTile(
        onTap: onTap,
        leading: IconButton(
          icon: Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isCompleted ? Colors.green : null,
          ),
          onPressed: onToggle,
        ),
        title: Text(
          task.description,
          style: TextStyle(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted ? theme.disabledColor : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.project != null) Text('📁 ${task.project}'),
            if (task.due != null)
              Text(
                '📅 ${DateFormat('MMM d, y').format(task.due!)}',
                style: TextStyle(color: task.isOverdue ? Colors.red : null),
              ),
          ],
        ),
        trailing: task.priority != TaskPriority.none
            ? PriorityBadge(priority: task.priority)
            : null,
      ),
    );
  }
}

/// Priority badge widget
class PriorityBadge extends StatelessWidget {
  final TaskPriority priority;

  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (priority) {
      case TaskPriority.high:
        color = Colors.red;
        label = 'H';
        break;
      case TaskPriority.medium:
        color = Colors.orange;
        label = 'M';
        break;
      case TaskPriority.low:
        color = Colors.green;
        label = 'L';
        break;
      case TaskPriority.none:
        return const SizedBox.shrink();
    }

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
