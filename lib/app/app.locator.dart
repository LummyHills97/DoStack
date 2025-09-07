import 'package:get_it/get_it.dart';
import 'package:stacked_services/stacked_services.dart';
import '../services/todo_service.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  // Register Stacked Services FIRST
  locator.registerLazySingleton<NavigationService>(() => NavigationService());
  locator.registerLazySingleton<DialogService>(() => DialogService());
  locator.registerLazySingleton<SnackbarService>(() => SnackbarService());

  // Register TodoService AFTER the other services
  locator.registerLazySingleton<TodoService>(() => TodoService());

  print('✅ All services registered in locator');
}