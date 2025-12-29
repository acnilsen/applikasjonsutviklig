import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/shopping_item.dart';

/// AppState is a class that manages the state of the app
/// it handles saving and loading of the lists to disk
/// and also provides access to the current list
/// ChangeNotifier is used to notify listeners when the state changes
class AppState extends ChangeNotifier {
  List<ShoppingList> shoppingLists = []; // List of all lists
  ShoppingList? currentList; // the current active list, or null if none
  bool _isLoading = true; // Whether the app is loading data from disk

  // the constructor is called when the app is starts
  AppState() {
    _loadLists();
  }

  bool get isLoading => _isLoading;

  // -----------------------------
  // File helpers
  // -----------------------------

  // Get the documents directory for the app
  Future<Directory> _getDocumentsDir() async =>
      await getApplicationDocumentsDirectory();

  // Get the file for a list based on its ID
  Future<File> _fileForList(ShoppingList list) async {
    final dir = await _getDocumentsDir();
    return File('${dir.path}/${list.id}.json');
  }

  // Save a list to disk, 'flush' means write to disk immediately
  Future<void> _saveList(ShoppingList list) async {
    final file = await _fileForList(list);
    await file.writeAsString(jsonEncode(list.toJson()), flush: true);
  }

  // -----------------------------
  // Load lists from disk
  // -----------------------------
  Future<void> _loadLists() async {
    _isLoading = true;
    notifyListeners();

    final dir = await _getDocumentsDir();
    // Get all files in the directory that end with '.json'
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'));

    shoppingLists = []; // Clear the list before refilling it

    for (final f in files) {
      try {
        final data = jsonDecode(await f.readAsString());
        final list = ShoppingList.fromJson(data);
        shoppingLists.add(list);
      } catch (_) {} // ignore errors
    }

    // If there are existing lists, but no active list, set the first one as active
    if (shoppingLists.isNotEmpty) {
      currentList ??= shoppingLists.first;
    }

    _isLoading = false; // Done loading
    notifyListeners(); // Notify listeners that the state has changed
  }

  // -----------------------------
  // List management
  // -----------------------------

  // Add a new list to the list
  void addList(String title) {
    final list = ShoppingList.create(title);
    shoppingLists.add(list);
    currentList = list; // Set the new list as active
    _saveList(list);
    notifyListeners();
  }

  // Remove a list
  void removeList(ShoppingList list) async {
    shoppingLists.remove(list); // Removes it from the memory

    // Delete the file on disk
    final file = await _fileForList(list);
    if (await file.exists()) {
      await file.delete();
    }

    // Set the current list to the first in the list, or null if empty
    if (shoppingLists.isNotEmpty) {
      currentList = shoppingLists.first;
    } else {
      currentList = null;
    }

    notifyListeners();
  }

  // Set the current list
  void setCurrentList(ShoppingList list) {
    currentList = list;
    notifyListeners();
  }

  // Get a list by ID
  ShoppingList? getListById(String id) {
    try {
      return shoppingLists.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  // -----------------------------
  // Item handling
  // -----------------------------

  // Add a new item to the current list
  void addItem(String name) {
    if (currentList == null || name.isEmpty) return; // Cancels if no list or empty name

    currentList!.items.insert(0,ListItem.create(name));
    _saveList(currentList!);
    notifyListeners();
  }

  // Toggle the checked status of an item
  void toggleItem(ListItem item) {
    if (currentList == null) return;

    final list = currentList!;
    final idx = list.items.indexOf(item);
    if (idx == -1) return; // Cancels if item not found

    // Changes checked status
    item.isChecked = !item.isChecked;

    if (item.isChecked) {
      list.items.removeAt(idx);
      list.items.add(item);
    }

    _saveList(list);
    notifyListeners();
  }

  // Delete an item from the current list
  void removeItem(ListItem item) {
    if (currentList == null) return;

    currentList!.items.remove(item);
    _saveList(currentList!);
    notifyListeners();
  }

  // -----------------------------
  // Sorted views for UI
  // -----------------------------
  List<ListItem> get uncheckedItems {
    if (currentList == null) return [];
    return currentList!.items.where((i) => !i.isChecked).toList();
  }

  List<ListItem> get checkedItems {
    if (currentList == null) return [];
    return currentList!.items.where((i) => i.isChecked).toList();
  }

  /// Moves an item manually. This is the original method.
  void moveItemBefore(String itemId, String? beforeItemId) {
    if (currentList == null) return;
    final list = currentList!;

    final fromIndex = list.items.indexWhere((i) => i.id == itemId);
    if (fromIndex == -1) return;

    final item = list.items.removeAt(fromIndex);

    if (beforeItemId == null) {
      list.items.add(item);
    } else {
      final insertIndex = list.items.indexWhere((i) => i.id == beforeItemId);
      if (insertIndex != -1) {
        list.items.insert(insertIndex, item);
      } else {
        list.items.add(item); // Safety fallback
      }
    }
    _saveList(list);
    notifyListeners();
  }


  /// Special-purpose method for handling drag-and-drop from the UI.
  /// It delays the UI notification to prevent conflicts with widget animations.
  void reorderItem(String itemId, String? beforeItemId) {
    if (currentList == null) return;
    final list = currentList!;

    final fromIndex = list.items.indexWhere((i) => i.id == itemId);
    if (fromIndex == -1) return;

    final item = list.items.removeAt(fromIndex);

    if (beforeItemId == null) {
      list.items.add(item); // Add to the end
    } else {
      final insertIndex = list.items.indexWhere((i) => i.id == beforeItemId);
      if (insertIndex != -1) {
        list.items.insert(insertIndex, item);
      } else {
        list.items.add(item); // Safety fallback
      }
    }

    Future.microtask(() {
      _saveList(list);
      notifyListeners();
    });
  }

  ThemeMode themeMode = ThemeMode.system;

  void toggleTheme() {
    if (themeMode == ThemeMode.light) {
      themeMode = ThemeMode.dark;
    } else {
      themeMode = ThemeMode.light;
    }
    notifyListeners();
  }
}
