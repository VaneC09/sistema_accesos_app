// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : notification_service.dart
// Módulo    : features/notifications/data
// Autor     : Omega Company
// Fecha     : 2026-05-29
// Versión   : 2.1.0
// Descripción: Notificaciones locales + polling del Bloc — RF-023, RNF-04
// =============================================================================

import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_logger.dart';
import 'notification_model.dart';

const _kCanalId = 'accesos_visitas_canal';
const _kCanalNombre = 'Accesos y Visitas';
const _kCanalDesc = 'Notificaciones de control de acceso';

class NotificationService {
  static const String _modulo = 'NOTIFICATION_SERVICE';

  NotificationService._();
  static final NotificationService instancia = NotificationService._();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Function(NotificationModel)? onNotificacionTocada;
  Function(NotificationModel)? onNotificacionRecibida;

  bool _inicializado = false;

  Future<void> inicializar() async {
    if (_inicializado) return;

    await _inicializarNotificacionesLocales();
    _inicializado = true;
    AppLogger.info(_modulo, 'NotificationService inicializado (modo polling)');
  }

  Future<void> _inicializarNotificacionesLocales() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onToqueNotificacionLocal,
    );

    if (Platform.isAndroid) {
      const canal = AndroidNotificationChannel(
        _kCanalId,
        _kCanalNombre,
        description: _kCanalDesc,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(canal);
    }

    if (Platform.isIOS) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  void _onToqueNotificacionLocal(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    AppLogger.info(_modulo, 'Notificación local tocada — payload: $payload');

    try {
      final notificacion = NotificationModel(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        tipo: _tipoDesdeString(payload),
        titulo: '',
        mensaje: '',
        fecha: DateTime.now(),
      );
      onNotificacionTocada?.call(notificacion);
    } catch (e) {
      AppLogger.error(_modulo, 'Error al procesar toque: $e');
    }
  }

  Future<void> mostrarNotificacionLocal({
    required String titulo,
    required String mensaje,
    required String tipo,
    int? idNotificacion,
  }) async {
    AppLogger.info(_modulo, 'Mostrando notificación local: $titulo');

    const androidDetalles = AndroidNotificationDetails(
      _kCanalId,
      _kCanalNombre,
      channelDescription: _kCanalDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetalles = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const detalles = NotificationDetails(
      android: androidDetalles,
      iOS: iosDetalles,
    );

    await _localNotifications.show(
      idNotificacion ?? DateTime.now().millisecondsSinceEpoch % 100000,
      titulo,
      mensaje,
      detalles,
      payload: tipo,
    );
  }

  Future<void> notificarIngresoVisitante({
    required String nombreVisitante,
    required String area,
    int? idNotificacion,
  }) async {
    await mostrarNotificacionLocal(
      titulo: '🟢 Visitante en camino',
      mensaje:
          '$nombreVisitante acaba de ingresar${area.isNotEmpty ? ' por $area' : ''}.',
      tipo: 'visitante_ingreso',
      idNotificacion: idNotificacion,
    );
  }

  Future<void> notificarSolicitudExtension({
    required String nombreVisitante,
    required String folio,
    int? idNotificacion,
  }) async {
    await mostrarNotificacionLocal(
      titulo: '⚠️ Solicitud de tiempo extra',
      mensaje:
          '$nombreVisitante llegó fuera de horario ($folio). Revisa y decide si autorizar.',
      tipo: 'solicitud_extension',
      idNotificacion: idNotificacion,
    );
  }

  Future<void> notificarQrExtendido({
    required String nombreVisitante,
    required String folio,
    int? idNotificacion,
  }) async {
    await mostrarNotificacionLocal(
      titulo: AppStrings.notifQrExtendidoTitulo,
      mensaje:
          '$nombreVisitante ($folio). ${AppStrings.notifQrExtendidoMensaje}',
      tipo: 'qr_extendido',
      idNotificacion: idNotificacion,
    );
  }

  TipoNotificacion _tipoDesdeString(String tipo) {
    switch (tipo) {
      case 'visitante_ingreso':
        return TipoNotificacion.visitanteIngreso;
      case 'solicitud_extension':
        return TipoNotificacion.solicitudExtension;
      case 'qr_expirado_tolerancia':
        return TipoNotificacion.qrExpiradoTolerancia;
      case 'qr_extendido':
        return TipoNotificacion.qrExtendido;
      case 'visitante_salida':
        return TipoNotificacion.visitanteSalida;
      case 'autorizada':
      case 'solicitud_autorizada':
        return TipoNotificacion.solicitudAutorizada;
      case 'rechazada':
      case 'solicitud_rechazada':
        return TipoNotificacion.solicitudRechazada;
      default:
        return TipoNotificacion.nuevaSolicitudPendiente;
    }
  }
}
