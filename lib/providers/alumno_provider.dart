import 'package:flutter/foundation.dart';
import '../db/database_helper.dart';
import '../models/alumno.dart';

class AlumnoProvider extends ChangeNotifier {
  List<Alumno> _all = [];
  String query = '';
  String filtro = 'todos'; // todos, al_dia, por_vencer, vencido
  List<Alumno> get alumnos {
    var l = _all.where((a) => a.activo==1).toList();
    if (query.isNotEmpty) l = l.where((a)=>a.nombre.toLowerCase().contains(query.toLowerCase())).toList();
    if (filtro!='todos') l = l.where((a)=>a.estado==filtro).toList();
    return l;
  }
  int get countAlDia => _all.where((a)=>a.activo==1 && a.estado=='al_dia').length;
  int get countPorVencer => _all.where((a)=>a.activo==1 && a.estado=='por_vencer').length;
  int get countVencido => _all.where((a)=>a.activo==1 && a.estado=='vencido').length;

  Future<void> load() async {
    final db = await DatabaseHelper.instance.db;
    final maps = await db.query('alumnos', orderBy: 'fecha_vencimiento ASC');
    _all = maps.map((m)=>Alumno.fromMap(m)).toList();
    notifyListeners();
  }
  Future<void> add(Alumno a) async {
    final db = await DatabaseHelper.instance.db;
    await db.insert('alumnos', a.toMap()..remove('id'));
    await load();
  }
  Future<void> update(Alumno a) async {
    final db = await DatabaseHelper.instance.db;
    await db.update('alumnos', a.toMap(), where:'id=?', whereArgs:[a.id]);
    await load();
  }
  Future<void> remove(int id) async {
    final db = await DatabaseHelper.instance.db;
    await db.update('alumnos', {'activo':0}, where:'id=?', whereArgs:[id]);
    await load();
  }
}
