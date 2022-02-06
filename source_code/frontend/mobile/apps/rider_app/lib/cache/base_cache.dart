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

  Future<void> insert(JsonObject data) {
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

  // TODO make more generic
  Future<void> delete(String where, List whereArgs) {
    assert(database != null && database!.isOpen);

    return database!.delete(
      tableName,
      where: where,
      whereArgs: whereArgs,
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
