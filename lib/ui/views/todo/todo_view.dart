import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_todo_demo/models/todo.dart';
import 'todo_viewmodel.dart';
 // Make sure to import your Todo model

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
            _buildInput(model),
            const Divider(height: 1),
            Expanded(child: _buildEnhancedTodoList(model)),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedStats(TodoViewModel model) => Container(
    padding: const EdgeInsets.all(16),
    color: Colors.grey.shade100,
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statTile('Total', model.total, Colors.indigo),
            _statTile('Pending', model.pending, Colors.orange),
            _statTile('Completed', model.completed, Colors.green),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statTile('Overdue', model.overdue, Colors.red),
            _statTile('Due Today', model.dueToday, Colors.purple),
            _statTile('Habits', model.todos.where((t) => model.isRecurring(t)).length, Colors.green),
          ],
        ),
      ],
    ),
  );

  Widget _statTile(String label, int value, Color color) => Column(
    children: [
      Text(
        '$value',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
      ),
      Text(label, style: const TextStyle(fontSize: 11)),
    ],
  );

  Widget _buildInput(TodoViewModel model) => Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: model.textController,
            maxLength: 100,
            decoration: const InputDecoration(
              hintText: 'New task...',
              counterText: '',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.add_task),
            ),
            onSubmitted: (_) => model.addTodo(),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: model.addTodo,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),
          child: const Text('Add'),
        ),
      ],
    ),
  );

  Widget _buildEnhancedTodoList(TodoViewModel model) => ListView.builder(
    itemCount: model.todos.length,
    itemBuilder: (context, index) {
      final todo = model.todos[index];
      return _buildEnhancedTodoCard(model, todo);
    },
  );

  Widget _buildEnhancedTodoCard(TodoViewModel model, Todo todo) { // Changed from dynamic to Todo
    final isOverdue = model.isOverdue(todo);
    final isDueToday = model.isDueToday(todo);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: isOverdue
          ? Colors.red.shade50
          : isDueToday
              ? Colors.purple.shade50
              : todo.isCompleted
                  ? Colors.green.shade50
                  : Colors.white,
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: todo.isCompleted,
              onChanged: (_) => model.toggle(todo.id),
            ),
            // Priority indicator
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: model.getPriorityColor(todo),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        title: Text(
          todo.title.isNotEmpty ? todo.title : 'Untitled Todo',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: todo.isCompleted ? Colors.green[800] : Colors.black87,
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Category
                Icon(model.getCategoryIcon(todo), size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(model.getCategoryLabel(todo), style: const TextStyle(fontSize: 12)),
                
                // Due date
                if (model.getDueDateString(todo).isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: isOverdue ? Colors.red : isDueToday ? Colors.purple : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    model.getDueDateString(todo),
                    style: TextStyle(
                      fontSize: 12,
                      color: isOverdue ? Colors.red : isDueToday ? Colors.purple : Colors.grey,
                      fontWeight: isOverdue || isDueToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
                
                // Time spent
                if (model.getTimeSpent(todo).isNotEmpty) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.timer, size: 14, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(model.getTimeSpent(todo), style: const TextStyle(fontSize: 12)),
                ],
                
                // Recurring indicator
                if (model.isRecurring(todo)) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.repeat, size: 14, color: Colors.green),
                  Text('${model.getStreakCount(todo)}', style: const TextStyle(fontSize: 12)),
                ],
              ],
            ),
            
            // Subtask progress
            if (model.hasSubTasks(todo))
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: LinearProgressIndicator(
                  value: model.getSubTaskProgress(todo),
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    model.getSubTaskProgress(todo) == 1.0 ? Colors.green : Colors.blue,
                  ),
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => model.delete(todo.id),
        ),
      ),
    );
  }
}