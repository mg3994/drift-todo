import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

Future<File> get databaseFile async {
  // We use `path_provider` to find a suitable path to store our data in.
  final appDir = await getApplicationDocumentsDirectory();
  final dbPath = p.join(appDir.path, 'todo-app.sqlite');
  return File(dbPath);
}

Future<void> validateDatabaseSchema(GeneratedDatabase database) async {
  // This method validates that the actual schema of the opened database matches
  // the tables, views, triggers and indices for which drift_dev has generated
  // code.
  // Validating the database's schema after opening it is generally a good idea,
  // since it allows us to get an early warning if we change a table definition
  // without writing a schema migration for it.
  //
  // For details, see: https://drift.simonbinder.eu/docs/advanced-features/migrations/#verifying-a-database-schema-at-runtime
  if (kDebugMode) {
    await VerifySelf(database).validateDatabaseSchema();
  }
}

abstract class PlatformImplementation {
  static Future<void> backup(GeneratedDatabase db) async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      final file = File(p.join(result, 'backup.sqlite'));
      await db.customStatement('VACUUM INTO ?', [file.path]);
    }
  }

  static Future<void> restore(GeneratedDatabase db) async {
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
    final currentDbFile = await databaseFile;
    await tempDbFile.copy(currentDbFile.path);
    await tempDbFile.delete();
  }

  static Future<String?> get databasePath async {
    return (await databaseFile).path;
  }
}
