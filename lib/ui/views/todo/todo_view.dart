import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'todo_viewmodel.dart';

class TodoView extends StatelessWidget {
  const TodoView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<TodoViewModel>.reactive(
      viewModelBuilder: () => TodoViewModel(),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Todo App'),
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
            _buildInput(model),
            const Divider(height: 1),
            Expanded(child: _buildTodoList(model)),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(TodoViewModel model) => Container(
        padding: const EdgeInsets.all(16),
        color: Colors.grey.shade100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statTile('Total', model.total, Colors.indigo),
            _statTile('Pending', model.pending, Colors.orange),
            _statTile('Completed', model.completed, Colors.green),
          ],
        ),
      );

  Widget _statTile(String label, int value, Color color) => Column(
        children: [
          Text(
            '$value',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      );

  Widget _buildInput(TodoViewModel model) => Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: model.textController,
                maxLength: 50,
                decoration: const InputDecoration(
                  hintText: 'New todo...',
                  counterText: '',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => model.addTodo(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: model.addTodo,
              child: const Text('Add'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );

  Widget _buildTodoList(TodoViewModel model) => ListView.builder(
        itemCount: model.todos.length,
        itemBuilder: (context, index) {
          final todo = model.todos[index];
          final isCompleted = todo.isCompleted;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green[100] : Colors.orange[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: Checkbox(
                value: isCompleted,
                onChanged: (_) => model.toggle(todo.id),
              ),
             title: Text(
                  todo.title.isNotEmpty ? todo.title : 'Untitled Todo',
                  style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isCompleted ? Colors.green[800] : Colors.black87,
                 decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
  ),
),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => model.delete(todo.id),
              ),
            ),
          );
        },
      );
}
