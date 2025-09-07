import 'package:hive/hive.dart';
import '../models/todo.dart';

class TodoService {
  static const String _boxName = 'todos';
  late Box<Todo> _todoBox;

  Future<void> init() async {
    _todoBox = Hive.box<Todo>(_boxName);  // Fixed: was *todoBox and *boxName
  }

  /// Todos list
  List<Todo> get todos => _todoBox.values.toList();

  /// Computed stats
  int get total => todos.length;
  int get completed => todos.where((t) => t.isCompleted).length;
  int get pending => todos.where((t) => !t.isCompleted).length;

  /// Watch todos for reactive UI
  Stream<List<Todo>> watchTodos() {
    return _todoBox.watch().map((_) => todos);  // Fixed: was *todoBox and (*)
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

  /// Clear completed todos (Missing method that TodoViewModel needs)
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
}