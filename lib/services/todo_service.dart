import 'package:injectable/injectable.dart';
import 'package:stacked/stacked.dart';
import '../models/todo.dart';

@lazySingleton
class TodoService with ListenableServiceMixin {
  TodoService() {
    listenToReactiveValues([_todos]);
  }

  final ReactiveValue<List<Todo>> _todos = ReactiveValue<List<Todo>>([]);

  List<Todo> get todos => _todos.value;

  void add(String title) {
    if (title.trim().isEmpty) return;
    final todo = Todo(id: DateTime.now().toString(), title: title.trim());
    _todos.value = [..._todos.value, todo];
  }

  void toggle(String id) {
    _todos.value = _todos.value.map((todo) =>
      todo.id == id ? todo.copyWith(isCompleted: !todo.isCompleted) : todo
    ).toList();
  }

  void delete(String id) {
    _todos.value = _todos.value.where((t) => t.id != id).toList();
  }

  void clearCompleted() {
    _todos.value = _todos.value.where((t) => !t.isCompleted).toList();
  }

  int get completed => _todos.value.where((t) => t.isCompleted).length;
  int get pending => _todos.value.where((t) => !t.isCompleted).length;
  int get total => _todos.value.length;
}