import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:stacked_todo_demo/app/app.locator.dart';
import '../../models/todo.dart';

void setupDialogUi() {
  final dialogService = locator<DialogService>();
  dialogService.registerCustomDialogBuilder(
    variant: DialogType.form,
    builder: (context, dialogRequest, onDialogTap) => FormDialog(
      request: dialogRequest,
      completion: onDialogTap,
    ),
  );
}

enum DialogType { form }

class FormDialog extends StatelessWidget {
  final DialogRequest request;
  final Function(DialogResponse) completion;

  const FormDialog({required this.request, required this.completion, super.key});

  @override
  Widget build(BuildContext context) {
    final titleController = request.customData['titleController'] as TextEditingController;
    final notesController = request.customData['notesController'] as TextEditingController;
    ValueNotifier<TaskPriority> priority = ValueNotifier(request.customData['priority'] as TaskPriority);
    ValueNotifier<TaskCategory> category = ValueNotifier(request.customData['category'] as TaskCategory);
    ValueNotifier<DateTime?> dueDate = ValueNotifier(request.customData['dueDate'] as DateTime?);

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(request.title ?? '', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<TaskPriority>(
              value: priority.value,
              decoration: const InputDecoration(labelText: 'Priority', border: OutlineInputBorder()),
              items: TaskPriority.values.map((p) => DropdownMenuItem(value: p, child: Text(p.label))).toList(),
              onChanged: (value) => priority.value = value!,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<TaskCategory>(
              value: category.value,
              decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
              items: TaskCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(c.label))).toList(),
              onChanged: (value) => category.value = value!,
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<DateTime?>(
              valueListenable: dueDate,
              builder: (context, value, child) => Row(
                children: [
                  Expanded(child: Text(value == null ? 'No Due Date' : value.toString().split(' ')[0])),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) dueDate.value = picked;
                    },
                    child: const Text('Pick Due Date'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => completion(DialogResponse(confirmed: false)),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => completion(DialogResponse(
                    confirmed: true,
                    data: {
                      'titleController': titleController,
                      'notesController': notesController,
                      'priority': priority.value,
                      'category': category.value,
                      'dueDate': dueDate.value,
                    },
                  )),
                  child: const Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}