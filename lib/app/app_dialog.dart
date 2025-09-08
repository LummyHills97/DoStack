import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import '../ui/views/todo/widgets/task_creation_dialog.dart';
import 'app.locator.dart';

enum DialogType { form }

void setupDialogUi() {
  final dialogService = locator<DialogService>();

  dialogService.registerCustomDialogBuilder(
    variant: DialogType.form,
    builder: (context, request, completer) => TaskCreationDialog(
      request: request,
      completer: completer,
    ),
  );
}
