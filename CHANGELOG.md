# Changelog

## 1.1.0 - 2026-09-23 - d26e961
- Huella biometrica con `local_auth`: login automatico, dialogo para activar tras PIN, interruptor en Ajustes (PIN queda como respaldo). Android: permiso `USE_BIOMETRIC` + `MainActivity` a `FlutterFragmentActivity`
- Cerrar sesion con confirmacion desde Dashboard (vuelve a pedir PIN/huella)
- Dashboard con orden: por vencimiento / alfabetico A-Z / mas recientes + menu Ordenar
- Eliminar pago con confirmacion y recalculo de vencimiento desde inscripcion (`recalcularVencimiento`, `contarPagos`, `eliminarPago`) + 5 tests nuevos
- Form alumno con `FechaMaskFormatter` dd/MM/yyyy (auto `/`, max 8 digitos) + `parseFecha` con validacion real (rechaza 31/02, acepta 29/02/2024) + 4 tests
- WhatsApp con 2 opciones en Detalle: recordatorio de pago (vence/vencio) y bienvenida + grupo Tehuacan (`buildWelcomeMessage`, `kGrupoWhatsApp`)
- Detalle Sliver 250 parallax con titulo, tarjeta foto `FileImage` en lista y detalle

## 1.0.0 - 2026
- f14efe7: repositories, tests edad, CI (`flutter analyze` + `flutter test --coverage`), dart doc, legibilidad
- a11b10e: README y arquitectura completos en espanol UTF-8, manual usuario y changelog
- b1e7bf9: mensajes vence/vencio con emojis y estructura limpia - notif y WhatsApp Central Boxing
- Fases 1-5 completas, estetica A Sliver, foto camara/galeria, launcher icon + splash redondo
