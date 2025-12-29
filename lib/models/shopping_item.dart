/// Model representing an element in a shopping list.
class ListItem {
  final String id;
  String name;
  bool isChecked;

  // Constructor for creating a new item
  ListItem(this.id, this.name, {this.isChecked = false});

  // Factory constructor for creating a new item from only a name
  factory ListItem.create(String name) => ListItem(
    // Generates a unique ID using the current timestamp
    DateTime.now().millisecondsSinceEpoch.toString(),
    name
  );

  // Converts the item to a JSON object for storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'isChecked': isChecked,
  };

  // Factory constructor for creating an item from a JSON object
  factory ListItem.fromJson(Map<String, dynamic> json) => ListItem(
    json['id'] as String,
    json['name'] as String,
    isChecked: json['isChecked'] as bool,
  );
}

/// Model representing an entire shopping list.
class ShoppingList {
  final String id;
  String title;
  List<ListItem> items; // List of items in the list

  // Constructor for creating a new list
  // If no items are provided, an empty list is created by default
  ShoppingList({required this.id, required this.title, List<ListItem>? items})
    : items = items ?? [];

  // Factory constructor for creating a new list from only a title
  factory ShoppingList.create(String title) => ShoppingList(
    // Generates a unique ID using the current timestamp
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    title: title,
  );

  // Converts the list to a JSON object for storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    // Converts the list of items to a list of JSON objects
    'items': items.map((item) => item.toJson()).toList(),
  };

  // Factory constructor for creating a list from a JSON object
  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    // Converts the list of JSON objects to a list of items. If the list is null, an empty list is used.
    // '?.cast' ensures that the list items is always a Map
    final itemsJson = (json['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    return ShoppingList(
      id: json['id'] as String,
      title: json['title'] as String,
      // Creates a list of items from the JSON objects
      items: itemsJson.map((i) => ListItem.fromJson(i)).toList(),
    );
  }
}