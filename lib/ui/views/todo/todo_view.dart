import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'todo_viewmodel.dart';
import '../../../models/todo.dart';

class TodoView extends StatelessWidget {
  const TodoView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<TodoViewModel>.reactive(
      viewModelBuilder: () => TodoViewModel(),
      builder: (context, model, _) => Scaffold(
        appBar: AppBar(
          title: const Text('DoStack - Enhanced Todo'),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          actions: [
            if (model.completed > 0)
              IconButton(
                icon: const Icon(Icons.clear_all),
                onPressed: model.clearCompleted,
                tooltip: 'Clear Completed',
              ),
          ],
        ),
        body: Column(
          children: [
            _buildStats(model),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => model.addTodo(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Add New Todo'),
              ),
            ),
            const Divider(),
            Expanded(child: _buildTodoList(context, model)),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(TodoViewModel model) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _statTile('Total', model.total.toString()),
          _statTile('Completed', model.completed.toString()),
          _statTile('Pending', model.pending.toString()),
          _statTile('Due Today', model.dueToday.toString()),
          _statTile('Overdue', model.overdue.toString()),
        ],
      ),
    );
  }

  Widget _statTile(String label, String value) => Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      );

  Widget _buildTodoList(BuildContext context, TodoViewModel model) {
    if (model.todos.isEmpty) {
      return const Center(child: Text('No todos yet — add one!'));
    }

    return ListView.separated(
      itemCount: model.todos.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (_, index) {
        final todo = model.todos[index];
        return Dismissible(
          key: Key(todo.id),
          background: _dismissBg(left: true),
          secondaryBackground: _dismissBg(),
          onDismissed: (_) => model.deleteTodo(todo.id),
          child: ListTile(
            onTap: () => model.editTodo(context, todo),
            leading: Checkbox(
              value: todo.isCompleted,
              onChanged: (_) => model.toggleComplete(todo.id),
            ),
            title: Text(
              todo.title,
              style: TextStyle(
                decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: _buildSubtitle(todo),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showMenu(context, model, todo),
            ),
          ),
        );
      },
    );
  }

  Widget _dismissBg({bool left = false}) => Container(
        color: Colors.redAccent,
        alignment: left ? Alignment.centerLeft : Alignment.centerRight,
        padding: EdgeInsets.only(left: left ? 16 : 0, right: left ? 0 : 16),
        child: const Icon(Icons.delete, color: Colors.white),
      );

  Widget _buildSubtitle(Todo todo) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (todo.notes.isNotEmpty) Text(todo.notes),
          Row(
            children: [
              Text(todo.priority.label, style: TextStyle(color: todo.priority.color)),
              const SizedBox(width: 8),
              Text('· ${todo.category.label}'),
              if (todo.dueDate != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text('· Due ${todo.dueDate!.day}/${todo.dueDate!.month}/${todo.dueDate!.year}'),
                ),
            ],
          ),
        ],
      );

  void _showMenu(BuildContext context, TodoViewModel model, Todo todo) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                model.editTodo(context, todo);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                model.deleteTodo(todo.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
