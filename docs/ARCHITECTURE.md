# Arquitectura - Central Boxing (Actualizado)

## Stack
Flutter 3.29.3, sqflite, provider, flutter_local_notifications, workmanager, image_picker, google_fonts, flutter_launcher_icons + flutter_native_splash

## Capas
- core/theme.dart (light/dark Oswald), core/constants.dart (`kGrupoWhatsApp`), core/fecha_mask_formatter.dart (`FechaMaskFormatter` auto `/` + `parseFecha` dd/MM/yyyy validado)
- providers: alumno_provider (activo==1, filtro + orden vencimiento/nombre/inscripcion), theme_provider (manual)
- db/database_helper v2, models/alumno (edad, foto_path), models/pago
- services: pago_service.siguienteVencimiento 28/29/31 + recalcularVencimiento/contarPagos/eliminarPago con recalcula desde inscripcion, notification_service.buildWhatsAppMessage con emojis + buildWelcomeMessage grupo Tehuacan, backup_service con _filtrar, auth_service PIN hash + biometria (`local_auth`, canUseBiometrics/authenticate, flag biometric_enabled)

## Pantallas
Login Hero gradiente 4 cajas (pegar PIN completo, backspace retrocede, auto-login huella, dialogo activar huella) + logout con confirmacion, Dashboard SliverAppBar 80 CENTRAL BOXING 22 FilterChip + menu Ordenar, Detail Sliver 250 parallax Hero 180 FullScreen InteractiveViewer + bottom sheet WhatsApp (recordatorio/bienvenida) + eliminar pago con confirmacion, Form 2 Cards foto + campos fecha con mascara dd/MM/yyyy, Settings 4 Cards (general + seguridad huella + backup + export)

## Android
Permiso `USE_BIOMETRIC`, `MainActivity : FlutterFragmentActivity` (requerido por `local_auth`), `debugShowCheckedModeBanner: false`

## BD
alumnos(id, nombre, telefono +52, fecha_inscripcion, fecha_vencimiento +1 mes, monto, foto_path, fecha_nacimiento NULL, activo) -> pagos(FK)

## Notificaciones
Workmanager 24h 09:00 query vencimiento BETWEEN now+3d y <now, canal central_boxing_channel, mensajes ⏰ vence / 🚨 vencio con Central Boxing

## Icono/Splash
launcher_icon adaptive #111111 desde logo_boxing.png circular, splash logo_splash.png 1024 circular transparente #111111 1.5s Hero
