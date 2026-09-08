# Plan de Desarrollo por Fases - Central Boxing

## FASE 1 - Cimientos (Semana 1)
### 1.1 Setup Proyecto
- flutter create central_boxing, pubspec.yaml (sqflite, provider, flutter_local_notifications, workmanager, url_launcher, share_plus, path_provider, file_picker, csv, pdf, intl), android config, ícono
### 1.2 Base de Datos Local
- lib/db/database_helper.dart singleton, tablas alumnos/pagos, migración v1->v2 ADD fecha_nacimiento
### 1.3 Modelos y Lógica
- lib/models/alumno.dart edad calculada + estado, pago.dart, services/pago_service.dart siguienteVencimiento() con tope último día mes
- Entregable: test 31/01->28/02

## FASE 2 - Auth y CRUD (Semana 1-2)
### 2.1 Login PIN
- lib/screens/login_screen.dart PIN 4 dígitos hash, SharedPreferences, olvide PIN
### 2.2 CRUD Alumnos
- providers/alumno_provider.dart, screens/alumno_form_screen.dart (vencimiento default +1 mes, fecha_nacimiento opcional + preview edad), dashboard_screen.dart (cards, semáforo, búsqueda, filtros, FAB), alumno_detail_screen.dart
- Entregable: APK debug CRUD offline

## FASE 3 - Pagos e Historial (Semana 2)
### 3.1 Registro Pago
- Marcar Pagado -> INSERT pagos + UPDATE vencimiento con regla A (anticipado mantiene día) / B (vencido desde hoy)
### 3.2 Historial
- Lista pagos por alumno, contadores dashboard
- Entregable: test 31/03->30/04, pago anticipado 10/09->10/10

## FASE 4 - Notificaciones y WhatsApp (Semana 3)
### 4.1 Notificaciones
- services/notification_service.dart, workmanager 09:00 diaria, query vencimiento BETWEEN now AND now+3d, permiso Android 13+, boot completed
### 4.2 WhatsApp
- services/whatsapp_service.dart wa.me con mensaje personalizado
- Entregable: notificaciones + WhatsApp funcionando

## FASE 5 - Respaldo, Export y Release (Semana 3-4)
### 5.1 Backup/Restore JSON a Descargas
### 5.2 Export CSV/PDF deudores via share_plus
### 5.3 Pulido, tema, validaciones, flutter build apk --release
- Entregable: APK release + README.md

## Riesgos
Pérdida datos sin backup, permisos POST_NOTIFICATIONS/SCHEDULE_EXACT_ALARM
