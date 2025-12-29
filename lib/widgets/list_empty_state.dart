import 'package:flutter/material.dart';

/// Displays a message when there are no lists or items.
class ListEmptyState extends StatelessWidget {
  const ListEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.list_alt, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No lists or items found!', style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }
}
