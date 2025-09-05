import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../app/app.locator.dart';
import '../../../services/todo_service.dart';
import 'package:stacked_services/stacked_services.dart';

class TodoViewModel extends ReactiveViewModel {
  final _todoService = locator<TodoService>();
  final _snackbarService = locator<SnackbarService>();
  final _dialogService = locator<DialogService>();

  TextEditingController textController = TextEditingController();

  List get todos => _todoService.todos;
  int get completed => _todoService.completed;
  int get pending => _todoService.pending;
  int get total => _todoService.total;

  void addTodo() {
    final raw = textController.text;
    final title = raw.replaceAll(RegExp(r'[^\x00-\x7F]'), '').trim();

    if (title.isEmpty) {
      _snackbarService.showSnackbar(
        message: 'Please enter a valid todo (no emojis or symbols).',
        duration: const Duration(seconds: 1),
      );
      return;
    }

    if (raw != title) {
      _snackbarService.showSnackbar(
        message: 'Emojis or unsupported characters were removed.',
        duration: const Duration(seconds: 2),
      );
    }

    _todoService.add(title);
    textController.clear();

    _snackbarService.showSnackbar(
      message: 'Todo Added!',
      duration: const Duration(seconds: 2),
    );
  }

  void toggle(String id) => _todoService.toggle(id);

  void delete(String id) => _todoService.delete(id);

  void clearCompleted() => _todoService.clearCompleted();

  @override
  List<ListenableServiceMixin> get listenableServices => [_todoService];
}
