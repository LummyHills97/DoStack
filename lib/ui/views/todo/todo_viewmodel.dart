import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_todo_demo/models/todo.dart';
import '../../../app/app.locator.dart';
import '../../../services/todo_service.dart';
import 'package:stacked_services/stacked_services.dart';
import 'dart:async';

class TodoViewModel extends ReactiveViewModel {
  final _todoService = locator<TodoService>();
  final _snackbarService = locator<SnackbarService>();
  final _dialogService = locator<DialogService>();

  // Controllers
  TextEditingController textController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  TextEditingController subTaskController = TextEditingController();

  // State variables
  TaskPriority _selectedPriority = TaskPriority.medium;
  TaskCategory _selectedCategory = TaskCategory.personal;
  DateTime? _selectedDueDate;
  bool _isRecurring = false;
  String? _editingTodoId;
  String? _currentTimerTodoId;
  Timer? _timer;
  int _currentSeconds = 0;
  bool _isPomodoroMode = false;
  int _pomodoroMinutes = 25;

  // Filter states
  TaskPriority? _priorityFilter;
  TaskCategory? _categoryFilter;
  bool _showOnlyDueToday = false;
  bool _showOnlyOverdue = false;

  // Getters
  List<Todo> get todos {
    var filteredTodos = _todoService.todos;
    
    if (_priorityFilter != null) {
      filteredTodos = filteredTodos.where((t) => t.priority == _priorityFilter).toList();
    }
    
    if (_categoryFilter != null) {
      filteredTodos = filteredTodos.where((t) => t.category == _categoryFilter).toList();
    }
    
    if (_showOnlyDueToday) {
      filteredTodos = filteredTodos.where((t) => t.isDueToday).toList();
    }
    
    if (_showOnlyOverdue) {
      filteredTodos = filteredTodos.where((t) => t.isOverdue).toList();
    }
    
    // Sort by priority (high first), then by due date
    filteredTodos.sort((a, b) {
      if (a.priority.value != b.priority.value) {
        return b.priority.value.compareTo(a.priority.value);
      }
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }
      if (a.dueDate != null) return -1;
      if (b.dueDate != null) return 1;
      return a.createdAt.compareTo(b.createdAt);
    });
    
