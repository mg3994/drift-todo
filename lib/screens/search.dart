import 'package:flutter/material.dart';

import '../database/database.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  Future<List<TodoEntryWithCategory>>? _search;
  String? _text;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: (_) {
            setState(() {
              if (_text != _controller.text && _controller.text.isNotEmpty) {
                _text = _controller.text;
                _search = AppDatabase.provider.value.search(_text!);
              }
            });
          },
          decoration: const InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
          ),
        ),
      ),
      body: FutureBuilder<List<TodoEntryWithCategory>>(
        future: _search,
        builder: (context, snapshot) {
          final entries = snapshot.data;

          if (entries == null) {
            return const Center(child: Text('Enter a search query'));
          } else {
            return ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(entries[index].entry.description),
                );
              },
            );
          }
        },
      ),
    );
  }
}
