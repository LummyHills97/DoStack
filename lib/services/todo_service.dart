import 'package:hive/hive.dart';
import '../models/todo.dart';

class TodoService {
  static const String _boxName = 'todos';
  late Box<Todo> _todoBox;

  /// Initialize Hive box
  Future<void> init() async {
    _todoBox = Hive.box<Todo>(_boxName);
  }

  /// Get all todos
  List<Todo> getTodos() {
    return _todoBox.values.toList();
  }

  /// Watch todos (for reactive UI)
  Stream<List<Todo>> watchTodos() {
    return _todoBox.watch().map((_) => getTodos());
  }

  /// Add new todo
  Future<void> addTodo(Todo todo) async {
    await _todoBox.put(todo.id, todo);
  }

  /// Update an existing todo
  Future<void> updateTodo(Todo todo) async {
    await _todoBox.put(todo.id, todo);
  }

  /// Delete todo
  Future<void> deleteTodo(String id) async {
    await _todoBox.delete(id);
  }

  /// Toggle completed state
  Future<void> toggleTodoComplete(String id) async {
    final todo = _todoBox.get(id);
    if (todo != null) {
      todo.isCompleted = !todo.isCompleted;
      await todo.save();
    }
  }

  /// Clear all todos
  Future<void> clearTodos() async {
    await _todoBox.clear();
  }
}