    return filteredTodos;
  }

  int get completed => _todoService.completed;
  int get pending => _todoService.pending;
  int get total => _todoService.total;
  int get overdue => todos.where((t) => t.isOverdue).length;
  int get dueToday => todos.where((t) => t.isDueToday).length;

  TaskPriority get selectedPriority => _selectedPriority;
  TaskCategory get selectedCategory => _selectedCategory;
  DateTime? get selectedDueDate => _selectedDueDate;
  bool get isRecurring => _isRecurring;
  bool get isEditing => _editingTodoId != null;
  bool get isTimerRunning => _timer != null && _timer!.isActive;
  String? get currentTimerTodoId => _currentTimerTodoId;
  int get currentSeconds => _currentSeconds;
  bool get isPomodoroMode => _isPomodoroMode;
  int get pomodoroMinutes => _pomodoroMinutes;

  TaskPriority? get priorityFilter => _priorityFilter;
  TaskCategory? get categoryFilter => _categoryFilter;
  bool get showOnlyDueToday => _showOnlyDueToday;
  bool get showOnlyOverdue => _showOnlyOverdue;

  String get timerDisplay {
    final minutes = _currentSeconds ~/ 60;
    final seconds = _currentSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Task CRUD operations
  void addOrUpdateTodo() {
    final title = textController.text.trim();
    
    if (title.isEmpty) {
      _snackbarService.showSnackbar(
        message: 'Please enter a task title',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    if (_editingTodoId != null) {
      _updateExistingTodo();
    } else {
      _createNewTodo(title);
    }
  }

  void _createNewTodo(String title) {
    final todo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      notes: notesController.text.trim(),
      priority: _selectedPriority,
      category: _selectedCategory,
      dueDate: _selectedDueDate,
      isRecurring: _isRecurring,
    );

    _todoService.add(todo);
    _clearForm();
    
    _snackbarService.showSnackbar(
      message: 'Task added successfully!',
      duration: const Duration(seconds: 2),
    );
  }

  void _updateExistingTodo() {
    final existingTodo = todos.firstWhere((t) => t.id == _editingTodoId);
    final updatedTodo = existingTodo.copyWith(
      title: textController.text.trim(),
      notes: notesController.text.trim(),
      priority: _selectedPriority,
      category: _selectedCategory,
      dueDate: _selectedDueDate,
      isRecurring: _isRecurring,
    );

    _todoService.update(updatedTodo);
    _clearForm();
    
    _snackbarService.showSnackbar(
      message: 'Task updated successfully!',
      duration: const Duration(seconds: 2),
    );
  }

  void editTodo(Todo todo) {
    textController.text = todo.title;
    notesController.text = todo.notes;
    _selectedPriority = todo.priority;
    _selectedCategory = todo.category;
    _selectedDueDate = todo.dueDate;
    _isRecurring = todo.isRecurring;
    _editingTodoId = todo.id;
    notifyListeners();
  }

  void cancelEdit() {
    _clearForm();
  }

  void _clearForm() {
    textController.clear();
    notesController.clear();
    _selectedPriority = TaskPriority.medium;
    _selectedCategory = TaskCategory.personal;
    _selectedDueDate = null;
    _isRecurring = false;
    _editingTodoId = null;
    notifyListeners();
  }

  // Property setters
  void setPriority(TaskPriority priority) {
    _selectedPriority = priority;
    notifyListeners();
  }

  void setCategory(TaskCategory category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setDueDate(DateTime? date) {
    _selectedDueDate = date;
    notifyListeners();
  }

  void setRecurring(bool recurring) {
    _isRecurring = recurring;
    notifyListeners();
  }

  // SubTask operations
  void addSubTask(String todoId) {
    final title = subTaskController.text.trim();
    if (title.isEmpty) return;

    final subTask = SubTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
    );

    _todoService.addSubTask(todoId, subTask);
    subTaskController.clear();
  }

  void toggleSubTask(String todoId, String subTaskId) {
    _todoService.toggleSubTask(todoId, subTaskId);
  }

  void deleteSubTask(String todoId, String subTaskId) {
    _todoService.deleteSubTask(todoId, subTaskId);
  }

  // Timer functionality
  void startTimer(String todoId) {
    if (_timer != null) stopTimer();
    
    _currentTimerTodoId = todoId;
    _currentSeconds = _isPomodoroMode ? _pomodoroMinutes * 60 : 0;
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPomodoroMode) {
        _currentSeconds--;
        if (_currentSeconds <= 0) {
          _onPomodoroComplete();
        }
      } else {
        _currentSeconds++;
      }
      notifyListeners();
    });
    
    notifyListeners();
  }

  void stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
      
      if (_currentTimerTodoId != null && _currentSeconds > 0) {
        final minutesSpent = _isPomodoroMode 
            ? _pomodoroMinutes - (_currentSeconds / 60).ceil()
            : (_currentSeconds / 60).ceil();
        
        _todoService.addTimeSpent(_currentTimerTodoId!, minutesSpent);
      }
      
      _currentTimerTodoId = null;
      _currentSeconds = 0;
      notifyListeners();
    }
  }

  void _onPomodoroComplete() {
    stopTimer();
    _snackbarService.showSnackbar(
      message: 'Pomodoro completed! Time for a break.',
      duration: const Duration(seconds: 3),
    );
  }

  void setPomodoroMode(bool enabled) {
    _isPomodoroMode = enabled;
    if (!enabled && _timer != null) {
      stopTimer();
    }
    notifyListeners();
  }

  void setPomodoroMinutes(int minutes) {
    _pomodoroMinutes = minutes;
    notifyListeners();
  }

  // Filter methods
  void setPriorityFilter(TaskPriority? priority) {
    _priorityFilter = priority;
    notifyListeners();
  }

  void setCategoryFilter(TaskCategory? category) {
    _categoryFilter = category;
    notifyListeners();
  }

  void setShowOnlyDueToday(bool show) {
    _showOnlyDueToday = show;
    if (show) _showOnlyOverdue = false;
    notifyListeners();
  }

  void setShowOnlyOverdue(bool show) {
    _showOnlyOverdue = show;
    if (show) _showOnlyDueToday = false;
    notifyListeners();
  }

  void clearFilters() {
    _priorityFilter = null;
    _categoryFilter = null;
    _showOnlyDueToday = false;
    _showOnlyOverdue = false;
    notifyListeners();
  }

  // Existing methods
  void toggle(String id) => _todoService.toggle(id);
  void delete(String id) => _todoService.delete(id);
  void clearCompleted() => _todoService.clearCompleted();

  @override
  void dispose() {
    _timer?.cancel();
    textController.dispose();
    notesController.dispose();
    subTaskController.dispose();
    super.dispose();
  }

  @override
  List<ListenableServiceMixin> get listenableServices => [_todoService];
}