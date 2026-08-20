import 'dart:io';

import 'package:costly/database/database_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('recreates a corrupt database file automatically', () async {
    final dbPath = join(await getDatabasesPath(), 'costly.db');
    final corruptDb = File(dbPath);

    await corruptDb.parent.create(recursive: true);

    if (await corruptDb.exists()) {
      await corruptDb.delete();
    }

    await corruptDb.writeAsString('not a database');

    final db = await DatabaseHelper().database;

    expect(db.isOpen, isTrue);
    final tables = await db.query('sqlite_master');
    expect(tables.any((row) => row['name'] == 'budget'), isTrue);
    expect(tables.any((row) => row['name'] == 'expenses'), isTrue);
  });
}
