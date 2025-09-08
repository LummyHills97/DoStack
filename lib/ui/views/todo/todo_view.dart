// lib/ui/views/todo/todo_view.dart
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_todo_demo/models/todo.dart';
import 'todo_viewmodel.dart';


class TodoView extends StatelessWidget {
  const TodoView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<TodoViewModel>.reactive(
      viewModelBuilder: () => TodoViewModel(),
      builder: (context, model, child) => Scaffold(
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
            _buildEnhancedStats(model),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: model.addTodo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Add New Todo'),
              ),
            ),
            const Divider(height: 1),
            Expanded(child: _buildEnhancedTodoList(model)),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedStats(TodoViewModel model) {
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

  Widget _statTile(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildEnhancedTodoList(TodoViewModel model) {
    final items = model.todos;
    if (items.isEmpty) {
      return const Center(child: Text('No todos yet — add one!'));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final todo = items[index];
        return Dismissible(
          key: Key(todo.id),
          background: Container(color: Colors.redAccent, alignment: Alignment.centerLeft, padding: const EdgeInsets.only(left: 16), child: const Icon(Icons.delete, color: Colors.white)),
          secondaryBackground: Container(color: Colors.redAccent, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 16), child: const Icon(Icons.delete, color: Colors.white)),
          onDismissed: (_) => model.deleteTodo(todo.id),
          child: ListTile(
            onTap: () => model.editTodo(todo),
            leading: Checkbox(
              value: todo.isCompleted,
              onChanged: (_) => model.toggleComplete(todo.id),
            ),
            title: Text(todo.title, style: TextStyle(decoration: todo.isCompleted ? TextDecoration.lineThrough : null)),
            subtitle: Column(
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
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text('· Due ${todo.dueDate!.day}/${todo.dueDate!.month}/${todo.dueDate!.year}'),
                      ),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showTodoMenu(context, model, todo),
            ),
          ),
        );
      },
    );
  }

  void _showTodoMenu(BuildContext context, TodoViewModel model, Todo todo) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                model.editTodo(todo);
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
