import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflites/model/student.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  static late Database _database;

  String studentsTable = 'Students';
  String columnId = 'id';
  String columnName = 'name';

  Future<Database> get database async {
    // if(_database != null) {
    //   return _database;
    // }

    _database = await _initDB();
    return _database;
  }

  Future<Database> _initDB() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = '${dir.path}student.db';
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  void _createDB(Database database, int version) async {
    await database.execute(
      'CREATE TABLE $studentsTable($columnId INTEGER PRIMARY KEY AUTOINCREMENT, $columnName TEXT)',
    );
  }

  //read
  Future<List<Student>> getStudents() async {
    final db = await database;
    final List<Map<String, dynamic>> studentsMapList = await db.query(studentsTable);
    final List<Student> studentsList = [];

    for (var studentMap in studentsMapList) {
      studentsList.add(Student.fromMap(studentMap));
    }

    return studentsList;
  }

  //insert
  Future<Student> insertStudent(Student student) async {
    final db = await database;
    student.id = await db.insert(studentsTable, student.toMap());
    return student;
  }

  //update
  Future<int> updateStudent(Student student) async {
    final db = await database;
    return await db.update(
      studentsTable,
      student.toMap(),
      where: "$columnId = ?",
      whereArgs: [student.id],
    );
  }

  //delete
  Future<int> deleteStudent(int id) async {
    final db = await database;
    return await db.delete(
      studentsTable,
      where: "$columnId = ?",
      whereArgs: [id],
    );
  }
}
