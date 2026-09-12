import '../../db/database_helper.dart';
import '../../models/alumno.dart';
import 'alumno_repository.dart';
class SqfliteAlumnoRepository implements AlumnoRepository {
  @override Future<List<Alumno>> getAll() async {
    final db=await DatabaseHelper.instance.db;
    final m=await db.query('alumnos', orderBy:'fecha_vencimiento ASC');
    return m.map((e)=>Alumno.fromMap(e)).toList();
  }
  @override Future<void> add(Alumno a) async { final db=await DatabaseHelper.instance.db; await db.insert('alumnos', a.toMap()..remove('id')); }
  @override Future<void> update(Alumno a) async { final db=await DatabaseHelper.instance.db; await db.update('alumnos', a.toMap(), where:'id=?', whereArgs:[a.id]); }
  @override Future<void> remove(int id) async { final db=await DatabaseHelper.instance.db; await db.update('alumnos', {'activo':0}, where:'id=?', whereArgs:[id]); }
}
