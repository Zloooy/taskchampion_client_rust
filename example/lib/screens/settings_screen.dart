import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskchampion_client_example/config/app_config.dart';
import 'package:taskchampion_client_rust/taskchampion_client_rust.dart';
import 'package:taskchampion_client_example/services/task_storage_service.dart';
import 'package:taskchampion_client_example/services/permission_service.dart';

/// Settings screen for configuring sync server
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _serverUrlController;
  late TextEditingController _clientIdController;
  late TextEditingController _encryptionSecretController;
  bool _isEditing = false;
  bool _isLoading = false;
  bool _isExporting = false;
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    final config = context.read<AppConfig>();
    _serverUrlController = TextEditingController(text: config.serverUrl);
    _clientIdController = TextEditingController(text: config.clientId);
    _encryptionSecretController = TextEditingController(
      text: config.encryptionSecret,
    );
    
    // Initialize app config if not already initialized
    if (!config.isInitialized) {
      config.initialize();
    }
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    _clientIdController.dispose();
    _encryptionSecretController.dispose();
    super.dispose();
  }

  Future<void> _saveConfiguration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isEditing = false;
      _isLoading = true;
    });

    final config = context.read<AppConfig>();

    try {
      // Update configuration - this will clear old data and reconnect
      await config.updateConfiguration(
        serverUrl: _serverUrlController.text.trim(),
        clientId: _clientIdController.text.trim(),
        encryptionSecret: _encryptionSecretController.text.trim(),
      );

      if (config.isConnected) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Configuration saved and connected successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Configuration saved but connection failed. Check credentials.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _cancelEditing() {
    final config = context.read<AppConfig>();
    setState(() {
      _isEditing = false;
      _serverUrlController.text = config.serverUrl;
      _clientIdController.text = config.clientId;
      _encryptionSecretController.text = config.encryptionSecret;
    });
  }

  Future<void> _clearCredentials() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Credentials'),
        content: const Text(
          'This will remove all stored credentials from secure storage and reset to defaults. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final config = context.read<AppConfig>();
      await config.clearCredentials();
      setState(() {
        _serverUrlController.text = config.serverUrl;
        _clientIdController.text = config.clientId;
        _encryptionSecretController.text = config.encryptionSecret;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Credentials cleared'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _exportTasks() async {
    final config = context.read<AppConfig>();
    if (config.client == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Client not initialized'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Check permission
    final permissionGranted = await PermissionService.requestStoragePermission();
    if (!permissionGranted) {
      if (mounted) {
        _showPermissionDeniedDialog();
      }
      return;
    }

    setState(() => _isExporting = true);

    try {
      final service = TaskStorageService(client: config.client);
      final success = await service.exportTasks();

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tasks exported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _importTasks() async {
    final config = context.read<AppConfig>();
    if (config.client == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Client not initialized'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Check permission
    final permissionGranted = await PermissionService.requestStoragePermission();
    if (!permissionGranted) {
      if (mounted) {
        _showPermissionDeniedDialog();
      }
      return;
    }

    setState(() => _isImporting = true);

    try {
      final service = TaskStorageService(client: config.client);
      final result = await service.importTasks();

      if (mounted) {
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.summary),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Import failed: ${result.errorMessage}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isImporting = false);
    }
  }

  /// Show dialog when permission is denied
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'File access permission is required to export/import tasks. '
          'You can grant it in the app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await PermissionService.openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          if (_isEditing) ...[
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _isLoading ? null : _saveConfiguration,
              tooltip: 'Save',
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _isLoading ? null : _cancelEditing,
              tooltip: 'Cancel',
            ),
          ] else
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Edit',
            ),
        ],
      ),
      body: Consumer<AppConfig>(
        builder: (context, config, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Connection status card
              Card(
                child: ListTile(
                  leading: Icon(
                    config.isConnected ? Icons.cloud_done : Icons.cloud_off,
                    color: config.isConnected ? Colors.green : Colors.grey,
                  ),
                  title: Text(
                    config.isConnected ? 'Connected' : 'Disconnected',
                  ),
                  subtitle: Text(config.serverUrl),
                  trailing: config.isConnected
                      ? ElevatedButton(
                          onPressed: () => config.disconnect(),
                          child: const Text('Disconnect'),
                        )
                      : ElevatedButton(
                          onPressed: () => config.initClient(),
                          child: const Text('Connect'),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // Server configuration
              const Text(
                'Server Configuration',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildConfigField(
                          label: 'Server URL',
                          controller: _serverUrlController,
                          enabled: _isEditing,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Server URL is required';
                            }
                            if (!value.trim().startsWith('http://') &&
                                !value.trim().startsWith('https://')) {
                              return 'URL must start with http:// or https://';
                            }
                            return null;
                          },
                        ),
                        const Divider(),
                        _buildConfigField(
                          label: 'Client ID',
                          controller: _clientIdController,
                          enabled: _isEditing,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Client ID is required';
                            }
                            return null;
                          },
                        ),
                        const Divider(),
                        _buildConfigField(
                          label: 'Encryption Secret',
                          controller: _encryptionSecretController,
                          enabled: _isEditing,
                          obscureText: !_isEditing,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Encryption secret is required';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              if (_isEditing) ...[
                const SizedBox(height: 16),
                Card(
                  color: Colors.amber.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber, color: Colors.amber),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Changing credentials will clear local data and sync from the new server.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Statistics
              const Text(
                'Statistics',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              FutureBuilder<TaskStats>(
                future: config.client?.getStats(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final stats = snapshot.data!;

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildStatRow('Total Tasks', stats.total.toString()),
                          const Divider(),
                          _buildStatRow('Pending', stats.pending.toString()),
                          const Divider(),
                          _buildStatRow(
                            'Completed',
                            stats.completed.toString(),
                          ),
                          const Divider(),
                          _buildStatRow('Deleted', stats.deleted.toString()),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Actions
              const Text(
                'Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.sync),
                      title: const Text('Sync Now'),
                      subtitle: const Text('Manually sync with server'),
                      onTap: config.isConnected ? () => config.sync() : null,
                    ),
                    const Divider(),
                    ListTile(
                      leading: _isExporting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.download),
                      title: const Text('Export Tasks'),
                      subtitle: const Text('Export all tasks to JSON file'),
                      onTap: _isExporting ? null : _exportTasks,
                    ),
                    const Divider(),
                    ListTile(
                      leading: _isImporting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.upload),
                      title: const Text('Import Tasks'),
                      subtitle: const Text('Import tasks from JSON file'),
                      onTap: _isImporting ? null : _importTasks,
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.delete_forever, color: Colors.red),
                      title: const Text(
                        'Clear Credentials',
                        style: TextStyle(color: Colors.red),
                      ),
                      subtitle: const Text('Remove stored credentials'),
                      onTap: _clearCredentials,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // About
              const Text(
                'About',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'TaskChampion Client Example',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text('Version 0.1.0'),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Open GitHub repo
                        },
                        icon: const Icon(Icons.code),
                        label: const Text('View on GitHub'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildConfigField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              enabled: enabled,
              obscureText: obscureText && !enabled,
              validator: validator,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
