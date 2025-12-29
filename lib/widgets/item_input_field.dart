import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

/// Widget for adding new items to a list.
class ItemInputField extends StatefulWidget {
  @override
  ItemInputFieldState createState() => ItemInputFieldState();
}

/// State for the ItemInputField.
class ItemInputFieldState extends State<ItemInputField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  void _addItem(BuildContext context) {
    final appState = context.read<AppState>();
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      appState.addItem(text);
      _controller.clear();
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding (
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: const InputDecoration(
                labelText: 'Add new Item',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _addItem(context),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => _addItem(context),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}