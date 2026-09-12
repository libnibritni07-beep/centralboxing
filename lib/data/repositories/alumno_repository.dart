import '../../models/alumno.dart';
abstract class AlumnoRepository {
  Future<List<Alumno>> getAll();
  Future<void> add(Alumno a);
  Future<void> update(Alumno a);
  Future<void> remove(int id);
}
