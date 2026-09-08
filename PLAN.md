# Central Boxing - Plan de Implementación

## 1. Resumen
App Android offline (Flutter) para gimnasio de box. Gestión de alumnos, pagos mensuales, notificaciones locales al admin 3 días antes del vencimiento, historial de pagos, respaldo y exportación, integración WhatsApp.

## 2. Requisitos Acordados
- Plataforma: Android
- BD: Local (sqflite/drift) offline-first
- Login: Admin único con PIN local (SharedPreferences hash)
- Alumno: nombre, teléfono/WhatsApp, fecha_inscripción, fecha_vencimiento, monto, foto opcional, fecha_nacimiento opcional -> edad calculada
- Pagos: Mensual fijo, marcado manual, con historial
- Notificaciones: Solo admin, 3 días de anticipación, diaria 09:00 (WorkManager + flutter_local_notifications)
- Extras: Backup JSON/DB, export CSV/PDF deudores, botón WhatsApp, offline 100%

## 3. Stack
Flutter 3.x, sqflite, Provider/Riverpod, flutter_local_notifications, workmanager, url_launcher, share_plus, path_provider, file_picker, csv, pdf

## 4. Modelo de Datos
```sql
CREATE TABLE alumnos(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nombre TEXT NOT NULL,
  telefono TEXT NOT NULL,
  fecha_inscripcion TEXT NOT NULL,
  fecha_vencimiento TEXT NOT NULL,
  monto REAL NOT NULL,
  foto_path TEXT,
  fecha_nacimiento TEXT, -- NULL opcional ISO8601
  activo INTEGER NOT NULL DEFAULT 1
);
CREATE TABLE pagos(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  alumno_id INTEGER NOT NULL REFERENCES alumnos(id),
  fecha_pago TEXT NOT NULL,
  mes_cubierto TEXT NOT NULL,
  monto REAL NOT NULL,
  metodo TEXT
);
-- edad: getter calculado en modelo, no columna
```

## 5. Lógica Crítica
### 5.1 Cálculo Edad
`edad = hoy.year - fn.year - (hoy < aniversarioEsteAño ? 1 : 0)`

### 5.2 Siguiente Vencimiento (+1 mes calendario)
```dart
DateTime siguienteVencimiento(DateTime base){
  int y=base.year, m=base.month+1; if(m>12){m=1; y++;}
  int ultimo = DateTime(y, m+1, 0).day;
  int d = base.day > ultimo ? ultimo : base.day;
  return DateTime(y,m,d);
}
base = alumno.fechaVencimiento.isAfter(DateTime.now()) ? alumno.fechaVencimiento : DateTime.now();
```
Ej: 31/01/2026->28/02/2026, 31/01/2024->29/02/2024

### 5.3 Notificaciones
Query diaria: `fecha_vencimiento BETWEEN date('now') AND date('now','+3 days')`

## 6. Pantallas
1. Login/PIN (crear/validar, olvide PIN)
2. Dashboard (cards Al día/Por vencer/Vencidos, lista semáforo, búsqueda, filtro estado, FAB agregar)
3. Detalle Alumno (datos, edad 26 años, historial pagos, Marcar Pago, Editar, Eliminar, WhatsApp)
4. Form Alumno (nombre, tel, monto, fecha vencimiento default +1 mes, fecha nacimiento opcional con preview edad)
5. Ajustes (cambiar PIN, backup export/import JSON, export deudores CSV/PDF)

## 7. Estructura Carpetas
```
lib/
 main.dart
 db/database_helper.dart
 models/alumno.dart, pago.dart
 providers/alumno_provider.dart
 screens/login_screen.dart, dashboard_screen.dart, alumno_detail_screen.dart, alumno_form_screen.dart, settings_screen.dart
 services/notification_service.dart, backup_service.dart, whatsapp_service.dart, pago_service.dart
 widgets/alumno_card.dart, estado_badge.dart
```

## 8. Plan de Implementación (8 pasos)
1. flutter create + dependencias
2. DB Helper + modelos + provider
3. Login PIN local
4. CRUD Alumnos + Dashboard con estados/búsqueda
5. Pagos + historial + renovación vencimiento
6. Notificaciones + WorkManager + permisos Android 13+
7. WhatsApp + Export CSV/PDF + Backup/Restore
8. Pulido UI, ícono, APK release

## 9. Riesgos
Pérdida de datos sin backup -> recordatorio mensual backup. Permisos notificaciones.
