# Central Boxing 🥊 - App Gimnasio de Box

App Android offline para gestión de alumnos y pagos mensuales.

## Características
- Registro de alumnos (nombre, teléfono, monto, vencimiento, foto, fecha nacimiento opcional con edad automática)
- Control de pagos mensuales con historial y semáforo (Al día / Por vencer ≤3 días / Vencido)
- Cálculo de vencimiento inteligente +1 mes calendario (contempla 28/29/31 días)
- Notificaciones locales diarias al admin (3 días antes)
- Marcado de pago manual, renovación automática de vencimiento
- Login admin único con PIN local
- Botón recordatorio WhatsApp, export deudores CSV/PDF, backup/restore JSON
- 100% offline con BD local `sqflite`

## Requisitos
- Flutter 3.x, Android SDK, Dart 3.x

## Instalación
```bash
flutter pub get
flutter run
flutter build apk --release
```

## Estructura
Ver `PLAN.md` para modelo de datos y arquitectura detallada.

## Backup
Ajustes -> Exportar Backup (.json en Descargas) / Importar Backup

## Licencia
Uso privado Central Boxing.
