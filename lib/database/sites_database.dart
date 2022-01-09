import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:qr_scann/models/site_model.dart';

class SitesDatabase {
  static final SitesDatabase instance = SitesDatabase._init();

  static Database? _database;

  SitesDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    await db.execute('''CREATE TABLE $tableSites (
      ${SiteFields.id} $idType,
      ${SiteFields.url} $textType,
      ${SiteFields.time} $textType
    )''');
  }

  Future<Site> create(Site note) async {
    final db = await instance.database;

    final id = await db.insert(tableSites, note.toJson());
    return note.copy(id: id);
  }

  Future<Site> readNote(int id) async {
    final db = await instance.database;

    final maps = await db.query(tableSites,
        columns: SiteFields.values,
        where: '${SiteFields.id} = ?',
        whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Site.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Site>> readAllSites() async {
    final db = await instance.database;

    final orderBy = '${SiteFields.time} ASC';
    final result = await db.query(tableSites, orderBy: orderBy);
    return result.map((json) => Site.fromJson(json)).toList();
  }

  Future<int> delete(int? id) async {
    final db = await instance.database;

    return db.delete(
      tableSites,
      where: '${SiteFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
