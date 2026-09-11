class Pago {
  final int? id;
  final int alumnoId;
  final DateTime fechaPago;
  final String mesCubierto;
  final double monto;
  final String? metodo;
  Pago({
    this.id,
    required this.alumnoId,
    required this.fechaPago,
    required this.mesCubierto,
    required this.monto,
    this.metodo,
  });
  Map<String, dynamic> toMap() => {
    'id': id,
    'alumno_id': alumnoId,
    'fecha_pago': fechaPago.toIso8601String(),
    'mes_cubierto': mesCubierto,
    'monto': monto,
    'metodo': metodo,
  };
  factory Pago.fromMap(Map<String, dynamic> m) => Pago(
    id: m['id'],
    alumnoId: m['alumno_id'],
    fechaPago: DateTime.parse(m['fecha_pago']),
    mesCubierto: m['mes_cubierto'],
    monto: (m['monto'] as num).toDouble(),
    metodo: m['metodo'],
  );
}
