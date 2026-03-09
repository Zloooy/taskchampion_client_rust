// This is a basic Flutter widget test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:taskchampion_client_example/config/app_config.dart';

void main() {
  testWidgets('AppConfig initializes correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppConfig(),
        child: const MaterialApp(home: Scaffold(body: Text('Test'))),
      ),
    );

    // Verify that the app builds correctly
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
