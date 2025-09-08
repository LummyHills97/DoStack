import 'package:hive/hive.dart';
import '../models/todo.dart';

class TodoService {
  static const String _boxName = 'todos';
  late Box<Todo> _todoBox; // FIXED: removed asterisks

  Future<void> init() async {
    _todoBox = Hive.box<Todo>(_boxName); // FIXED: removed asterisks
  }

  /// Todos list
  List<Todo> get todos => _todoBox.values.toList();

  /// Computed stats
  int get total => todos.length;
  int get completed => todos.where((t) => t.isCompleted).length;
  int get pending => todos.where((t) => !t.isCompleted).length;

  /// Watch todos for reactive UI
  Stream<List<Todo>> watchTodos() {
    return _todoBox.watch().map((_) => todos); // FIXED: removed asterisks and used proper underscore
  }

  /// Add new todo
  Future<void> add(Todo todo) async {
    await _todoBox.put(todo.id, todo);
  }

  /// Update todo
  Future<void> update(Todo todo) async {
    await _todoBox.put(todo.id, todo);
  }

  /// Delete todo
  Future<void> delete(String id) async {
    await _todoBox.delete(id);
  }

  /// Toggle completed
  Future<void> toggleComplete(String id) async {
    final todo = _todoBox.get(id);
    if (todo != null) {
      todo.isCompleted = !todo.isCompleted;
      await todo.save();
    }
  }

  /// Clear completed todos
  Future<void> clearCompleted() async {
    final completedTodos = todos.where((t) => t.isCompleted).toList();
    for (final todo in completedTodos) {
      await _todoBox.delete(todo.id);
    }
  }

  /// Clear all
  Future<void> clear() async {
    await _todoBox.clear();
  }

  /// Get todo by ID
  Todo? getTodo(String id) {
    return _todoBox.get(id);
  }

  /// Search todos
  List<Todo> search(String query) {
    if (query.trim().isEmpty) return todos;
    
    return todos.where((todo) {
      return todo.title.toLowerCase().contains(query.toLowerCase()) ||
             (todo.notes?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();
  }

  /// Get todos by completion status
  List<Todo> getTodosByStatus(bool isCompleted) {
    return todos.where((todo) => todo.isCompleted == isCompleted).toList();
  }
}
