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
