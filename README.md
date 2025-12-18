# app

A cross-platform todo app using drift for local persistence.

## Supported platforms

This app runs on

- Android
- iOS
- macOS
- Linux
- Windows
- Web

When running the app, either with `flutter run` or by running the outputs of
`flutter build`, native sqlite3 dependencies should be set up automatically.
When running the app in a regular Dart VM, for instance through `flutter test`,
you need to ensure that sqlite3 is available yourself. See the [documentation](https://drift.simonbinder.eu/docs/platforms/#desktop)
for more details on this.
To run or build this app on the web, first run `build_runner build` to compile
the web worker used to access databases.

## Development

As this app uses drift, it depends on code-generation.
Use `dart run build_runner build` to automatically build the generated
code.

### Testing

Drift databases don't depend on platform-channels or Flutter-specific features
by default. This means that they can easily be used in unit tests.
One such test is in `test/database_test.dart`

### Migration

After changing the structure of your database schema, for instance by adding
new tables or altering columns, you need to write a migration to ensure that
existing users of your app can convert their database to the latest version.

Run the following command to save the new schema and generate a step-by-step migration helper for
this schema.

```
dart run drift_dev make-migrations
```
