// main.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:stacked_todo_demo/app/app_dialog.dart';
import 'app/app.locator.dart';
import 'ui/views/todo/todo_view.dart';

// import your Hive models + generated adapters
import 'models/todo.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters (generated files must exist)
  Hive.registerAdapter(TodoAdapter());
  Hive.registerAdapter(SubTaskAdapter());
  Hive.registerAdapter(TaskPriorityAdapter());
  Hive.registerAdapter(TaskCategoryAdapter());

  // Open boxes BEFORE creating/using services that access them
  await Hive.openBox<Todo>('todos');

  // Now it's safe to setup locator (services may use Hive)
  setupLocator();
  setupDialogUi();

  runApp(const MyApp());
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
