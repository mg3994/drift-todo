import 'package:flutter/material.dart';

import '../../database/database.dart';

class BackupIcon extends StatelessWidget {
  const BackupIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () =>
          showDialog(context: context, builder: (_) => const BackupDialog()),
      icon: const Icon(Icons.save),
      tooltip: 'Backup',
    );
  }
}

class BackupDialog extends StatelessWidget {
  const BackupDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Database backup'),
      content: const Text(
        'Here, you can save the database to a file or restore a created '
        'backup.',
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final db = AppDatabase.provider.value;
            await db.backup();
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Backup saved successfully')),
              );
            }
          },
          child: const Text('Save'),
        ),
        TextButton(
          onPressed: () async {
            final db = AppDatabase.provider.value;
            await db.restore();

            // And finally, re-open the database
            AppDatabase.provider.value = AppDatabase();

            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Database restored successfully')),
              );
            }
          },
          child: const Text('Restore'),
        ),
      ],
    );
  }
}

class Supported extends StatelessWidget {
  const Supported({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(children: [BackupDialog()]);
  }
}
