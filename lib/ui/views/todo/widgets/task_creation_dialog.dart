import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

class TaskCreationDialog extends StatefulWidget {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const TaskCreationDialog({
    super.key,
    required this.request,
    required this.completer,
  });

  @override
  State<TaskCreationDialog> createState() => _TaskCreationDialogState();
}

class _TaskCreationDialogState extends State<TaskCreationDialog> {
  late TextEditingController _titleController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _notesController = TextEditingController();
  }

  void _save() {
    widget.completer(
      DialogResponse(
        confirmed: true,
        data: {
          'titleController': _titleController,
          'notesController': _notesController,
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.request.title ?? "Add Todo"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: "Title"),
          ),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(labelText: "Notes"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => widget.completer(DialogResponse(confirmed: false)),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text("Save"),
        ),
      ],
    );
  }
}
