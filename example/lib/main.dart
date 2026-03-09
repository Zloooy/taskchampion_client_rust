import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskchampion_client_example/config/app_config.dart';
import 'package:taskchampion_client_rust/taskchampion_client_rust.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';

/// TaskChampion Client Library Example Application
///
/// This example demonstrates how to use the TaskChampion client library
/// to create a full-featured task management application.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the TaskChampion library
  await TaskChampionClient.init();

  runApp(const TaskChampionExampleApp());
}

class TaskChampionExampleApp extends StatelessWidget {
  const TaskChampionExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppConfig(),
      child: MaterialApp(
        title: 'TaskChampion Example',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        darkTheme: ThemeData.dark(useMaterial3: true),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
        routes: {'/settings': (context) => const SettingsScreen()},
      ),
    );
  }
}
