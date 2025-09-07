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

  // Setup locator
  setupLocator();
  print('✅ Locator setup complete');

  // Setup dialog UI directly here instead of calling setupDialogUi()
  try {
    final dialogService = locator<DialogService>();
    print('✅ Got DialogService from locator');
    
    dialogService.registerCustomDialogBuilder(
      variant: DialogType.form,
      builder: (context, dialogRequest, onDialogTap) {
        print('🏗️ Building FormDialog in main...');
        return FormDialog(
          request: dialogRequest,
          completion: onDialogTap,
        );
      },
    );
    print('✅ Dialog builder registered successfully in main');
  } catch (e) {
    print('❌ Error registering dialog in main: $e');
  }

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