import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../features/agenda/domain/evento.dart';
import '../../features/ajustes/domain/recordatorios_config.dart';
import '../../features/clientes/domain/cliente.dart';

/// Programa recordatorios locales para citas de agenda y procedimientos que
/// se acercan a su fecha meta, según los días de antelación y la hora que
/// el usuario haya elegido en Ajustes ([RecordatoriosConfig]).
///
/// Cada llamada a [reprogramar] cancela todo lo pendiente y vuelve a
/// programar desde cero a partir de los datos actuales, así que siempre
/// refleja el estado más reciente sin tener que rastrear altas/bajas/ediciones
/// una a una.
class NotificacionesService {
  NotificacionesService._();

  static final NotificacionesService instancia = NotificacionesService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _inicializado = false;

  static const _canal = AndroidNotificationDetails(
    'recordatorios',
    'Recordatorios',
    channelDescription: 'Avisos de citas y procedimientos de TusJuicios',
    importance: Importance.high,
    priority: Priority.high,
  );

  static const _detalles = NotificationDetails(
    android: _canal,
    iOS: DarwinNotificationDetails(),
  );

  Future<void> init() async {
    if (_inicializado) return;

    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Madrid'));

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    _inicializado = true;
  }

  tz.TZDateTime _aLasHoras(DateTime fecha, int hora) =>
      tz.TZDateTime(tz.local, fecha.year, fecha.month, fecha.day, hora);

  String _tituloAviso(String sujeto, int diasAntes) => switch (diasAntes) {
        0 => '$sujeto hoy',
        1 => '$sujeto mañana',
        _ => '$sujeto en $diasAntes días',
      };

  Future<void> reprogramar({
    required List<Evento> eventos,
    required List<Procedimiento> procedimientos,
    required RecordatoriosConfig config,
  }) async {
    await init();
    await _plugin.cancelAll();

    final ahora = tz.TZDateTime.now(tz.local);
    var id = 0;

    if (config.citasActivo) {
      for (final evento in eventos) {
        final vispera = evento.fecha.subtract(Duration(days: config.citasDiasAntes));
        final aviso = _aLasHoras(vispera, config.citasHora);
        if (aviso.isBefore(ahora)) continue;

        await _plugin.zonedSchedule(
          id: id++,
          title: _tituloAviso('Cita', config.citasDiasAntes),
          body: '${evento.clienteNombre ?? evento.descripcion ?? 'Personal'}'
              '${evento.clienteNombre != null && evento.descripcion != null ? ' · ${evento.descripcion}' : ''}'
              '${evento.hora != null ? ' a las ${evento.hora}' : ''}',
          scheduledDate: aviso,
          notificationDetails: _detalles,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    }

    if (config.procedimientosActivo) {
      for (final procedimiento in procedimientos) {
        final fechaMeta = procedimiento.fechaMeta;
        if (fechaMeta == null || procedimiento.estado == EstadoProcedimiento.cerrado) continue;

        final aviso = _aLasHoras(
          fechaMeta.subtract(Duration(days: config.procedimientosDiasAntes)),
          config.procedimientosHora,
        );
        if (aviso.isBefore(ahora)) continue;

        await _plugin.zonedSchedule(
          id: id++,
          title: 'Procedimiento por vencer',
          body: '${procedimiento.nombre} vence el ${fechaMeta.day}/${fechaMeta.month}',
          scheduledDate: aviso,
          notificationDetails: _detalles,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    }
  }
}
