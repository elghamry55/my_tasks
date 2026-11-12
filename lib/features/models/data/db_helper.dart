
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../model/task_model.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();

  factory DBHelper() => _instance;

  DBHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;

    _db = await _initDB();

    return _db!;
  }

  Future<Database> _initDB() async {
    final directory = await getApplicationDocumentsDirectory();

    final path = join(directory.path, 'mytasks.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        dueDate TEXT NOT NULL,
        status INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insertTask(TaskModel task) async {
    final db = await database;

    final map = task.toMap()..remove('id');

    return db.insert('tasks', map);
  }

  Future<List<TaskModel>> getAllTasks() async {
    final db = await database;

    final result = await db.query(
      'tasks',
      orderBy: 'dueDate ASC',
    );

    return result.map((item) {
      return TaskModel.fromMap(item);
    }).toList();
  }

  Future<int> updateTask(TaskModel task) async {
    final db = await database;

    return db.update(
      'tasks',
      task.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;

    return db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
