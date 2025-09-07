import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:stacked_todo_demo/app/app.locator.dart';
import '../../models/todo.dart';

enum DialogType { form }

void setupDialogUi() {
  final dialogService = locator<DialogService>();

  dialogService.registerCustomDialogBuilder(
    variant: DialogType.form,
    builder: (context, request, completer) => FormDialog(
      request: request,
      completer: completer,
    ),
  );
}

/// Custom Form Dialog
class FormDialog extends StatefulWidget {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const FormDialog({
    super.key,
    required this.request,
    required this.completer,
  });

  @override
  State<FormDialog> createState() => _FormDialogState();
}

class _FormDialogState extends State<FormDialog> {
  late final TextEditingController titleController;
  late final TextEditingController notesController;
  late TaskPriority priority;
  late TaskCategory category;
  DateTime? dueDate;

  @override
  void initState() {
    super.initState();
    final data = widget.request.customData ?? {};
    titleController = data['titleController'] ?? TextEditingController();
    notesController = data['notesController'] ?? TextEditingController();
    priority = data['priority'] ?? TaskPriority.medium;
    category = data['category'] ?? TaskCategory.personal;
    dueDate = data['dueDate'];
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.request.title ?? 'Todo',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),

              /// Title
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 12),

              /// Notes
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),

              /// Priority
              DropdownButtonFormField<TaskPriority>(
                value: priority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: TaskPriority.values.map((p) {
                  return DropdownMenuItem(
                    value: p,
                    child: Row(
                      children: [
                        CircleAvatar(radius: 6, backgroundColor: p.color),
                        const SizedBox(width: 8),
                        Text(p.label),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => priority = val!),
              ),
              const SizedBox(height: 12),

              /// Category
              DropdownButtonFormField<TaskCategory>(
                value: category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: TaskCategory.values.map((c) {
                  return DropdownMenuItem(
                    value: c,
                    child: Row(
                      children: [Icon(c.icon, size: 16), const SizedBox(width: 8), Text(c.label)],
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => category = val!),
              ),
              const SizedBox(height: 12),

              /// Due Date
              Row(
                children: [
                  Expanded(
                    child: Text(
                      dueDate == null
                          ? 'No Due Date'
                          : '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}',
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: dueDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() => dueDate = picked);
                      }
                    },
                    child: const Text('Pick Date'),
                  ),
                  if (dueDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => dueDate = null),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              /// Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => widget.completer(DialogResponse(confirmed: false)),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      widget.completer(DialogResponse(
                        confirmed: true,
                        data: {
                          'titleController': titleController,
                          'notesController': notesController,
                          'priority': priority,
                          'category': category,
                          'dueDate': dueDate,
                        },
                      ));
                    },
                    child: Text(widget.request.title?.contains('Edit') == true ? 'Update' : 'Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
