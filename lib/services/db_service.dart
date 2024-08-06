import 'package:minerd/models/visit.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:minerd/models/incident.dart';

class DBService {
  static Database? _database;

  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;

    _database = await openDatabase(
      join(await getDatabasesPath(), 'minerd.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE incidencias(id INTEGER PRIMARY KEY AUTOINCREMENT, titulo TEXT, centroEducativo TEXT, regional TEXT, distrito TEXT, fecha TEXT, descripcion TEXT, fotoPath TEXT, audioPath TEXT)',
        );
      },
      version: 1,
    );
    return _database!;
  }

  static Future<void> insertIncidencia(Incidencia incidencia) async {
    final db = await getDatabase();
    await db.insert('incidencias', incidencia.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Incidencia>> incidencias() async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query('incidencias');
    return List.generate(maps.length, (i) {
      return Incidencia.fromMap(maps[i]);
    });
  }


 
  static Future<void> insertVisit(Visit visit) async {
    final db = await getDatabase();
    await db.insert('visitas', visit.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

    static Future<void> eliminarTodasIncidencias() async {
    final db = await getDatabase();
    await db.delete('incidencias');
  }


  static Future<void> deleteAllIncidencias() async {
    final db = await getDatabase();
    await db.delete('incidencias');
  }
}
