class Alumno {
  final int? id;
  final String nombre, telefono;
  final DateTime fechaInscripcion, fechaVencimiento;
  final double monto;
  final String? fotoPath, fechaNacimiento; // ISO8601
  final int activo;

  Alumno({this.id, required this.nombre, required this.telefono, required this.fechaInscripcion, required this.fechaVencimiento, required this.monto, this.fotoPath, this.fechaNacimiento, this.activo=1});

  int get edad {
    if (fechaNacimiento == null) return 0;
    final fn = DateTime.parse(fechaNacimiento!);
    final hoy = DateTime.now();
    int e = hoy.year - fn.year;
    if (hoy.month < fn.month || (hoy.month == fn.month && hoy.day < fn.day)) e--;
    return e;
  }
  String get edadTexto => fechaNacimiento == null ? '-' : '$edad años';
  String get estado {
    final hoy = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final v = DateTime(fechaVencimiento.year, fechaVencimiento.month, fechaVencimiento.day);
    if (v.isBefore(hoy)) return 'vencido';
    if (v.difference(hoy).inDays <= 3) return 'por_vencer';
    return 'al_dia';
  }

  Map<String,dynamic> toMap()=>{'id':id,'nombre':nombre,'telefono':telefono,'fecha_inscripcion':fechaInscripcion.toIso8601String(),'fecha_vencimiento':fechaVencimiento.toIso8601String(),'monto':monto,'foto_path':fotoPath,'fecha_nacimiento':fechaNacimiento,'activo':activo};
  factory Alumno.fromMap(Map<String,dynamic> m)=>Alumno(id:m['id'],nombre:m['nombre'],telefono:m['telefono'],fechaInscripcion:DateTime.parse(m['fecha_inscripcion']),fechaVencimiento:DateTime.parse(m['fecha_vencimiento']),monto:(m['monto'] as num).toDouble(),fotoPath:m['foto_path'],fechaNacimiento:m['fecha_nacimiento'],activo:m['activo']);
}
