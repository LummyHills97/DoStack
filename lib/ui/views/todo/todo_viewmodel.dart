import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_todo_demo/models/todo.dart';
import '../../../app/app.locator.dart';
import '../../../services/todo_service.dart';
 // Make sure to import your Todo model
import 'package:stacked_services/stacked_services.dart';

class TodoViewModel extends ReactiveViewModel {
  final _todoService = locator<TodoService>();
  final _snackbarService = locator<SnackbarService>();

  TextEditingController textController = TextEditingController();

  List<Todo> get todos {
    // Create a mutable copy of the unmodifiable list
    var filteredTodos = List<Todo>.from(_todoService.todos);
    
    // Sort by completion status and creation date for now
    filteredTodos.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1; // Incomplete first
      }
      return b.createdAt.compareTo(a.createdAt); // Newer first
    });
    return filteredTodos;
  }

  int get completed => _todoService.completed;
  int get pending => _todoService.pending;
  int get total => _todoService.total;

  // Enhanced stats using actual Todo properties
  int get overdue {
    return todos.where((todo) => todo.isOverdue).length;
  }

  int get dueToday {
    return todos.where((todo) => todo.isDueToday).length;
  }

  // Updated addTodo method with better emoji handling
  void addTodo() {
    final raw = textController.text.trim();
    
    if (raw.isEmpty) {
      _snackbarService.showSnackbar(
        message: 'Please enter a todo item.',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // Better emoji removal that preserves regular text
    final title = raw.replaceAll(RegExp(r'[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F1E0}-\u{1F1FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]', unicode: true), '').replaceAll(RegExp(r'\s+'), ' ').trim();
    
    if (title.isEmpty) {
      _snackbarService.showSnackbar(
        message: 'Please enter valid text (emojis only are not allowed).',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    if (raw != title && title.isNotEmpty) {
      _snackbarService.showSnackbar(
        message: 'Emojis were removed from your todo.',
        duration: const Duration(seconds: 2),
      );
    }

    // Create a Todo object with required fields
    final newTodo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      priority: TaskPriority.medium, // Default priority
      category: TaskCategory.personal, // Default category
    );

    _todoService.add(newTodo); // Now passing a Todo object
    textController.clear();
    
    _snackbarService.showSnackbar(
      message: 'Todo Added!',
      duration: const Duration(seconds: 2),
    );
  }

  void toggle(String id) => _todoService.toggle(id);
  void delete(String id) => _todoService.delete(id);
  void clearCompleted() => _todoService.clearCompleted();

  // Helper methods now using actual Todo properties
  String getPriorityLabel(Todo todo) {
    switch (todo.priority) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }

  Color getPriorityColor(Todo todo) {
    switch (todo.priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
    }
  }

  String getCategoryLabel(Todo todo) {
    switch (todo.category) {
      case TaskCategory.work:
        return 'Work';
      case TaskCategory.personal:
        return 'Personal';
      case TaskCategory.shopping:
        return 'Shopping';
      case TaskCategory.health:
        return 'Health';
      case TaskCategory.education:
        return 'Education';
      case TaskCategory.finance:
        return 'Finance';
      
      case TaskCategory.other:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  IconData getCategoryIcon(Todo todo) {
    switch (todo.category) {
      case TaskCategory.work:
        return Icons.work;
      case TaskCategory.personal:
        return Icons.person;
      case TaskCategory.shopping:
        return Icons.shopping_cart;
      case TaskCategory.health:
        return Icons.health_and_safety;
      case TaskCategory.education:
        return Icons.school;
      // Remove the cases that don't exist in your enum
      case TaskCategory.finance:
        // TODO: Handle this case.
        throw UnimplementedError();
      case TaskCategory.other:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  bool hasSubTasks(Todo todo) {
    return todo.subTasks.isNotEmpty;
  }

  double getSubTaskProgress(Todo todo) {
    if (todo.subTasks.isEmpty) return 1.0;
    final completed = todo.subTasks.where((st) => st.isCompleted).length;
    return completed / todo.subTasks.length;
  }

  String getTimeSpent(Todo todo) {
    if (todo.timeSpentMinutes == 0) return '';
    final hours = todo.timeSpentMinutes ~/ 60;
    final minutes = todo.timeSpentMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  bool isRecurring(Todo todo) {
    return todo.isRecurring;
  }

  int getStreakCount(Todo todo) {
    return todo.streakCount;
  }

  bool isOverdue(Todo todo) {
    return todo.isOverdue;
  }

  bool isDueToday(Todo todo) {
    return todo.isDueToday;
  }

  String getDueDateString(Todo todo) {
    if (todo.dueDate == null) return '';
    
    final now = DateTime.now();
    final dueDate = todo.dueDate!;
    final difference = dueDate.difference(now).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference > 1) {
      return 'In $difference days';
    } else {
      return '${difference.abs()} days ago';
    }
  }

  String getNotes(Todo todo) {
    return todo.notes;
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  List<ListenableServiceMixin> get listenableServices => [_todoService];
}