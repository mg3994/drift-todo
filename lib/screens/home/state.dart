import 'package:signals/signals.dart';

import '../../database/database.dart';

final activeCategory = signal<Category?>(null);

final entriesInCategory = streamSignal(() {
  final database = AppDatabase.provider.value;
  final current = activeCategory.value?.id;
  return database.entriesInCategory(current);
});
