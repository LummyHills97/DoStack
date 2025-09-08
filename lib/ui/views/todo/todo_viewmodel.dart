import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:stacked_todo_demo/app/app_dialog.dart';
import '../../../app/app.locator.dart';
import '../../../services/todo_service.dart';
import '../../../models/todo.dart';

class TodoViewModel extends BaseViewModel {
  final TodoService _todoService = locator<TodoService>();
  final DialogService _dialogService = locator<DialogService>();
  final SnackbarService _snackbarService = locator<SnackbarService>();

  StreamSubscription<List<Todo>>? _sub;
  bool _initialized = false;

  TodoViewModel() {
    _startWatching();
  }

  Future<void> _startWatching() async {
    try {
      setBusy(true);
      await _todoService.init();
      _sub = _todoService.watchTodos().listen(
        (_) {
          if (!_initialized) {
            _initialized = true;
            setBusy(false);
          }
          notifyListeners();
        },
        onError: (error) {
          print('Error watching todos: $error');
          setBusy(false);
        },
      );
    } catch (e) {
      print('Error initializing todo service: $e');
      setBusy(false);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  // Getters
  List<Todo> get todos => _todoService.todos;
  int get completed => _todoService.completed;
  int get pending => _todoService.pending;
  int get total => _todoService.total;
  int get overdue => todos.where((t) => t.isOverdue).length;
  int get dueToday => todos.where((t) => t.isDueToday).length;

  /// Add new todo (with custom dialog)
  Future<void> addTodo() async {
    try {
      final response = await _dialogService.showCustomDialog(
        variant: DialogType.form,
        title: "Add Todo",
      );

      if (response != null && response.confirmed) {
        final data = response.data as Map<String, dynamic>;
        final title =
            (data['titleController'] as TextEditingController).text.trim();
        final notes =
            (data['notesController'] as TextEditingController).text.trim();

        if (title.isEmpty) {
          _snackbarService.showSnackbar(message: "Title cannot be empty");
          return;
        }

        final newTodo = Todo(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          notes: notes,
        );

        await _todoService.add(newTodo);
        _snackbarService.showSnackbar(message: "Todo added successfully!");
        notifyListeners();
      }
    } catch (e, stackTrace) {
      print('❌ Error in addTodo: $e');
      print('📍 $stackTrace');
      _snackbarService.showSnackbar(message: "Failed to add todo");
    }
  }

  /// Toggle completion
  Future<void> toggleComplete(String id) async {
    try {
      await _todoService.toggleComplete(id);
      _snackbarService.showSnackbar(message: "Todo updated");
    } catch (e) {
      _snackbarService.showSnackbar(message: "Failed to update todo");
    }
  }

  /// Delete
  Future<void> deleteTodo(String id) async {
    try {
      await _todoService.delete(id);
      _snackbarService.showSnackbar(message: "Todo deleted");
    } catch (e) {
      _snackbarService.showSnackbar(message: "Failed to delete todo");
    }
  }

  /// Clear completed
  Future<void> clearCompleted() async {
    try {
      if (completed == 0) {
        _snackbarService.showSnackbar(message: "No completed todos to clear");
        return;
      }
      await _todoService.clearCompleted();
      _snackbarService.showSnackbar(message: "Cleared completed todos");
    } catch (e) {
      _snackbarService.showSnackbar(message: "Failed to clear todos");
    }
  }

  /// Edit todo
  Future<void> editTodo(Todo todo) async {
    try {
      final response = await _dialogService.showCustomDialog(
        variant: DialogType.form,
        title: "Edit Todo",
        customData: {
          'titleController': TextEditingController(text: todo.title),
          'notesController': TextEditingController(text: todo.notes),
          'priority': todo.priority,
          'category': todo.category,
          'dueDate': todo.dueDate,
          'initialId': todo.id,
        },
      );

      if (response != null && response.confirmed) {
        final data = response.data as Map<String, dynamic>;
        final title =
            (data['titleController'] as TextEditingController).text.trim();
        final notes =
            (data['notesController'] as TextEditingController).text.trim();

        if (title.isEmpty) {
          _snackbarService.showSnackbar(message: "Title cannot be empty");
          return;
        }

        final updated = todo.copyWith(
          title: title,
          notes: notes,
          priority: data['priority'] as TaskPriority,
          category: data['category'] as TaskCategory,
          dueDate: data['dueDate'] as DateTime?,
        );

        await _todoService.update(updated);
        _snackbarService.showSnackbar(message: "Todo updated successfully");
      }
    } catch (e, stackTrace) {
      print('❌ Error editing todo: $e');
      print('📍 $stackTrace');
      _snackbarService.showSnackbar(message: "Failed to update todo");
    }
  }
}
