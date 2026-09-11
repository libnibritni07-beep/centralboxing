import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  DatabaseHelper._();
  Database? _db;
  Future<Database> get db async => _db ??= await _init();
  Future<Database> _init() async {
    final p = join(await getDatabasesPath(), 'central_boxing.db');
    return openDatabase(
      p,
      version: 2,
      onCreate: (db, v) async {
        await db.execute(
          'CREATE TABLE alumnos(id INTEGER PRIMARY KEY AUTOINCREMENT, nombre TEXT NOT NULL, telefono TEXT NOT NULL, fecha_inscripcion TEXT NOT NULL, fecha_vencimiento TEXT NOT NULL, monto REAL NOT NULL, foto_path TEXT, fecha_nacimiento TEXT, activo INTEGER NOT NULL DEFAULT 1)',
        );
        await db.execute(
          'CREATE TABLE pagos(id INTEGER PRIMARY KEY AUTOINCREMENT, alumno_id INTEGER NOT NULL REFERENCES alumnos(id), fecha_pago TEXT NOT NULL, mes_cubierto TEXT NOT NULL, monto REAL NOT NULL, metodo TEXT)',
        );
        await db.execute('CREATE INDEX idx_venc ON alumnos(fecha_vencimiento)');
      },
      onUpgrade: (db, oldV, newV) async {
        if (oldV < 2) {
          await db.execute(
            'ALTER TABLE alumnos ADD COLUMN fecha_nacimiento TEXT',
          );
        }
      },
    );
  }
}
