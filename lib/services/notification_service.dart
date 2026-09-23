import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../core/constants.dart';
import '../db/database_helper.dart';
import 'package:intl/intl.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static Future<void> init() async {
    const init = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/launcher_icon'),
    );
    await _plugin.initialize(init);
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            'central_boxing_channel',
            'Vencimientos',
            importance: Importance.high,
          ),
        );
  }

  static Future<void> checkAndNotify() async {
    final db = await DatabaseHelper.instance.db;
    final porVencer = await db.rawQuery(
      "SELECT * FROM alumnos WHERE activo=1 AND date(fecha_vencimiento) BETWEEN date('now') AND date('now','+3 days')",
    );
    final vencidos = await db.rawQuery(
      "SELECT * FROM alumnos WHERE activo=1 AND date(fecha_vencimiento) < date('now')",
    );
    int id = 0;
    for (final a in porVencer) {
      final fecha = DateFormat(
        'dd/MM/yyyy',
        'es',
      ).format(DateTime.parse(a['fecha_vencimiento'] as String));
      await _plugin.show(
        id++,
        '⏰ Tu cuota vence - ${a['nombre']}',
        '${a['nombre']}, tu cuota vence el $fecha 💳 Monto: \$${a['monto']} — ¡Te esperamos en Central Boxing! 🥊',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'central_boxing_channel',
            'Vencimientos',
          ),
        ),
      );
    }
    for (final a in vencidos) {
      final fecha = DateFormat(
        'dd/MM/yyyy',
        'es',
      ).format(DateTime.parse(a['fecha_vencimiento'] as String));
      await _plugin.show(
        id++,
        '🚨 Tu cuota venció - ${a['nombre']}',
        '⚠️ ${a['nombre']}, tu cuota venció el $fecha — Monto: \$${a['monto']} 💳 Regulariza en Central Boxing 🥊',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'central_boxing_channel',
            'Vencimientos',
            importance: Importance.high,
          ),
        ),
      );
    }
    if (porVencer.isNotEmpty || vencidos.isNotEmpty) {
      await _plugin.show(
        999,
        '🥊 Central Boxing',
        '${porVencer.length} por vencer, ${vencidos.length} vencidos',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'central_boxing_channel',
            'Vencimientos',
          ),
        ),
      );
    }
  }

  static String buildWhatsAppMessage(
    String nombre,
    String fecha,
    String monto,
    bool vencido,
  ) {
    if (vencido) {
      return '👋 Hola $nombre!\n\n🚨 *Tu cuota venció* el *$fecha* ⚠️\n💳 Monto pendiente: *\$$monto*\n📍 Central Boxing 🥊\n\n¿Nos ayudas a regularizar? ¡Te esperamos! 🙏';
    } else {
      return '👋 Hola $nombre!\n\n⏰ *Tu cuota vence* el *$fecha* 🗓️\n💳 Monto: *\$$monto*\n📍 Central Boxing 🥊\n\n¡Te esperamos para seguir entrenando! 💪';
    }
  }

  static String buildWelcomeMessage(String nombre) {
    return '👋 ¡Hola $nombre! 🥊\n\n🎉 *Bienvenido(a) a la familia Central Boxing Tehuacán* 🎉\n\nTe invito a unirte a nuestro grupo de WhatsApp para estar al tanto de sparrings, avisos, eventos y más 👇\n\n$kGrupoWhatsApp\n\n¡Nos vemos en el gym! 💪';
  }
}
