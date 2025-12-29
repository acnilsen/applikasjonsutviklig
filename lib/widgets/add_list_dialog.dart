import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

/// Dialog to add a new list. Prompts the user to add a name for the new list.
class AddListDialog extends StatefulWidget {
  @override
  State<AddListDialog> createState() => _AddListDialogState();
}

/// State for the AddListDialog. This handles the input and adding of the new list.
class _AddListDialogState extends State<AddListDialog> {
  // Controller for the text field. Used to access the text entered by the user.
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();

    // Dialog to add a new list.
    return AlertDialog(
      title: Text("New List"),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(
          labelText: "Name of the new list",
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            final name = controller.text.trim();
            if (name.isNotEmpty) {
              appState.addList(name);
              Navigator.pop(context);
            }
          },
          child: Text("Create"),
        ),
      ],
    );
  }
}
