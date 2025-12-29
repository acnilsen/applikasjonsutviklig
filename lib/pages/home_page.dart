import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/item_input_field.dart';
import '../widgets/item_list.dart';
import '../widgets/add_list_dialog.dart';

/// Homepage is the main page in the app.
class HomePage extends StatelessWidget {
  /// A pretty custom AppBar used across the whole page.
  PreferredSizeWidget buildPrettyAppBar(
      BuildContext context, {
        required String title,
        List<Widget>? actions,
        PreferredSizeWidget? bottom,
      }) {
    return AppBar(
      elevation: 3,
      centerTitle: true,
      title: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 22,
            letterSpacing: 0.3,
          ),
        ),
      ),
      actions: actions,
      bottom: bottom ??
          PreferredSize(
            preferredSize: const Size.fromHeight(3),
            child: Container(
              height: 3,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final lists = appState.shoppingLists;

    // --- No lists yet
    if (lists.isEmpty) {
      return Scaffold(
        appBar: buildPrettyAppBar(
          context,
          title: "Shopping lists",
        ),
        body: Center(
          child: ElevatedButton.icon(
            icon: Icon(Icons.add),
            label: Text("Create your first list"),
            onPressed: () => showDialog(
              context: context,
              builder: (_) => AddListDialog(),
            ),
          ),
        ),
      );
    }

    // --- Lists exist: show TabBar
    return DefaultTabController(
      length: lists.length + 1,
      child: Scaffold(
        appBar: buildPrettyAppBar(
          context,
          title: "My lists",
          actions: [
            // Light/dark mode toggle
            IconButton(
              icon: Icon(
                Theme.of(context).brightness == Brightness.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              onPressed: () {
                context.read<AppState>().toggleTheme();
              },
            ),

            // Delete list menu
            if (appState.currentList != null)
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'delete') {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text('Delete list?'),
                        content: Text(
                            'Are you sure you want to delete the current list and all its items?'),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, false),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, true),
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true && context.mounted) {
                      context.read<AppState>().removeList(appState.currentList!);                    }
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: const [
                        Icon(Icons.delete, color: Colors.redAccent),
                        SizedBox(width: 8),
                        Text(
                          'Delete current list',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],

          // Bottom TabBar
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              for (final list in lists)
                Tab(
                  key: ValueKey('tab-${list.id}'),
                  text: list.title,
                ),
              const Tab(icon: Icon(Icons.add)),
            ],
            onTap: (index) {
              if (index == lists.length) {
                final currentContext = context;
                Future.microtask(() {
                  if (currentContext.mounted) {
                    showDialog(
                      context: context,
                      builder: (_) => AddListDialog(),
                    );
                  }
                });
              } else {
                appState.setCurrentList(lists[index]);
              }
            },
          ),
        ),

        // Body with actual list views
        body: TabBarView(
          children: [
            for (final list in lists)
              _ShoppingListView(listId: list.id),

            // Dummy page for '+'
            const Center(
              child: Text("Create a new list by tapping +"),
            ),
          ],
        ),
      ),
    );
  }
}

/// A view representing a single list.
class _ShoppingListView extends StatelessWidget {
  final String listId;

  const _ShoppingListView({required this.listId});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final list = appState.getListById(listId);

    if (list == null) {
      return Center(child: Text("List not found"));
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(12),
          child: ItemInputField(),
        ),
        Expanded(
          child: ItemList(list: list),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
