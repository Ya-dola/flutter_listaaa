import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'supabase_service.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  ListScreenState createState() => ListScreenState();
}

class ListScreenState extends State<ListScreen> {
  final SupabaseService supabaseService = SupabaseService();
  List<Map<String, dynamic>> shoppingList = [];

  @override
  void initState() {
    super.initState();
    _updateList();
  }

  void _updateList() async {
    try {
      final newList = await supabaseService.fetchList();
      setState(() {
        shoppingList = newList;
      });
    } catch (e) {
      // Handle the error
      print('Error fetching shopping list: $e');
    }
  }

  void _addItemToList(name, description) async {
    try {
      // Example: Add a new item
      await supabaseService.addItem({
        'name': name,
        'description': description,
      });

      // Refresh the shopping list after adding
      _updateList();
    } catch (e) {
      // Handle the error
      print('Error adding item: $e');
    }
  }

  void _showAddDialog() async {
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    await showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Add New Item'),
          content: Column(
            children: [
              CupertinoTextField(
                placeholder: 'Name',
                controller: nameController,
              ),
              const SizedBox(height: 16.0),
              CupertinoTextField(
                placeholder: 'Description',
                controller: descriptionController,
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
              },
              isDefaultAction: true,
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                _addItemToList(nameController.text, descriptionController.text);
                Navigator.pop(context);
              },
              child: const Text('Add Item'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CupertinoButton(
          onPressed: _updateList,
          child: const Text('Update List'),
        ),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Adjust the number of columns as needed
              crossAxisSpacing: 12.0, // Adjust spacing between columns
              mainAxisSpacing: 12.0, // Adjust spacing between rows
            ),
            itemCount: shoppingList.length,
            itemBuilder: (context, index) {
              final item = shoppingList[index];
              return Card(
                child: ListTile(
                  title: Text(item['name']),
                  // Other item details go here
                ),
              );
            },
          ),
        ),
        CupertinoButton(
          onPressed: _showAddDialog,
          child: const Text('Add Item'),
        )
      ],
    );
  }
}
