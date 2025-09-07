import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../services/todo_service.dart';
import '../../../models/todo.dart';

class TodoViewModel extends BaseViewModel {
  final TodoService _todoService = locator<TodoService>();
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

  // Simple passthrough getters used by the view
  List<Todo> get todos => _todoService.todos;
  int get completed => _todoService.completed;
  int get pending => _todoService.pending;
  int get total => _todoService.total;
  int get overdue => todos.where((t) => t.isOverdue).length;
  int get dueToday => todos.where((t) => t.isDueToday).length;

  /// Simple dialog using Flutter's built-in showDialog
  Future<void> addTodo(BuildContext context) async {
    try {
      print('🔄 Starting addTodo with simple dialog...');
      
      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => AddTodoDialog(),
      );

      print('✅ Dialog result: $result');

      if (result != null) {
        final title = result['title'] as String;
        if (title.trim().isEmpty) {
          _snackbarService.showSnackbar(message: 'Please enter a todo title.');
          return;
        }

        final newTodo = Todo(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title.trim(),
          notes: result['notes'] as String? ?? '',
          priority: result['priority'] as TaskPriority? ?? TaskPriority.medium,
          category: result['category'] as TaskCategory? ?? TaskCategory.personal,
          dueDate: result['dueDate'] as DateTime?,
          isRecurring: false,
          isCompleted: false,
          timeSpentMinutes: 0,
          streakCount: 0,
        );

        print('✨ Created todo: ${newTodo.id} - ${newTodo.title}');
        await _todoService.add(newTodo);
        _snackbarService.showSnackbar(message: 'Todo added successfully!');
        print('✅ Todo added successfully');
      }
    } catch (e, stackTrace) {
      print('❌ Error in addTodo: $e');
      print('📍 Stack trace: $stackTrace');
      _snackbarService.showSnackbar(message: 'Failed to add todo. Error: $e');
    }
  }

  /// Simple edit dialog
  Future<void> editTodo(BuildContext context, Todo todo) async {
    try {
      print('✏️ Editing todo: ${todo.id} - ${todo.title}');
      
      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => AddTodoDialog(existingTodo: todo),
      );

      if (result != null) {
        final title = result['title'] as String;
        if (title.trim().isEmpty) {
          _snackbarService.showSnackbar(message: 'Title cannot be empty');
          return;
        }

        final updated = todo.copyWith(
          title: title.trim(),
          notes: result['notes'] as String? ?? '',
          priority: result['priority'] as TaskPriority? ?? todo.priority,
          category: result['category'] as TaskCategory? ?? todo.category,
          dueDate: result['dueDate'] as DateTime?,
        );

        await _todoService.update(updated);
        _snackbarService.showSnackbar(message: 'Todo updated successfully');
        print('✅ Todo updated successfully');
      }
    } catch (e) {
      print('❌ Error editing todo: $e');
      _snackbarService.showSnackbar(message: 'Failed to update todo');
    }
  }

  Future<void> toggleComplete(String id) async {
    try {
      await _todoService.toggleComplete(id);
      _snackbarService.showSnackbar(message: 'Todo updated');
    } catch (e) {
      print('❌ Error toggling todo: $e');
      _snackbarService.showSnackbar(message: 'Failed to update todo');
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      await _todoService.delete(id);
      _snackbarService.showSnackbar(message: 'Todo deleted');
    } catch (e) {
      print('❌ Error deleting todo: $e');
      _snackbarService.showSnackbar(message: 'Failed to delete todo');
    }
  }

  Future<void> clearCompleted() async {
    try {
      final completedCount = completed;
      if (completedCount == 0) {
        _snackbarService.showSnackbar(message: 'No completed todos to clear');
        return;
      }
      
      await _todoService.clearCompleted();
      _snackbarService.showSnackbar(message: 'Cleared $completedCount completed todos');
    } catch (e) {
      print('❌ Error clearing completed todos: $e');
      _snackbarService.showSnackbar(message: 'Failed to clear completed todos');
    }
  }
}

/// Simple custom dialog widget
class AddTodoDialog extends StatefulWidget {
  final Todo? existingTodo;
  
  const AddTodoDialog({Key? key, this.existingTodo}) : super(key: key);

  @override
  State<AddTodoDialog> createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends State<AddTodoDialog> {
  late TextEditingController titleController;
  late TextEditingController notesController;
  TaskPriority selectedPriority = TaskPriority.medium;
  TaskCategory selectedCategory = TaskCategory.personal;
  DateTime? selectedDueDate;

  @override
  void initState() {
    super.initState();
    
    // Initialize with existing todo data if editing
    if (widget.existingTodo != null) {
      titleController = TextEditingController(text: widget.existingTodo!.title);
      notesController = TextEditingController(text: widget.existingTodo!.notes);
      selectedPriority = widget.existingTodo!.priority;
      selectedCategory = widget.existingTodo!.category;
      selectedDueDate = widget.existingTodo!.dueDate;
    } else {
      titleController = TextEditingController();
      notesController = TextEditingController();
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingTodo != null ? 'Edit Todo' : 'Add New Todo'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TaskPriority>(
              value: selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: TaskPriority.values.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: priority.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(priority.label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedPriority = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TaskCategory>(
              value: selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: TaskCategory.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Row(
                    children: [
                      Icon(category.icon, size: 16),
                      const SizedBox(width: 8),
                      Text(category.label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedCategory = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedDueDate == null
                          ? 'No Due Date'
                          : '${selectedDueDate!.day}/${selectedDueDate!.month}/${selectedDueDate!.year}',
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDueDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedDueDate = picked;
                        });
                      }
                    },
                    child: const Text('Pick'),
                  ),
                  if (selectedDueDate != null)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          selectedDueDate = null;
                        });
                      },
                      icon: const Icon(Icons.clear, size: 16),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop({
              'title': titleController.text,
              'notes': notesController.text,
              'priority': selectedPriority,
              'category': selectedCategory,
              'dueDate': selectedDueDate,
            });
          },
          child: Text(widget.existingTodo != null ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}