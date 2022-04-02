

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
// import 'package:tongue_cmu_bluetooth/model/note.dart';
import 'package:wb_cmu/model/user.dart';
import 'package:wb_cmu/model/weightTest.dart';

class WeightDatabase {
  static final WeightDatabase instance = WeightDatabase._init();

  static Database? _database;

  WeightDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('tongue.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }
  final weightTest = 'weightTest';
  Future _createDB(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final textType = 'TEXT NOT NULL';
    final boolType = 'BOOLEAN NOT NULL';
    final integerType = 'INTEGER NOT NULL';
    final floatType = 'DOUBLE NOT NULL';

    await db.execute('''
CREATE TABLE $tableUser ( 
  ${UserFields.id} $idType, 
  ${UserFields.name} $textType,
  ${UserFields.surname} $textType,
  ${UserFields.gender} $textType,
  ${UserFields.age} $integerType,
  ${UserFields.createAt} $textType
  )
''');

    await db.execute('''
CREATE TABLE $tableWeightTest ( 
  ${WeightTestFields.id} $idType, 
  ${WeightTestFields.userId} $integerType,
  ${WeightTestFields.time} $textType,
  ${WeightTestFields.deviceId} $integerType,
  ${WeightTestFields.type} $textType,
  ${WeightTestFields.leftKilogram} $floatType,
  ${WeightTestFields.rightKilogram} $floatType,
  ${WeightTestFields.total} $floatType,
  FOREIGN KEY (${WeightTestFields.userId}) REFERENCES tableUser(${UserFields.id})
  )
''');
  }

  Future<WeightTest> addTest(WeightTest weightTest) async{
    final db = await instance.database;
    final id = await db.insert(tableWeightTest, weightTest.toJson());
    return weightTest.copy(id:id);
  }

  // Future<WeightTest> getMaxTest(int userId) async {
  //   final db = await instance.database;
  //   final result = await db.rawQuery(
  //     "SELECT a.* FROM $weightTest a LEFT OUTER JOIN $weightTest b ON a._id = b._id  WHERE b._id IS NULL AND a.userId = $userId LIMIT 1"
  //   );
  //   if (result.isNotEmpty) {
  //     // print(result);
  //     return WeightTest.fromJson(result.first);
  //   } else {
  //     return WeightTest(userId: userId, time: DateTime.now(), type: "Not found", leftKilogram: 0,rightKilogram: 0,total: 0);
  //   }
  // }
  Future<User> createUser(User user) async {
    final db = await instance.database;
    final id = await db.insert(tableUser, user.toJson());
    return user.copy(id: id);
  }

  Future<User> readUser(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableUser,
      columns: UserFields.values,
      where: '${UserFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<User>> readAllUser() async {
    final db = await instance.database;

    final orderBy = '${UserFields.createAt} ASC';
    // final result =
    //     await db.rawQuery('SELECT * FROM $tableNotes ORDER BY $orderBy');

    final result = await db.query(tableUser, orderBy: orderBy);

    return result.map((json) => User.fromJson(json)).toList();
  }

  Future<User> getLogin(String loginName, String loginSurName) async {
    final db = await instance.database;
    final result = await db.rawQuery(
        "SELECT * FROM user WHERE name = '$loginName' and surname = '$loginSurName'");
    // print(result);
    if (result.isNotEmpty) {
      return User.fromJson(result.first);
    } else {
      return User(
          name: "", surname: "", gender: "", age: 0, createAt: DateTime.now());
    }
  }

  Future<int> updateUser(User user) async {
    final db = await instance.database;

    return db.update(
      tableUser,
      user.toJson(),
      where: '${UserFields.id} = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableUser,
      where: '${UserFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
  Future exportUserData() async{
    final db = await instance.database;
    final result = await db.rawQuery(
        "SELECT * FROM user ");
    return result;
  }
  Future exportTestData() async{
    final db = await instance.database;
    final result = await db.rawQuery(
        "SELECT *,user.name,user.surname FROM $weightTest INNER JOIN user ON userId = user._id");
    return result;

  }
}
