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

  void _addItemToList(String name, String description) async {
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

  void _editSelectedItem(int id, String editedName, String editedDesc) async {
    try {
      await supabaseService
          .updateItem(id, {'name': editedName, 'description': editedDesc});
    } catch (e) {
      print('Error deleting item: $e');
    }

    // Refresh the shopping list after deleting
    _updateList();
  }

  void _deleteSelectedItem(int id) async {
    try {
      await supabaseService.deleteItem(id);
    } catch (e) {
      print('Error deleting item: $e');
    }

    // Refresh the shopping list after deleting
    _updateList();
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
              const SizedBox(height: 10.0),
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
              return ItemCard(
                item: shoppingList[index],
                supabaseService: supabaseService,
                onEdit: _editSelectedItem,
                onDelete: _deleteSelectedItem,
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CupertinoButton.filled(
            onPressed: _showAddDialog,
            child: const Text('Add Item'),
          ),
        )
      ],
    );
  }
}

class ItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final SupabaseService supabaseService;
  final void Function(int, String, String) onEdit;
  final void Function(int) onDelete;

  const ItemCard({
    super.key,
    required this.item,
    required this.supabaseService,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final int id = item['id'];
    final String name = item['name'];
    final String? desc = item['description'];
    final bool completed = item['completed'];

    // Determine theme brightness
    Brightness? themeBrightness = CupertinoTheme.of(context).brightness;

    // Set the card color based on theme brightness
    Color cardColor = themeBrightness == Brightness.light
        ? const Color(0xffdfbbff) // Light theme color
        : const Color(0xff9f73cc); // Dark theme color

    void showEditDialog(String oldName, String oldDesc) async {
      TextEditingController nameController = TextEditingController();
      TextEditingController descriptionController = TextEditingController();

      nameController.text = oldName;
      descriptionController.text = oldDesc;

      await showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('Edit Item: $name'),
            content: Column(
              children: [
                const SizedBox(height: 10.0),
                const Text(
                  'Name',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                CupertinoTextField(
                  placeholder: 'Name',
                  controller: nameController,
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'Description',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
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
                  onEdit(id, nameController.text, descriptionController.text);
                  Navigator.pop(context);
                },
                child: const Text('Edit Item'),
              ),
            ],
          );
        },
      );
    }

    return Card(
      elevation: 6,
      margin: const EdgeInsets.all(12.0),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeInOutCubicEmphasized,
          child: Center(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      tooltip: 'Edit Item',
                      onPressed: () {
                        showEditDialog(name, desc!);
                      },
                    ),
                    const SizedBox(width: 42),
                    IconButton(
                      icon: const Icon(Icons.delete_forever_rounded),
                      tooltip: 'Delete Item',
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      onPressed: () {
                        onDelete(id);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  desc!,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
