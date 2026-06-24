import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/diary_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _db;
  DatabaseHelper._init();

  Future<Database> get database async => _db ??= await _initDB();

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'eluthu_diary.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) => db.execute('''
      CREATE TABLE entries (
        id        INTEGER PRIMARY KEY AUTOINCREMENT,
        date      TEXT    NOT NULL,
        dayName   TEXT    NOT NULL,
        title     TEXT    NOT NULL,
        snippet   TEXT    NOT NULL,
        mood      TEXT    NOT NULL,
        paperColor INTEGER NOT NULL,
        rotation  REAL    NOT NULL,
        tags      TEXT    NOT NULL
      )
    '''),
    );
  }

  Future<int> insertEntry(DiaryEntry entry) async {
    final db = await database;
    final map = Map<String, dynamic>.from(entry.toMap())..remove('id');
    return db.insert('entries', map);
  }

  Future<int> updateEntry(DiaryEntry entry) async {
    final db = await database;
    return db.update(
      'entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteEntry(int id) async {
    final db = await database;
    return db.delete('entries', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<DiaryEntry>> getAllEntries() async {
    final db = await database;
    final rows = await db.query('entries', orderBy: 'id DESC');
    return rows.map(DiaryEntry.fromMap).toList();
  }

  Future<int> countEntriesThisMonth() async {
    final db = await database;
    final now = DateTime.now();
    // date stored as "April 14" — match by month name
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final monthName = months[now.month];
    final result = await db.rawQuery(
      "SELECT COUNT(*) as c FROM entries WHERE date LIKE '$monthName%'",
    );
    return (result.first['c'] as int? ?? 0);
  }
}
