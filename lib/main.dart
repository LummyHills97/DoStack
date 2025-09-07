// lib/main.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stacked_services/stacked_services.dart';

import 'app/app.locator.dart';
import 'app/app_dialog.dart'; // provides setupDialogUi()
import 'models/todo.dart';
import 'ui/views/todo/todo_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Initialize Hive
  await Hive.initFlutter();

  // 2) Register adapters (safe: only register if not already registered)
  try {
    _registerAdaptersSafe();
    debugPrint('✅ Hive adapters registered (or were already registered).');
  } catch (e, st) {
    debugPrint('❌ Error registering adapters: $e\n$st');
    rethrow;
  }

  // 3) Open boxes BEFORE creating/using services that expect them
  try {
    await Hive.openBox<Todo>('todos');
    debugPrint('✅ Opened Hive box "todos".');
  } catch (e, st) {
    debugPrint('❌ Failed to open Hive box: $e\n$st');
    rethrow;
  }

  // 4) Setup service locator (registers services like DialogService, TodoService, etc.)
  setupLocator();
  debugPrint('✅ Service locator setup complete.');

  // 5) Register dialog builders (uses the same DialogService instance from locator)
  //    This wires up your custom dialogs so showCustomDialog(...) works.
  try {
    setupDialogUi();
    debugPrint('✅ Custom dialog UI registered.');
  } catch (e, st) {
    debugPrint('❌ Error during setupDialogUi(): $e\n$st');
    rethrow;
  }

  // 6) Run the app
  runApp(const MyApp());
}

void _registerAdaptersSafe() {
  // Adapter typeIds must match what your generated (or manual) todo.g.dart defines.
  // Only register if Hive hasn't already seen that typeId.
  if (!Hive.isAdapterRegistered(TaskPriorityAdapter().typeId)) {
    Hive.registerAdapter(TaskPriorityAdapter());
  }
  if (!Hive.isAdapterRegistered(TaskCategoryAdapter().typeId)) {
    Hive.registerAdapter(TaskCategoryAdapter());
  }
  if (!Hive.isAdapterRegistered(SubTaskAdapter().typeId)) {
    Hive.registerAdapter(SubTaskAdapter());
  }
  if (!Hive.isAdapterRegistered(TodoAdapter().typeId)) {
    Hive.registerAdapter(TodoAdapter());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DoStack Todo',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      navigatorKey: StackedService.navigatorKey,
      home: const TodoView(),
    );
  }
}
