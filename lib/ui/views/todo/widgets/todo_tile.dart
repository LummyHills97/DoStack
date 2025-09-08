import 'package:flutter/material.dart';
import 'package:stacked_todo_demo/models/todo.dart';

class TodoTile extends StatelessWidget {
  final Todo todo;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TodoTile({
    Key? key,
    required this.todo,
    this.onTap,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: (_) => onTap?.call(),
        ),
        title: Text(
          todo.title,
          maxLines: 1, // prevent long text from overflowing
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            decoration: todo.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        subtitle: todo.notes != null && todo.notes!.isNotEmpty
            ? Text(
                todo.notes!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
