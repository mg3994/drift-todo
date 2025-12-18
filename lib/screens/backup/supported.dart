import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

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
          onPressed: () {
            createDatabaseBackup(AppDatabase.provider.value);
          },
          child: const Text('Save'),
        ),
        TextButton(
          onPressed: () async {
            final db = AppDatabase.provider.value;
            await db.close();

            // Open the selected database file
            final backupFile = await FilePicker.platform.pickFiles();
            if (backupFile == null) return;
            final backupDb = sqlite3.open(backupFile.files.single.path!);

            // Vacuum it into a temporary location first to make sure it's working.
            final tempPath = await getTemporaryDirectory();
            final tempDb = p.join(tempPath.path, 'import.db');
            backupDb
              ..execute('VACUUM INTO ?', [tempDb])
              ..dispose();

            // Then replace the existing database file with it.
            final tempDbFile = File(tempDb);
            await tempDbFile.copy((await databaseFile).path);
            await tempDbFile.delete();

            // And finally, re-open the database
            AppDatabase.provider.value = AppDatabase();

            if (context.mounted) {
              Navigator.pop(context);
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
    return Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            final db = AppDatabase.provider.value;
            await db.backup();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Backup saved successfully')),
              );
            }
          },
          child: const Text('Backup Database'),
        ),
        ElevatedButton(
          onPressed: () async {
            final db = AppDatabase.provider.value;
            await db.restore();
            // Re-initialize the database state to reflect changes
            AppDatabase.provider.value = AppDatabase();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Database restored successfully')),
              );
            }
          },
          child: const Text('Restore Database'),
        ),
      ],
    );
  }
}
