import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:stacked_todo_demo/app/app.locator.dart';
import '../../models/todo.dart';

void setupDialogUi() {
  print('🔧 Setting up dialog UI...');
  
  try {
    final dialogService = locator<DialogService>();
    print('✅ Got DialogService from locator');
    
    dialogService.registerCustomDialogBuilder(
      variant: DialogType.form,
      builder: (context, dialogRequest, onDialogTap) {
        print('🏗️ Building FormDialog...');
        return FormDialog(
          request: dialogRequest,
          completion: onDialogTap,
        );
      },
    );
    
    print('✅ Dialog builder registered successfully');
  } catch (e) {
    print('❌ Error setting up dialog UI: $e');
  }
}

enum DialogType { form }

class FormDialog extends StatefulWidget {
  final DialogRequest request;
  final Function(DialogResponse) completion;

  const FormDialog({required this.request, required this.completion, super.key});

  @override
  State<FormDialog> createState() => _FormDialogState();
}

class _FormDialogState extends State<FormDialog> {
  late TextEditingController titleController;
  late TextEditingController notesController;
  late TaskPriority selectedPriority;
  late TaskCategory selectedCategory;
  DateTime? selectedDueDate;

  @override
  void initState() {
    super.initState();
    titleController = widget.request.customData['titleController'] as TextEditingController;
    notesController = widget.request.customData['notesController'] as TextEditingController;
    selectedPriority = widget.request.customData['priority'] as TaskPriority;
    selectedCategory = widget.request.customData['category'] as TaskCategory;
    selectedDueDate = widget.request.customData['dueDate'] as DateTime?;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.request.title ?? '',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<TaskPriority>(
              value: selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: TaskPriority.values
                  .map((p) => DropdownMenuItem(
                        value: p,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: p.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(p.label),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedPriority = value;
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<TaskCategory>(
              value: selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: TaskCategory.values
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Row(
                          children: [
                            Icon(c.icon, size: 16),
                            const SizedBox(width: 8),
                            Text(c.label),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedCategory = value;
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedDueDate == null
                          ? 'No Due Date'
                          : '${selectedDueDate!.day}/${selectedDueDate!.month}/${selectedDueDate!.year}',
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDueDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedDueDate = picked;
                        });
                      }
                    },
                    child: const Text('Pick Date'),
                  ),
                  if (selectedDueDate != null)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          selectedDueDate = null;
                        });
                      },
                      icon: const Icon(Icons.clear, size: 16),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    widget.completion(DialogResponse(confirmed: false));
                  },
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    widget.completion(DialogResponse(
                      confirmed: true,
                      data: {
                        'titleController': titleController,
                        'notesController': notesController,
                        'priority': selectedPriority,
                        'category': selectedCategory,
                        'dueDate': selectedDueDate,
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
    );
  }
}