import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals/signals.dart';

import '../database/database.dart';
import 'backup/backup.dart';
import 'home/card.dart';
import 'home/drawer.dart';
import 'home/state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = TextEditingController();
  late final void Function() _disposeSignal;

  @override
  void initState() {
    super.initState();
    _disposeSignal = entriesInCategory.subscribe((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _disposeSignal();
    super.dispose();
  }

  void _addTodoEntry() {
    if (_controller.text.isNotEmpty) {
      final database = AppDatabase.provider.value;
      final currentCategory = activeCategory.value;

      database.todoEntries.insertOne(
        TodoEntriesCompanion.insert(
          description: _controller.text,
          category: Value(currentCategory?.id),
        ),
      );

      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drift Todo list'),
        actions: [
          const BackupIcon(),
          IconButton(
            onPressed: () => context.go('/search'),
            icon: const Icon(Icons.search),
            tooltip: 'Search',
          ),
        ],
      ),
      drawer: const CategoriesDrawer(),
      body: switch (entriesInCategory.value) {
        AsyncData(value: final entries) => ListView.builder(
          itemCount: entries.length,
          itemBuilder: (context, index) {
            return TodoCard(entries[index].entry);
          },
        ),
        AsyncError(error: final e, stackTrace: final s) => () {
          debugPrintStack(label: e.toString(), stackTrace: s);
          return const Text('An error has occured');
        }(),
        AsyncLoading() => const Align(
          alignment: Alignment.center,
          child: CircularProgressIndicator(),
        ),
      },
      bottomSheet: Material(
        elevation: 12,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('What needs to be done?'),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onSubmitted: (_) => _addTodoEntry(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      color: Theme.of(context).colorScheme.secondary,
                      onPressed: _addTodoEntry,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
