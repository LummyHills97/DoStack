import 'package:flutter/material.dart';
import 'package:stacked_todo_demo/models/todo.dart';


class TaskCreationDialog extends StatefulWidget {
  final Todo? initialTodo;
  final Function(Todo) onSave;

  const TaskCreationDialog({
    super.key,
    this.initialTodo,
    required this.onSave,
  });

  @override
  State<TaskCreationDialog> createState() => _TaskCreationDialogState();
}

class _TaskCreationDialogState extends State<TaskCreationDialog> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  
  TaskPriority _selectedPriority = TaskPriority.medium;
  TaskCategory _selectedCategory = TaskCategory.personal;
  DateTime? _selectedDueDate;
  bool _isRecurring = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialTodo != null) {
      final todo = widget.initialTodo!;
      _titleController.text = todo.title;
      _notesController.text = todo.notes;
      _selectedPriority = todo.priority;
      _selectedCategory = todo.category;
      _selectedDueDate = todo.dueDate;
      _isRecurring = todo.isRecurring;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.initialTodo != null ? 'Edit Task' : 'Create New Task',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Title field
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title *',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            
            // Notes field
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              minLines: 1,
            ),
            const SizedBox(height: 20),
            
            // Priority selection
            const Text('Priority', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: TaskPriority.values.map((priority) => 
                Expanded(
                  child: RadioListTile<TaskPriority>(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      priority.label,
                      style: TextStyle(fontSize: 12, color: priority.color),
                    ),
                    value: priority,
                    groupValue: _selectedPriority,
                    onChanged: (value) => setState(() => _selectedPriority = value!),
                    activeColor: priority.color,
                  ),
                ),
              ).toList(),
            ),
            const SizedBox(height: 16),
            
            // Category selection
            const Text('Category', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<TaskCategory>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: TaskCategory.values.map((category) => 
                DropdownMenuItem(
                  value: category,
                  child: Row(
                    children: [
                      Icon(category.icon, size: 20),
                      const SizedBox(width: 8),
                      Text(category.label),
                    ],
                  ),
                ),
              ).toList(),
              onChanged: (value) => setState(() => _selectedCategory = value!),
            ),
            const SizedBox(height: 16),
            
            // Due date selection
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDueDate != null 
                        ? 'Due: ${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'
                        : 'No due date',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton.icon(
                  onPressed: _selectDueDate,
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Set Date'),
                ),
                if (_selectedDueDate != null)
                  IconButton(
                    onPressed: () => setState(() => _selectedDueDate = null),
                    icon: const Icon(Icons.clear),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Recurring toggle
            Row(
              children: [
                Checkbox(
                  value: _isRecurring,
                  onChanged: (value) => setState(() => _isRecurring = value!),
                ),
                const Text('Make this a recurring habit'),
                const Spacer(),
                Icon(
                  Icons.repeat,
                  color: _isRecurring ? Colors.green : Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(widget.initialTodo != null ? 'Update' : 'Create'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() => _selectedDueDate = date);
    }
  }

  void _saveTask() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task title')),
      );
      return;
    }

    final todo = Todo(
      id: widget.initialTodo?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      notes: _notesController.text.trim(),
      priority: _selectedPriority,
      category: _selectedCategory,
      dueDate: _selectedDueDate,
      isRecurring: _isRecurring,
      // Preserve existing data when editing
      isCompleted: widget.initialTodo?.isCompleted ?? false,
      subTasks: widget.initialTodo?.subTasks ?? [],
      timeSpentMinutes: widget.initialTodo?.timeSpentMinutes ?? 0,
      streakCount: widget.initialTodo?.streakCount ?? 0,
    );

    widget.onSave(todo);
    Navigator.of(context).pop();
  }
}