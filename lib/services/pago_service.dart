import '../db/database_helper.dart';
import '../models/pago.dart';

class PagoService {
  static DateTime siguienteVencimiento(DateTime base) {
    int y = base.year, m = base.month + 1;
    if (m > 12) {
      m = 1;
      y++;
    }
    int ultimo = DateTime(y, m + 1, 0).day;
    int d = base.day > ultimo ? ultimo : base.day;
    return DateTime(y, m, d);
  }

  static DateTime recalcularVencimiento(
    DateTime fechaInscripcion,
    int pagosRestantes,
  ) {
    var venc = siguienteVencimiento(fechaInscripcion);
    for (var i = 0; i < pagosRestantes; i++) {
      venc = siguienteVencimiento(venc);
    }
    return venc;
  }

  static DateTime calcularNuevoVencimiento(DateTime vencimientoActual) {
    final now = DateTime.now();
    final base = vencimientoActual.isAfter(now) ? vencimientoActual : now;
    final baseDate = DateTime(base.year, base.month, base.day);
    return siguienteVencimiento(baseDate);
  }

  static Future<void> registrarPago(
    int alumnoId,
    double monto, {
    String metodo = 'efectivo',
  }) async {
    final db = await DatabaseHelper.instance.db;
    final maps = await db.query(
      'alumnos',
      where: 'id=?',
      whereArgs: [alumnoId],
    );
    if (maps.isEmpty) return;
    final venc = DateTime.parse(maps.first['fecha_vencimiento'] as String);
    final nuevo = calcularNuevoVencimiento(venc);
    final mes = "${nuevo.year}-${nuevo.month.toString().padLeft(2, '0')}";
    await db.insert(
      'pagos',
      Pago(
          alumnoId: alumnoId,
          fechaPago: DateTime.now(),
          mesCubierto: mes,
          monto: monto,
          metodo: metodo,
        ).toMap()
        ..remove('id'),
    );
    await db.update(
      'alumnos',
      {'fecha_vencimiento': nuevo.toIso8601String()},
      where: 'id=?',
      whereArgs: [alumnoId],
    );
  }

  static Future<int> contarPagos(int alumnoId) async {
    final db = await DatabaseHelper.instance.db;
    final maps = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM pagos WHERE alumno_id=?',
      [alumnoId],
    );
    return (maps.first['c'] as num).toInt();
  }

  static Future<({DateTime inscripcion, DateTime vencimiento})?>
  datosAlumno(int alumnoId) async {
    final db = await DatabaseHelper.instance.db;
    final maps = await db.query(
      'alumnos',
      columns: ['fecha_inscripcion', 'fecha_vencimiento'],
      where: 'id=?',
      whereArgs: [alumnoId],
    );
    if (maps.isEmpty) return null;
    return (
      inscripcion: DateTime.parse(maps.first['fecha_inscripcion'] as String),
      vencimiento: DateTime.parse(maps.first['fecha_vencimiento'] as String),
    );
  }

  static Future<DateTime?> previsualizarVencimientoTrasBorrar(
    int alumnoId,
  ) async {
    final datos = await datosAlumno(alumnoId);
    if (datos == null) return null;
    final total = await contarPagos(alumnoId);
    if (total == 0) return datos.vencimiento;
    return recalcularVencimiento(datos.inscripcion, total - 1);
  }

  static Future<void> eliminarPago(int pagoId, int alumnoId) async {
    final db = await DatabaseHelper.instance.db;
    final deleted = await db.delete(
      'pagos',
      where: 'id=? AND alumno_id=?',
      whereArgs: [pagoId, alumnoId],
    );
    if (deleted == 0) return;
    final maps = await db.query(
      'alumnos',
      columns: ['fecha_inscripcion'],
      where: 'id=?',
      whereArgs: [alumnoId],
    );
    if (maps.isEmpty) return;
    final insc = DateTime.parse(maps.first['fecha_inscripcion'] as String);
    final restantes = await contarPagos(alumnoId);
    final nuevo = recalcularVencimiento(insc, restantes);
    await db.update(
      'alumnos',
      {'fecha_vencimiento': nuevo.toIso8601String()},
      where: 'id=?',
      whereArgs: [alumnoId],
    );
  }

  static Future<List<Pago>> historial(int alumnoId) async {
    final db = await DatabaseHelper.instance.db;
    final maps = await db.query(
      'pagos',
      where: 'alumno_id=?',
      whereArgs: [alumnoId],
      orderBy: 'fecha_pago DESC',
    );
    return maps.map((m) => Pago.fromMap(m)).toList();
  }
}
