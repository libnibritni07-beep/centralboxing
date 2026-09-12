# Central Boxing - App Gimnasio de Box

App Android offline para gestion de alumnos y pagos mensuales. 100% offline con BD local sqflite.

## Caracteristicas
- Registro de alumnos: nombre, telefono +52 fijo (10 digitos), monto, fecha inscripcion hoy editable, fecha vencimiento +1 mes solo lectura (28/29/31 dias), foto camara/galeria copia local, fecha nacimiento opcional con edad automatica
- Control pagos mensuales con semaforo Al dia / Por vencer <=3 dias / Vencido
- Historial pagos con registro Marcar Pagado y vencimiento inteligente
- Notificaciones locales diarias al admin 3 dias antes (⏰ Tu cuota vence / 🚨 Tu cuota vencio) con Central Boxing
- WhatsApp recordatorio con mensaje estructurado y emojis
- Login admin unico PIN local 4 cajas con fondo gradiente y Hero logo
- Dashboard SliverAppBar 80 CENTRAL BOXING 22 con StatsCard gradiente y filtros FilterChip scroll sin overflow
- Ajustes: modo oscuro manual, probar notificacion, backup JSON, export deudores CSV/PDF (todos/por vencer/vencido)
- Icono launcher y splash redondo transparente #111111 1.5s con Hero

## Requisitos
Flutter 3.29.3, Dart 3.7.2, Android SDK

## Instalacion
```bash
git clone https://github.com/libnibritni07-beep/centralboxing.git
cd C:/dev/centralboxing
flutter pub get
flutter run
# o
flutter build apk --debug
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

## Estructura
lib/core/theme.dart, lib/providers/theme_provider.dart, lib/services/notification_service.dart (buildWhatsAppMessage), lib/screens/

## Uso
1. Crear PIN, agregar alumno con foto, inscripcion hoy, vencimiento +1 mes readonly, por vencer/vencidos en Dashboard, WhatsApp swipe, Ajustes export.

## Proyecto
C:/dev/centralboxing fuera de OneDrive para evitar build corrupto.
