import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:lejoje/JsonModels/note_model.dart';
import 'package:lejoje/JsonModels/users.dart';

class DatabaseHelper {
  final databaseName = "myapp.db";
  String noteTable =
      "CREATE TABLE children (userId INTEGER PRIMARY KEY AUTOINCREMENT,firstName TEXT NOT NULL, lastName TEXT NOT NULL,phoneNumber TEXT UNIQUE, visited INTEGER, createdAt TEXT DEFAULT CURRENT_TIMESTAMP)";

  //Now we must create our user table into our sqlite db

  String users =
      "create table users (usrId INTEGER PRIMARY KEY AUTOINCREMENT, usrName TEXT UNIQUE, phoneNumber TEXT UNIQUE, usrPassword TEXT)";

  //We are done in this section

  Future<Database> initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);

    return openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(users);
      await db.execute(noteTable);
    });
  }

  //Now we create login and sign up method
  //as we create sqlite other functionality in our previous video

  //IF you didn't watch my previous videos, check part 1 and part 2

  //Login Method

  Future<bool> login(Users user) async {
    final Database db = await initDB();

    // I forgot the password to check
    var result = await db.rawQuery(
        "select * from users where usrName = '${user.usrName}' AND usrPassword = '${user.usrPassword}'");
    if (result.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  //Sign up
  Future<int> signup(Users user) async {
    final Database db = await initDB();

    return db.insert('users', user.toMap());
  }

  //Search Method
  Future<List<NoteModel>> searchChildren(String keyword) async {
    final Database db = await initDB();
    List<Map<String, Object?>> searchResult = await db
        .rawQuery("select * from children where firstName LIKE ?", ["%$keyword%"]);
    return searchResult.map((e) => NoteModel.fromMap(e)).toList();
  }

  //CRUD Methods

  //Create Note
  Future<int> createNote(NoteModel note) async {
    final Database db = await initDB();
    return db.insert('children', note.toMap());
  }

  //Get children
  Future<List<NoteModel>> getChildren() async {
    final Database db = await initDB();
    List<Map<String, Object?>> result = await db.query('children');
    return result.map((e) => NoteModel.fromMap(e)).toList();
  }

  //Delete children
  Future<int> deleteChild(int id) async {
    final Database db = await initDB();
    return db.delete('children', where: 'userId = ?', whereArgs: [id]);
  }
Future<void> updateVisitedStatus(int userId, bool visited) async {
  print('Updating visited status for user $userId to $visited');
  final db = await initDB();
  await db.update(
    'children',
    {'visited': visited ? 1 : 0},
    where: 'userId = ?',
    whereArgs: [userId],
  );
  print('Visited status updated successfully');
}

  //Update children
  Future<int> updateChild(firstname, lastname, phonenumber ,userId) async {
    final Database db = await initDB();
    return db.rawUpdate(
        'update children set firstName = ?, lastName = ?, phoneNumber= ? where userId = ?',
        [firstname, lastname, userId]);
  }
}
