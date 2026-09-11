import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../db/database_helper.dart';
import 'package:intl/intl.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static Future<void> init() async {
    const init = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
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
      await _plugin.show(
        id++,
        'Por vencer: ${a['nombre']}',
        'Vence ${DateFormat('dd/MM/yyyy').format(DateTime.parse(a['fecha_vencimiento'] as String))} - \$${a['monto']}',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'central_boxing_channel',
            'Vencimientos',
          ),
        ),
      );
    }
    for (final a in vencidos) {
      await _plugin.show(
        id++,
        'Vencido: ${a['nombre']}',
        'Venció ${DateFormat('dd/MM/yyyy').format(DateTime.parse(a['fecha_vencimiento'] as String))}',
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
        'Central Boxing',
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
}
