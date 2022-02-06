import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:shared/shared.dart';
import 'package:sqflite/sqflite.dart';

abstract class BaseCache {
  Database? database;
  final String tableName;

  BaseCache(this.tableName, {this.database});

  Future<void> initCacheStore() async {
    database ??= await openDatabase(
      join(await getDatabasesPath(), "cache.db"),
      onCreate: onDatabaseCreated,
      version: 1,
    );
  }

  @protected
  // TODO refactor completly wrappe the [Database], do not expose it.
  Future<void> onDatabaseCreated(Database database, int databaseVersion);

  Future<int> insert(JsonObject data) {
    assert(database != null && database!.isOpen);
    return database!.insert(
      tableName,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<JsonObject>> get({CacheQuery? query}) {
    assert(database != null && database!.isOpen);
    return database!.query(
      tableName,
      distinct: query?.distinct,
      columns: query?.columns,
      where: query?.where,
      whereArgs: query?.whereArgs,
      groupBy: query?.groupBy,
      having: query?.having,
      orderBy: query?.orderBy,
      limit: query?.limit,
      offset: query?.offset,
    );
  }

  Future<void> delete(String columnName, List<Object> columnValue) {
    assert(database != null && database!.isOpen);
    if (!RegExp(r'^[a-zA-Z_]+$').hasMatch(columnName) ||
        columnName.length > 20) {
      // Prevent SQL injection (TODO improve protection)
      throw Exception(
        "Table column Name can contain only alphabetic letters and _ character",
      );
    }

    return database!.delete(
      tableName,
      where: "$columnName = ?",
      whereArgs: [columnValue],
    );
  }
}

class CacheQuery {
  bool? distinct;
  List<String>? columns;
  String? where;
  List<Object?>? whereArgs;
  String? groupBy;
  String? having;
  String? orderBy;
  int? limit;
  int? offset;
}
