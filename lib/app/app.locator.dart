import 'package:get_it/get_it.dart';
import 'package:stacked_services/stacked_services.dart';
import '../services/todo_service.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  // Register TodoService
  locator.registerLazySingleton<TodoService>(() => TodoService());
  
  // Register Stacked Services
  locator.registerLazySingleton<NavigationService>(() => NavigationService());
  locator.registerLazySingleton<DialogService>(() => DialogService());
  locator.registerLazySingleton<SnackbarService>(() => SnackbarService());
}