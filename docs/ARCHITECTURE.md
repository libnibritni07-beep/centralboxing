# Arquitectura - Central Boxing

## Stack
Flutter 3.29.3, sqflite, provider, flutter_local_notifications, workmanager

## Capas
- `lib/core/constants.dart` - prefijo +52, canal notificaciones
- `lib/db/database_helper.dart` - singleton v2
- `lib/models/` - alumno edad calculada, pago
- `lib/services/pago_service.dart` - siguienteVencimiento() con tope último día mes
- `lib/providers/alumno_provider.dart` - filtros y contadores activo==1
- `lib/screens/` - login, dashboard, detail, form, settings

## BD
alumnos(id, nombre, telefono +52, fecha_inscripcion, fecha_vencimiento, monto, foto_path, fecha_nacimiento NULL, activo) -> pagos(FK alumno_id)

## Flujo pago
registrarPago() -> calcularNuevoVencimiento() anticipado mantiene día, vencido desde hoy
