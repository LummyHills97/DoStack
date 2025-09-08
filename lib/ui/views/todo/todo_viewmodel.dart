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
    // start listening to service stream and refresh UI on updates
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

  // Simple passthrough getters used by the view
  List<Todo> get todos => _todoService.todos;
  int get completed => _todoService.completed;
  int get pending => _todoService.pending;
  int get total => _todoService.total;
  int get overdue => todos.where((t) => t.isOverdue).length;
  int get dueToday => todos.where((t) => t.isDueToday).length;

  /// Show the existing custom dialog and create the Todo from result
  Future<void> addTodo() async {
    try {
      print('🔄 Starting addTodo...');
      
      final response = await _dialogService.showCustomDialog(
        variant: DialogType.form,
        title: 'Add New Todo',
        customData: {
          'titleController': TextEditingController(),
          'notesController': TextEditingController(),
          'priority': TaskPriority.medium,
          'category': TaskCategory.personal,
          'dueDate': null as DateTime?,
        },
      );

      print('✅ Dialog response: ${response?.confirmed}, data: ${response?.data}');

      if (response?.confirmed == true && response?.data != null) {
        final data = response!.data as Map<String, dynamic>;
        print('📋 Dialog data keys: ${data.keys.toList()}');
        
        final titleController = data['titleController'] as TextEditingController;
        final notesController = data['notesController'] as TextEditingController;
        
        final title = titleController.text.trim();
        print('📝 Title: "$title"');
        
        if (title.isEmpty) {
          print('⚠️ Title is empty');
          _snackbarService.showSnackbar(message: 'Please enter a todo title.');
          return;
        }

        final priority = data['priority'] as TaskPriority;
        final category = data['category'] as TaskCategory;
        final dueDate = data['dueDate'] as DateTime?;
        
        print('🎯 Priority: $priority, Category: $category, DueDate: $dueDate');

        final newTodo = Todo(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          notes: notesController.text.trim(),
          priority: priority,
          category: category,
          dueDate: dueDate,
          isRecurring: false,
          isCompleted: false,
          timeSpentMinutes: 0,
          streakCount: 0,
        );

        print('✨ Created todo: ${newTodo.id} - ${newTodo.title}');

        await _todoService.add(newTodo);
        print('✅ Todo added to service');
        
        _snackbarService.showSnackbar(message: 'Todo added successfully!');
        
        // Dispose controllers to prevent memory leaks
        titleController.dispose();
        notesController.dispose();
        print('🧹 Controllers disposed');
        
      } else {
        print('❌ Dialog was cancelled or returned null data');
      }
    } catch (e, stackTrace) {
      print('❌ Error in addTodo: $e');
      print('📍 Stack trace: $stackTrace');
      _snackbarService.showSnackbar(message: 'Failed to add todo. Error: $e');
    }
  }

  Future<void> toggleComplete(String id) async {
    try {
      print('🔄 Toggling todo completion: $id');
      await _todoService.toggleComplete(id);
      _snackbarService.showSnackbar(message: 'Todo updated');
      print('✅ Todo toggled successfully');
    } catch (e) {
      print('❌ Error toggling todo: $e');
      _snackbarService.showSnackbar(message: 'Failed to update todo');
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      print('🗑️ Deleting todo: $id');
      await _todoService.delete(id);
      _snackbarService.showSnackbar(message: 'Todo deleted');
      print('✅ Todo deleted successfully');
    } catch (e) {
      print('❌ Error deleting todo: $e');
      _snackbarService.showSnackbar(message: 'Failed to delete todo');
    }
  }

  Future<void> clearCompleted() async {
    try {
      final completedCount = completed;
      print('🧹 Clearing $completedCount completed todos');
      
      if (completedCount == 0) {
        _snackbarService.showSnackbar(message: 'No completed todos to clear');
        return;
      }
      
      await _todoService.clearCompleted();
      _snackbarService.showSnackbar(message: 'Cleared $completedCount completed todos');
      print('✅ Completed todos cleared successfully');
    } catch (e) {
      print('❌ Error clearing completed todos: $e');
      _snackbarService.showSnackbar(message: 'Failed to clear completed todos');
    }
  }

  Future<void> editTodo(Todo todo) async {
    try {
      print('✏️ Editing todo: ${todo.id} - ${todo.title}');
      
      final response = await _dialogService.showCustomDialog(
        variant: DialogType.form,
        title: 'Edit Todo',
        customData: {
          'titleController': TextEditingController(text: todo.title),
          'notesController': TextEditingController(text: todo.notes),
          'priority': todo.priority,
          'category': todo.category,
          'dueDate': todo.dueDate,
          'initialId': todo.id,
        },
      );

      print('✅ Edit dialog response: ${response?.confirmed}, data: ${response?.data}');

      if (response?.confirmed == true && response?.data != null) {
        final data = response!.data as Map<String, dynamic>;
        final titleController = data['titleController'] as TextEditingController;
        final notesController = data['notesController'] as TextEditingController;
        
        final title = titleController.text.trim();
        if (title.isEmpty) {
          print('⚠️ Edit: Title is empty');
          _snackbarService.showSnackbar(message: 'Title cannot be empty');
          return;
        }

        final updated = todo.copyWith(
          title: title,
          notes: notesController.text.trim(),
          priority: data['priority'] as TaskPriority,
          category: data['category'] as TaskCategory,
          dueDate: data['dueDate'] as DateTime?,
        );

        print('🔄 Updating todo with new data');
        await _todoService.update(updated);
        _snackbarService.showSnackbar(message: 'Todo updated successfully');
        print('✅ Todo updated successfully');
        
        // Dispose controllers to prevent memory leaks
        titleController.dispose();
        notesController.dispose();
      } else {
        print('❌ Edit dialog was cancelled');
      }
    } catch (e, stackTrace) {
      print('❌ Error editing todo: $e');
      print('📍 Stack trace: $stackTrace');
      _snackbarService.showSnackbar(message: 'Failed to update todo. Error: $e');
    }
  }
}