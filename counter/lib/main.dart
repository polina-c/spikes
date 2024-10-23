import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Item {
  String name;
  Item({required this.name});
}

class ItemsDataModel extends ChangeNotifier {
  List<Item> items = [Item(name: 'Item 1'), Item(name: 'Item 2')];

  void addItem(String name) {
    items.add(Item(name: name));
    notifyListeners();
  }

  void removeItem(int index) {
    items.removeAt(index);
    notifyListeners();
  }

  void editItem(int index, String newName) {
    items[index].name = newName;
    notifyListeners();
  }
}

class GenUIApp extends StatelessWidget {
  const GenUIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChangeNotifierProvider(
        create: (context) => ItemsDataModel(),
        child: const ItemListScreen(),
      ),
    );
  }
}

class ItemListScreen extends StatelessWidget {
  const ItemListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item List'),
      ),
      body: Consumer<ItemsDataModel>(
        builder: (context, itemDataModel, child) {
          return ListView.builder(
            itemCount: itemDataModel.items.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(itemDataModel.items[index].name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        final newName = await showDialog<String>(
                          context: context,
                          builder: (context) => EditItemDialog(
                            itemName: itemDataModel.items[index].name,
                          ),
                        );
                        if (newName != null) {
                          itemDataModel.editItem(index, newName);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        itemDataModel.removeItem(index);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final dataModel = context.read<ItemsDataModel>();
          final newName = await showDialog<String>(
            context: context,
            builder: (context) => const AddItemDialog(),
          );
          if (newName != null && newName.isNotEmpty) {
            dataModel.addItem(newName);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddItemDialog extends StatefulWidget {
  const AddItemDialog({super.key});

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Item'),
      content: TextField(
        controller: _controller,
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(_controller.text);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class EditItemDialog extends StatefulWidget {
  final String itemName;

  const EditItemDialog({super.key, required this.itemName});

  @override
  State<EditItemDialog> createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<EditItemDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.itemName);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Item'),
      content: TextField(
        controller: _controller,
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(_controller.text);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

void main() {
  runApp(const GenUIApp());
}
