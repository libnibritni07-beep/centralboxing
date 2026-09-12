# Arquitectura - Central Boxing (Actualizado)

## Stack
Flutter 3.29.3, sqflite, provider, flutter_local_notifications, workmanager, image_picker, google_fonts, flutter_launcher_icons + flutter_native_splash

## Capas
- core/theme.dart (light/dark Oswald), core/constants.dart
- providers: alumno_provider (activo==1), theme_provider (manual)
- db/database_helper v2, models/alumno (edad, foto_path), models/pago
- services: pago_service.siguienteVencimiento 28/29/31, notification_service.buildWhatsAppMessage con emojis, backup_service con _filtrar, auth_service PIN

## Pantallas
Login Hero gradiente 4 cajas, Dashboard SliverAppBar 80 CENTRAL BOXING 22 FilterChip, Detail Sliver Hero 180 FullScreen InteractiveViewer, Form 2 Cards foto, Settings 3 Cards

## BD
alumnos(id, nombre, telefono +52, fecha_inscripcion, fecha_vencimiento +1 mes, monto, foto_path, fecha_nacimiento NULL, activo) -> pagos(FK)

## Notificaciones
Workmanager 24h 09:00 query vencimiento BETWEEN now+3d y <now, canal central_boxing_channel, mensajes ⏰ vence / 🚨 vencio con Central Boxing

## Icono/Splash
launcher_icon adaptive #111111 desde logo_boxing.png circular, splash logo_splash.png 1024 circular transparente #111111 1.5s Hero
