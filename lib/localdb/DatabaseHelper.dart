import 'package:path/path.dart';
import 'package:payvor/model/recentsearch.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final _databaseName = "record.db";
  static final _databaseVersion = 1;

  static final table = 'RecentSearch';
  static final id = 'id';
  static final keyword = 'keyword';
  static final createdAt = 'createdAt';

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute("CREATE TABLE $table ("
        "$id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
        "$keyword TEXT,"
        "$createdAt TEXT"
        ")");
  }

  Future<int> insert(RecentSearch recentSearch) async {
    Database db = await instance.database;
    var res = await db.insert(table, recentSearch.toJson());
    return res;
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    var res = await db.query(table);
    return res.toList();
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$id = ?', whereArgs: [id]);
  }

  Future<void> clearTable() async {
    Database db = await instance.database;
    return await db.rawQuery("DELETE FROM $table");
  }

  Future<int> updateInformation(RecentSearch recentSearch) async {
    Database db = await instance.database;
    return await db.update("$table", recentSearch.toJson(),
        where: "id = ?", whereArgs: [recentSearch.id]);
  }
}
