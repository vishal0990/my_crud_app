// lib/main.dart

import 'package:flutter/material.dart';

import 'database_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRUD App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ItemListScreen(),
    );
  }
}

class ItemListScreen extends StatefulWidget {
  const ItemListScreen({super.key});

  @override
  _ItemListScreenState createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _items = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await _dbHelper.getItems();
    setState(() {
      _items = items;
    });
  }

  Future<void> _addItem() async {
    if (_controller.text.isNotEmpty) {
      await _dbHelper.insertItem({'name': _controller.text});
      _controller.clear();
      _loadItems();
    }
  }

  Future<void> _deleteItem(int id) async {
    await _dbHelper.deleteItem(id);
    _loadItems();
  }

  Future<void> _updateItem(int id) async {
    final String? newName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController editController = TextEditingController(
            text: _items.firstWhere((item) => item['id'] == id)['name']);
        return AlertDialog(
          title: const Text('Edit Item'),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(hintText: 'Enter new name'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(editController.text);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (newName != null && newName.isNotEmpty) {
      await _dbHelper.updateItem({'id': id, 'name': newName});
      _loadItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRUD Items'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Item Name',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _addItem,
            child: const Text('Add Item'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return ListTile(
                  title: Text(item['name']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _updateItem(item['id']),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteItem(item['id']),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
