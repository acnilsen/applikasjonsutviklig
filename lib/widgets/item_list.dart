import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/shopping_item.dart';
import '../providers/app_state.dart';

/// Widget for displaying a list of items, separated into two reorderable sections.
class ItemList extends StatefulWidget {
  final ShoppingList list;
  const ItemList({super.key, required this.list});

  @override
  State<ItemList> createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
  late final ScrollController _uncheckedController;
  late final ScrollController _checkedController;

  @override
  void initState() {
    super.initState();
    _uncheckedController = ScrollController();
    _checkedController = ScrollController();
  }

  @override
  void dispose() {
    _uncheckedController.dispose();
    _checkedController.dispose();
    super.dispose();
  }

  // --- Helper method for the onReorder callback ---
  void _handleReorder(
      int oldIndex,
      int newIndex,
      List<ListItem> list,
      AppState appState,
      ) {
    final isMovingToEnd = newIndex == list.length;

    if (!isMovingToEnd && newIndex > oldIndex) {
      newIndex -= 1;
    }

    // Now if moving to the end:
    final String? beforeId =
    isMovingToEnd ? null : list[newIndex].id;

    // IMPORTANT: always perform the reorder if index changed OR if moving to end
    if (oldIndex != newIndex || isMovingToEnd) {
      appState.reorderItem(list[oldIndex].id, beforeId);
    }
  }


  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    // Separate items into two lists based on their 'isChecked' status.
    final unchecked = widget.list.items.where((i) => !i.isChecked).toList();
    final checked = widget.list.items.where((i) => i.isChecked).toList();

    if (unchecked.isEmpty && checked.isEmpty) {
      return const Center(child: Text('No items in this list.'));
    }

    return Column(
      children: [
        // --- "To buy" Section ---
        _buildSectionHeader(context, 'To buy', unchecked.length),
        Expanded(
          child: unchecked.isEmpty
              ? const Center(child: Text('No items to buy.'))
              : _buildReorderableList(
              context: context,
              list: unchecked,
              controller: _uncheckedController,
              appState: appState),
        ),

        const Divider(height: 1),

        // --- "Bought" Section ---
        _buildSectionHeader(context, 'Bought', checked.length),
        Expanded(
          child: checked.isEmpty
              ? const Center(child: Text('No bought items.'))
              : _buildReorderableList(
              context: context,
              list: checked,
              controller: _checkedController,
              appState: appState,
              isCheckedList: true),
        ),
      ],
    );
  }

  // --- Helper widget for building the section header ---
  Widget _buildSectionHeader(BuildContext context, String title, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          Text('$count'),
        ],
      ),
    );
  }

  // --- Helper widget for building a reorderable list ---
  Widget _buildReorderableList({
    required BuildContext context,
    required List<ListItem> list,
    required ScrollController controller,
    required AppState appState,
    bool isCheckedList = false,
  }) {
    return Scrollbar(
      controller: controller,
      thumbVisibility: true,
      child: ReorderableListView.builder(
        key: PageStorageKey(isCheckedList ? 'checked' : 'unchecked'),
        scrollController: controller,
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: list.length,
        onReorder: (oldIndex, newIndex) =>
            _handleReorder(oldIndex, newIndex, list, appState),
        itemBuilder: (context, index) {
          final item = list[index];
          return Dismissible(
            key: ValueKey(item.id), // IMPORTANT: Use ValueKey for Dismissible
            direction: DismissDirection.endToStart,
            onDismissed: (_) => appState.removeItem(item),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20.0),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: ListTile(
              leading: Checkbox(
                value: item.isChecked,
                onChanged: (_) => appState.toggleItem(item),
              ),
              title: Text(
                item.name,
                style: isCheckedList
                    ? const TextStyle(
                    decoration: TextDecoration.lineThrough, color: Colors.grey)
                    : null,
              ),
              trailing: const Icon(Icons.drag_handle),
            ),
          );
        },
      ),
    );
  }
}
